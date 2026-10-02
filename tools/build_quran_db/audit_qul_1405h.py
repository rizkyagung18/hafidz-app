"""Read-only source audit for the proposed QUL 1405H Mushaf package.

The QUL download exports require account sign-in. This tool accepts exports
obtained by the resource owner; it never downloads or modifies Quran content.
It intentionally does not claim visual or license verification.
"""

from __future__ import annotations

import argparse
import bisect
import hashlib
import json
import re
import sqlite3
import subprocess
from collections import Counter, defaultdict
from contextlib import closing
from itertools import pairwise
from pathlib import Path
from typing import Any
from urllib.parse import quote

PAGE_FONT = re.compile(r"p([1-9][0-9]*)(?:-v1)?\.ttf\Z", re.IGNORECASE)
LINE_COLUMNS = {
    "page_number",
    "line_number",
    "line_type",
    "is_centered",
    "first_word_id",
    "last_word_id",
    "surah_number",
}
WORD_COLUMNS = {"surah", "ayah", "text"}
CANONICAL_COLUMNS = {"id", "surah", "ayah", "page"}
LAYOUT_INFO_COLUMNS = {"name", "number_of_pages", "lines_per_page", "font_name"}


class AuditError(ValueError):
    """The input cannot be interpreted using the documented QUL schema."""


def _hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _open_read_only(path: Path) -> sqlite3.Connection:
    if not path.is_file():
        raise AuditError(f"Missing SQLite file: {path}")
    database = sqlite3.connect(f"file:{quote(str(path.resolve()))}?mode=ro", uri=True)
    database.row_factory = sqlite3.Row
    database.execute("PRAGMA query_only = ON")
    return database


def _rows(path: Path, table: str, required: set[str]) -> list[sqlite3.Row]:
    # Table names are constants from this module, never user input.
    with closing(_open_read_only(path)) as database:
        available = {row[1] for row in database.execute(f"PRAGMA table_info({table})")}
        missing = sorted(required - available)
        if missing:
            raise AuditError(
                f"{path}: {table} is missing columns {missing}; "
                f"actual columns: {sorted(available)}"
            )
        return database.execute(f"SELECT * FROM {table}").fetchall()


def _source_file(path: Path) -> dict[str, Any]:
    return {"path": str(path), "sha256": _hash_file(path), "bytes": path.stat().st_size}


def _font_charset(path: Path) -> set[int]:
    """Read the TTF's Unicode cmap through fontconfig, when explicitly requested."""
    try:
        result = subprocess.run(
            ["fc-query", "--format", "%{charset}\n", str(path)],
            capture_output=True,
            text=True,
            check=True,
            timeout=15,
        )
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as error:
        raise AuditError(f"Cannot inspect font cmap for {path}: {error}") from error
    charset: set[int] = set()
    for item in result.stdout.split():
        if not re.fullmatch(r"[0-9a-fA-F]+(?:-[0-9a-fA-F]+)?", item):
            raise AuditError(f"Unrecognized fontconfig charset item {item!r} in {path}")
        start, _, end = item.partition("-")
        charset.update(range(int(start, 16), int(end or start, 16) + 1))
    if not charset:
        raise AuditError(f"Empty font cmap for {path}")
    return charset


def audit(
    layout_db: Path,
    script_db: Path,
    canonical_db: Path,
    font_dir: Path,
    *,
    expected_pages: int = 604,
    expected_ayahs: int = 6236,
    check_font_coverage: bool = False,
) -> dict[str, Any]:
    """Inspect exports and report every page difference without changing inputs.

    Counts are configurable only for small synthetic test fixtures. Production
    CLI calls use the published 604 pages and 6,236 canonical ayat.
    """
    lines = _rows(layout_db, "pages", LINE_COLUMNS)
    metadata = _rows(layout_db, "info", LAYOUT_INFO_COLUMNS)
    words = _rows(script_db, "words", WORD_COLUMNS)
    word_columns = set(words[0].keys()) if words else set()
    source_word_id = "word_index" if "word_index" in word_columns else "id"
    if source_word_id not in word_columns:
        raise AuditError(
            f"{script_db}: words must have a source word ID column "
            f"(id or word_index); actual columns: {sorted(word_columns)}"
        )
    canonical = _rows(canonical_db, "ayah", CANONICAL_COLUMNS)
    if not font_dir.is_dir():
        raise AuditError(f"Missing font directory: {font_dir}")

    errors: list[str] = []
    warnings: list[str] = []
    if len(metadata) != 1:
        errors.append(
            f"Layout info must contain exactly one edition row, got {len(metadata)}"
        )
    else:
        edition = metadata[0]
        if (
            "1405" not in str(edition["name"])
            or str(edition["font_name"]).lower() != "v1"
        ):
            errors.append("Layout info does not identify the 1405H V1 edition")
        if int(edition["number_of_pages"]) != expected_pages:
            errors.append("Layout info page count differs from the expected edition")
        if expected_pages == 604 and int(edition["lines_per_page"]) != 15:
            errors.append("Layout info does not specify the 15-line print")
    canonical_pages = {
        (int(a["surah"]), int(a["ayah"])): int(a["page"]) for a in canonical
    }
    if len(canonical) != expected_ayahs or len(canonical_pages) != expected_ayahs:
        errors.append(
            f"Canonical ayah count/unique keys must be {expected_ayahs}: "
            f"rows={len(canonical)}, keys={len(canonical_pages)}"
        )

    word_map: dict[int, sqlite3.Row] = {}
    word_positions: dict[tuple[int, int], set[int]] = defaultdict(set)
    for word in words:
        index = int(word[source_word_id])
        if index in word_map:
            errors.append(f"Duplicate source word ID {index}")
        word_map[index] = word
        if "location" in word_columns and "word" in word_columns:
            key = (int(word["surah"]), int(word["ayah"]))
            position = int(word["word"])
            if position in word_positions[key]:
                errors.append(f"Duplicate source word position {key}:{position}")
            word_positions[key].add(position)
            expected_location = f"{word['surah']}:{word['ayah']}:{word['word']}"
            if word["location"] != expected_location:
                errors.append(
                    f"Word {index} location {word['location']!r} differs from "
                    f"{expected_location!r}"
                )
    word_ids = sorted(word_map)
    if word_ids != list(range(1, len(words) + 1)):
        errors.append("Source word IDs are not exactly consecutive from 1")
    for key, positions in word_positions.items():
        if sorted(positions) != list(range(1, len(positions) + 1)):
            errors.append(f"Source word positions are not consecutive for {key}")

    page_lines: dict[int, set[int]] = defaultdict(set)
    page_first_ayah: dict[tuple[int, int], int] = {}
    word_membership: Counter[int] = Counter()
    page_codepoints: dict[int, set[int]] = defaultdict(set)
    line_types: Counter[str] = Counter()
    source_ranges: list[tuple[int, int, int, int]] = []
    for line in sorted(
        lines, key=lambda row: (int(row["page_number"]), int(row["line_number"]))
    ):
        page = int(line["page_number"])
        number = int(line["line_number"])
        kind = str(line["line_type"])
        line_types[kind] += 1
        if number in page_lines[page]:
            errors.append(f"Duplicate line {page}:{number}")
        page_lines[page].add(number)
        if kind != "ayah":
            if kind not in {"surah_name", "basmallah"}:
                errors.append(
                    f"Unrecognized source line type {kind!r} at {page}:{number}"
                )
            continue
        first, last = line["first_word_id"], line["last_word_id"]
        if first is None or last is None or int(first) > int(last):
            errors.append(f"Invalid word range at {page}:{number}: {first}..{last}")
            continue
        source_ranges.append((int(first), int(last), page, number))
        start = bisect.bisect_left(word_ids, int(first))
        end = bisect.bisect_right(word_ids, int(last))
        if (
            start == end
            or word_ids[start] != int(first)
            or word_ids[end - 1] != int(last)
        ):
            errors.append(
                f"Missing first/last source word at {page}:{number}: {first}..{last}"
            )
        for index in word_ids[start:end]:
            word = word_map[index]
            key = (int(word["surah"]), int(word["ayah"]))
            if key not in canonical_pages:
                errors.append(f"Word {index} references unknown canonical ayah {key}")
            elif not str(word["text"]):
                errors.append(f"Word {index} has empty glyph text")
            else:
                page_first_ayah[key] = min(page, page_first_ayah.get(key, page))
                page_codepoints[page].update(map(ord, str(word["text"])))
            word_membership[index] += 1

    if sorted(page_lines) != list(range(1, expected_pages + 1)):
        errors.append(f"Layout must cover consecutive pages 1..{expected_pages}")
    for page, line_numbers in page_lines.items():
        if sorted(line_numbers) != list(range(1, len(line_numbers) + 1)):
            errors.append(f"Page {page} has a missing or noncontiguous line number")
        if expected_pages == 604:
            expected_lines = 8 if page in {1, 2} else 15
            if len(line_numbers) != expected_lines:
                errors.append(
                    f"Page {page} has {len(line_numbers)} rows; inspected layout has {expected_lines}"
                )
    for before, after in pairwise(source_ranges):
        if before[1] + 1 != after[0]:
            errors.append(
                f"Source word ranges are not consecutive between "
                f"{before[2]}:{before[3]} and {after[2]}:{after[3]}"
            )
    missing_ayat = sorted(canonical_pages.keys() - page_first_ayah.keys())
    if missing_ayat:
        errors.append(f"{len(missing_ayat)} canonical ayat have no layout words")
    orphan_words = sorted(word_map.keys() - word_membership.keys())
    repeated_words = sorted(
        index for index, count in word_membership.items() if count > 1
    )
    if orphan_words:
        errors.append(f"{len(orphan_words)} source words are not assigned to any line")
    if repeated_words:
        errors.append(f"{len(repeated_words)} source words occur on multiple lines")

    page_differences = [
        {
            "ayah": f"{key[0]}:{key[1]}",
            "legacy_page": old_page,
            "edition_page": page_first_ayah[key],
        }
        for key, old_page in sorted(canonical_pages.items())
        if key in page_first_ayah and page_first_ayah[key] != old_page
    ]
    if page_first_ayah.get((2, 255)) != 42 and expected_pages == 604:
        errors.append("1405H mapping must place 2:255 on page 42")

    font_files: dict[int, dict[str, Any]] = {}
    other_ttf: list[str] = []
    for path in sorted(font_dir.rglob("*.ttf")):
        match = PAGE_FONT.fullmatch(path.name)
        if match is None:
            other_ttf.append(str(path.relative_to(font_dir)))
            continue
        page = int(match.group(1))
        if page in font_files:
            errors.append(f"Multiple font files identified for page {page}")
        font_files[page] = _source_file(path)
    missing_fonts = sorted(set(range(1, expected_pages + 1)) - font_files.keys())
    if missing_fonts:
        errors.append(f"No recognized page font for {len(missing_fonts)} pages")
    missing_glyphs: dict[str, list[str]] = {}
    if check_font_coverage:
        for page, codepoints in sorted(page_codepoints.items()):
            font = font_files.get(page)
            if font is None:
                continue
            available = _font_charset(Path(font["path"]))
            absent = sorted(codepoints - available)
            if absent:
                missing_glyphs[str(page)] = [f"U+{point:04X}" for point in absent]
                errors.append(f"Page {page} font lacks {len(absent)} source glyphs")

    return {
        "edition": "madinah-1405h-qpc-v1",
        "source_resources": {"layout": 15, "script": 57, "font": 238},
        "sources": {
            "layout": _source_file(layout_db),
            "script": _source_file(script_db),
            "canonical": _source_file(canonical_db),
        },
        "layout_info": dict(metadata[0]) if len(metadata) == 1 else None,
        "counts": {
            "pages": len(page_lines),
            "lines": len(lines),
            "source_words": len(words),
            "mapped_ayat": len(page_first_ayah),
            "recognized_page_fonts": len(font_files),
            "font_bytes": sum(entry["bytes"] for entry in font_files.values()),
            "font_coverage_checked_pages": len(page_codepoints) if check_font_coverage else 0,
        },
        "word_columns": sorted(word_columns),
        "source_word_id_column": source_word_id,
        "line_types": dict(sorted(line_types.items())),
        "page_line_counts": {
            str(page): len(numbers) for page, numbers in sorted(page_lines.items())
        },
        "page_differences": page_differences,
        "missing_ayat": [f"{surah}:{ayah}" for surah, ayah in missing_ayat],
        "orphan_word_ids": orphan_words,
        "repeated_word_ids": repeated_words,
        "missing_font_pages": missing_fonts,
        "missing_glyphs_by_page": missing_glyphs,
        "unrecognized_ttf_files": other_ttf,
        "font_files": {str(page): file for page, file in sorted(font_files.items())},
        "license_files": [
            str(path.relative_to(font_dir))
            for path in sorted(font_dir.rglob("*"))
            if path.is_file()
            and re.search(r"(?i)(license|licence|copyright|ofl)", path.name)
        ],
        "errors": errors,
        "warnings": warnings,
        "unverified": [
            "Printed visual fidelity requires renderer validation and user review.",
            "Resource-specific redistribution rights require human review.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--layout", type=Path, required=True, help="QUL resource 15 SQLite export"
    )
    parser.add_argument(
        "--script", type=Path, required=True, help="QUL resource 57 SQLite export"
    )
    parser.add_argument(
        "--fonts",
        type=Path,
        required=True,
        help="Unpacked QUL resource 238 TTF directory",
    )
    parser.add_argument(
        "--canonical",
        type=Path,
        default=Path("apps/mobile/assets/db/quran.sqlite"),
        help="Existing schema-v1 canonical Quran database",
    )
    parser.add_argument(
        "--report", type=Path, required=True, help="Output JSON audit report"
    )
    parser.add_argument(
        "--check-font-coverage",
        action="store_true",
        help="Use fc-query to verify every page font contains its source word glyphs",
    )
    args = parser.parse_args()
    try:
        report = audit(
            args.layout,
            args.script,
            args.canonical,
            args.fonts,
            check_font_coverage=args.check_font_coverage,
        )
    except (AuditError, sqlite3.DatabaseError, OSError, ValueError) as error:
        parser.exit(2, f"QUL audit input error: {error}\n")
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"Wrote {args.report}: {report['counts']['pages']} pages, "
        f"{report['counts']['mapped_ayat']} mapped ayat, "
        f"{len(report['page_differences'])} legacy page differences, "
        f"{len(report['errors'])} errors."
    )
    return 1 if report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
