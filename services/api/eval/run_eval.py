"""Run the Voice Ayah Finder golden-set evaluation without saving audio or transcripts."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sqlite3
import sys
import time
from collections import Counter
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

API_DIR = Path(__file__).resolve().parents[1]
ROOT_DIR = API_DIR.parents[1]
if str(API_DIR) not in sys.path:
    sys.path.insert(0, str(API_DIR))

from app.asr.audio import decode_to_pcm16k  # noqa: E402
from app.asr.model import QuranAsr  # noqa: E402
from app.matching.index import load_index  # noqa: E402
from app.matching.matcher import DEFAULT_THRESHOLDS, QuranMatcher  # noqa: E402
from app.matching.metadata import QuranMetadata  # noqa: E402
from app.matching.normalize import cleanup_query  # noqa: E402
from app.settings import AsrSettings  # noqa: E402

from eval.evaluation import (  # noqa: E402
    character_error_rate,
    summarize_samples,
    word_error_rate,
)

DATASET_VERSION = "golden-v1"
MANIFEST_FIELDS = ("path", "surah", "ayah_start", "ayah_end", "condition")
EXPECTED_COUNTS = {
    "clean-full": 600,
    "clean-partial": 400,
    "span": 300,
    "noisy": 400,
    "speaker-replay": 150,
    "user-real": 300,
    "negative": 150,
    "ambiguous": 50,
}
ALLOWED_CONDITIONS = frozenset(EXPECTED_COUNTS)


@dataclass(frozen=True, slots=True)
class ManifestEntry:
    path: str
    surah: int | None
    ayah_start: int | None
    ayah_end: int | None
    condition: str


def read_manifest(path: Path) -> list[ManifestEntry]:
    """Parse the versioned CSV and validate identifiers and relative audio paths."""
    if not path.is_file():
        raise FileNotFoundError(f"Golden-set manifest not found: {path}")
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        if tuple(reader.fieldnames or ()) != MANIFEST_FIELDS:
            raise ValueError("Manifest headers must be exactly: " + ",".join(MANIFEST_FIELDS))
        entries: list[ManifestEntry] = []
        seen_paths: set[str] = set()
        for line_number, row in enumerate(reader, start=2):
            relative_path = (row.get("path") or "").strip()
            candidate_path = Path(relative_path)
            if (
                not relative_path
                or candidate_path.is_absolute()
                or ".." in candidate_path.parts
                or relative_path in seen_paths
            ):
                raise ValueError(f"Manifest line {line_number} has an invalid or repeated path.")
            condition = (row.get("condition") or "").strip()
            if condition not in ALLOWED_CONDITIONS:
                raise ValueError(
                    f"Manifest line {line_number} has unknown condition {condition!r}."
                )
            if condition == "negative":
                if any(
                    (row.get(field) or "").strip() for field in ("surah", "ayah_start", "ayah_end")
                ):
                    raise ValueError(
                        f"Negative sample on line {line_number} must omit ayah labels."
                    )
                surah = start = end = None
            else:
                try:
                    surah = int(row["surah"])
                    start = int(row["ayah_start"])
                    end = int(row["ayah_end"])
                except (TypeError, ValueError) as exc:
                    raise ValueError(
                        f"Manifest line {line_number} needs integer ayah labels."
                    ) from exc
                if not 1 <= surah <= 114 or start < 1 or end < start:
                    raise ValueError(f"Manifest line {line_number} has an invalid ayah range.")
            seen_paths.add(relative_path)
            entries.append(ManifestEntry(relative_path, surah, start, end, condition))
    return entries


def _load_reference(database: Path, entry: ManifestEntry) -> str:
    if entry.surah is None or entry.ayah_start is None or entry.ayah_end is None:
        return ""
    uri = f"file:{database.resolve()}?mode=ro"
    with sqlite3.connect(uri, uri=True) as connection:
        rows = connection.execute(
            "SELECT text_norm FROM ayah WHERE surah = ? AND ayah BETWEEN ? AND ? ORDER BY ayah",
            (entry.surah, entry.ayah_start, entry.ayah_end),
        ).fetchall()
    if len(rows) != entry.ayah_end - entry.ayah_start + 1:
        raise ValueError(
            "Reference ayah range is missing from database: "
            f"{entry.surah}:{entry.ayah_start}-{entry.ayah_end}"
        )
    return " ".join(str(row[0]) for row in rows)


def _length_bucket(database: Path, entry: ManifestEntry) -> str | None:
    if entry.surah is None or entry.ayah_start is None or entry.ayah_end is None:
        return None
    uri = f"file:{database.resolve()}?mode=ro"
    with sqlite3.connect(uri, uri=True) as connection:
        rows = connection.execute(
            "SELECT text_norm FROM ayah WHERE surah = ? AND ayah BETWEEN ? AND ?",
            (entry.surah, entry.ayah_start, entry.ayah_end),
        ).fetchall()
    if len(rows) != entry.ayah_end - entry.ayah_start + 1:
        raise ValueError(
            f"Reference ayah range is missing from database: "
            f"{entry.surah}:{entry.ayah_start}-{entry.ayah_end}"
        )
    length = sum(len(str(row[0]).replace(" ", "")) for row in rows)
    if length < 40:
        return "short"
    if length <= 300:
        return "medium"
    return "long"


def _verify_data(database: Path, index_path: Path) -> tuple[dict[str, Any], QuranMetadata]:
    index = load_index(index_path)
    actual_hash = hashlib.sha256(database.read_bytes()).hexdigest()
    if index.get("database_sha256") != actual_hash:
        raise ValueError("Search index was built from a different Quran database.")
    return index, QuranMetadata.load(database)


def _evaluate_entry(
    entry: ManifestEntry,
    *,
    audio_root: Path,
    database: Path,
    asr: QuranAsr,
    matcher: QuranMatcher,
) -> dict[str, Any]:
    sample_path = (audio_root / entry.path).resolve()
    if not sample_path.is_relative_to(audio_root.resolve()):
        raise ValueError(f"Manifest path escapes the audio directory: {entry.path}")
    if not sample_path.is_file():
        raise FileNotFoundError(f"Golden-set audio is missing: {entry.path}")
    raw = sample_path.read_bytes()
    decode_started = time.perf_counter()
    pcm = decode_to_pcm16k(raw)
    decode_ms = (time.perf_counter() - decode_started) * 1000
    del raw
    asr_started = time.perf_counter()
    try:
        asr_result = asr.transcribe(pcm)
    finally:
        pcm.fill(0)
        del pcm
    asr_ms = (time.perf_counter() - asr_started) * 1000
    cleaned = cleanup_query(asr_result.text).text
    match_started = time.perf_counter()
    match_result = matcher.match(
        asr_result.text,
        asr_quality=QuranAsr.quality(asr_result),
    )
    match_ms = (time.perf_counter() - match_started) * 1000
    cer = wer = None
    length_bucket = _length_bucket(database, entry)
    if entry.condition == "clean-full":
        reference = _load_reference(database, entry)
        cer = character_error_rate(reference, cleaned)
        wer = word_error_rate(reference, cleaned)

    def candidate_dict(candidate: Any) -> dict[str, Any]:
        return {
            "surah": candidate.surah,
            "ayah_start": candidate.ayah_start,
            "ayah_end": candidate.ayah_end,
            "score": candidate.score,
        }

    return {
        "clip_id": Path(entry.path).stem,
        "condition": entry.condition,
        "length_bucket": length_bucket,
        "surah": entry.surah,
        "ayah_start": entry.ayah_start,
        "ayah_end": entry.ayah_end,
        "best": candidate_dict(match_result.best) if match_result.best else None,
        "candidates": [candidate_dict(item) for item in match_result.candidates[:5]],
        "confidence": match_result.confidence,
        "margin": match_result.margin,
        "ambiguous": match_result.ambiguous,
        "reason": match_result.reason,
        "latency_ms": decode_ms + asr_ms + match_ms,
        "decode_ms": decode_ms,
        "asr_ms": asr_ms,
        "match_ms": match_ms,
        "cer": cer,
        "wer": wer,
    }


def _dataset_status(entries: list[ManifestEntry]) -> tuple[str, dict[str, int]]:
    distribution = Counter(entry.condition for entry in entries)
    complete = all(distribution.get(name, 0) >= target for name, target in EXPECTED_COUNTS.items())
    return ("complete" if complete else "incomplete"), dict(sorted(distribution.items()))


def _build_result(samples: list[dict[str, Any]], entries: list[ManifestEntry]) -> dict[str, Any]:
    status, distribution = _dataset_status(entries)
    return {
        "dataset": DATASET_VERSION,
        "status": status,
        "expected_counts": EXPECTED_COUNTS,
        "actual_counts": distribution,
        "sample_count": len(samples),
        "metrics": summarize_samples(samples),
        "thresholds": asdict(DEFAULT_THRESHOLDS),
        "samples": samples,
    }


def _empty_result() -> dict[str, Any]:
    return {
        "dataset": DATASET_VERSION,
        "status": "blocked",
        "expected_counts": EXPECTED_COUNTS,
        "actual_counts": {},
        "sample_count": 0,
        "metrics": {},
        "thresholds": asdict(DEFAULT_THRESHOLDS),
        "samples": [],
        "blocker": "No audio samples are registered in the golden-v1 manifest.",
    }


def _format_metric(value: Any, *, percent: bool = False) -> str:
    if value is None:
        return "not measured"
    return f"{float(value) * 100:.2f}%" if percent else f"{float(value):.1f}"


def render_report(result: dict[str, Any]) -> str:
    """Create a shareable report containing aggregate metrics only."""
    lines = [
        "# Golden-v1 evaluation report",
        "",
        f"**Status:** `{result['status']}`  ",
        f"**Samples evaluated:** {result['sample_count']}",
        "",
    ]
    if result["status"] == "blocked":
        lines.extend(
            [
                f"Evaluation was not run: {result['blocker']}",
                "No accuracy or latency claim is made. Add licensed, consented samples to the "
                "private audio store and register their relative paths in "
                "`services/api/eval/golden-v1/manifest.csv`.",
                "",
            ]
        )
    else:
        lines.extend(
            ["## Dataset coverage", "", "| Subset | Target | Available |", "|---|---:|---:|"]
        )
        for name, target in EXPECTED_COUNTS.items():
            lines.append(f"| `{name}` | {target} | {result['actual_counts'].get(name, 0)} |")
        overall = result["metrics"].get("overall", {})
        lines.extend(
            [
                "",
                "## Overall metrics",
                "",
                "| Metric | Measured | Release gate |",
                "|---|---:|---:|",
                f"| Top-1 accuracy | {_format_metric(overall.get('top1_accuracy'), percent=True)} | "  # noqa: E501
                "≥ 90% overall |",
                f"| Top-3 accuracy | {_format_metric(overall.get('top3_accuracy'), percent=True)} | "  # noqa: E501
                "≥ 97% |",
                f"| Range exact (`span`) | "
                f"{_format_metric(overall.get('range_exact_accuracy'), percent=True)} | ≥ 80% |",
                f"| False auto-navigate | "
                f"{_format_metric(overall.get('false_auto_navigate_rate'), percent=True)} | ≤ 1% |",
                f"| Negative rejection | "
                f"{_format_metric(overall.get('negative_rejection_rate'), percent=True)} | ≥ 95% |",
                f"| CER (`clean-full`) | "
                f"{_format_metric(overall.get('cer_clean_full_mean'), percent=True)} | tracked |",
                f"| WER (`clean-full`) | "
                f"{_format_metric(overall.get('wer_clean_full_mean'), percent=True)} | tracked |",
                f"| Latency p50 | {_format_metric(overall.get('latency_ms_p50'))} ms | tracked |",
                f"| Latency p95 | {_format_metric(overall.get('latency_ms_p95'))} ms | ≤ 1,500 ms |",  # noqa: E501
                "",
                "## Per-subset metrics",
                "",
                "| Subset | N | Top-1 | Top-3 | False auto | Negative rejection |",
                "|---|---:|---:|---:|---:|---:|",
            ]
        )
        for subset, metrics in result["metrics"].items():
            if subset == "overall" or subset.startswith("length:"):
                continue
            lines.append(
                f"| `{subset}` | {metrics['samples']} | "
                f"{_format_metric(metrics['top1_accuracy'], percent=True)} | "
                f"{_format_metric(metrics['top3_accuracy'], percent=True)} | "
                f"{_format_metric(metrics['false_auto_navigate_rate'], percent=True)} | "
                f"{_format_metric(metrics['negative_rejection_rate'], percent=True)} |"
            )
        lines.extend(
            [
                "",
                "## Per ayah-length metrics",
                "",
                "| Bucket | N | Top-1 | Top-3 |",
                "|---|---:|---:|---:|",
            ]
        )
        for key in ("length:short", "length:medium", "length:long"):
            metrics = result["metrics"].get(key)
            if metrics is None:
                continue
            lines.append(
                f"| `{key.split(':', maxsplit=1)[1]}` | {metrics['samples']} | "
                f"{_format_metric(metrics['top1_accuracy'], percent=True)} | "
                f"{_format_metric(metrics['top3_accuracy'], percent=True)} |"
            )
        if result["status"] != "complete":
            lines.extend(
                [
                    "",
                    "> Dataset coverage is incomplete. Metrics are provisional and cannot be used "
                    "as release-gate evidence.",
                ]
            )
        lines.extend(
            [
                "",
                "Audio and transcript strings are not included in this report or the metrics JSON. "
                "CER/WER are calculated only for `clean-full` against normalized search-index text.",  # noqa: E501
                "",
            ]
        )
    return "\n".join(lines)


def write_outputs(result: dict[str, Any], output_json: Path, output_markdown: Path) -> None:
    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_markdown.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(
        json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    output_markdown.write_text(render_report(result), encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest",
        type=Path,
        default=API_DIR / "eval" / DATASET_VERSION / "manifest.csv",
    )
    parser.add_argument(
        "--audio-root", type=Path, default=API_DIR / "eval" / DATASET_VERSION / "audio"
    )
    parser.add_argument(
        "--database", type=Path, default=ROOT_DIR / "apps/mobile/assets/db/quran.sqlite"
    )
    parser.add_argument("--index", type=Path, default=API_DIR / "data/quran_index.pkl")
    parser.add_argument("--model-dir", type=Path, default=None)
    parser.add_argument(
        "--output-json",
        type=Path,
        default=API_DIR / "eval/output/golden-v1-metrics.json",
    )
    parser.add_argument(
        "--output-markdown",
        type=Path,
        default=ROOT_DIR / "docs/eval/golden-v1-report.md",
    )
    parser.add_argument(
        "--allow-empty",
        action="store_true",
        help="Write an explicit blocked report when the manifest has no rows (intended for CI).",
    )
    return parser


def main() -> int:
    args = build_parser().parse_args()
    entries = read_manifest(args.manifest)
    if not entries:
        if not args.allow_empty:
            raise SystemExit(
                "Golden-v1 manifest contains no samples; use --allow-empty only in CI."
            )
        result = _empty_result()
    else:
        index, _metadata = _verify_data(args.database, args.index)
        matcher = QuranMatcher(index)
        model_settings = AsrSettings()
        asr = QuranAsr(
            args.model_dir or model_settings.model_dir,
            model_settings.cpu_threads,
            model_settings.num_workers,
            model_settings.beam_size,
        )
        samples = [
            _evaluate_entry(
                entry,
                audio_root=args.audio_root,
                database=args.database,
                asr=asr,
                matcher=matcher,
            )
            for entry in entries
        ]
        result = _build_result(samples, entries)
    write_outputs(result, args.output_json, args.output_markdown)
    print(
        f"Wrote {result['status']} {DATASET_VERSION} report for "
        f"{result['sample_count']} sample(s): {args.output_markdown}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
