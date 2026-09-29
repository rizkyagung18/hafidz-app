"""Download and convert the Tarteel Quran Whisper checkpoint for faster-whisper."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path
from typing import Any

MODEL_ID = "tarteel-ai/whisper-base-ar-quran"
MODEL_REVISION = "e3f4a5f3f5336a1f0e43a2c2bdae62a680c53a8c"
ROOT = Path(__file__).resolve().parents[2]
SOURCE_DIR = ROOT / "models/hf-whisper-base-ar-quran"
OUTPUT_DIR = ROOT / "models/whisper-base-ar-quran-ct2-int8"
EVERYAYAH_URL = "https://everyayah.com/data/Alafasy_128kbps/001002.mp3"
REQUIRED_MODEL_FILES = (
    "config.json",
    "pytorch_model.bin",
    "vocab.json",
    "merges.txt",
    "preprocessor_config.json",
    "tokenizer_config.json",
)
ALLOW_PATTERNS = [
    "config.json",
    "pytorch_model.bin",
    "vocab.json",
    "merges.txt",
    "added_tokens.json",
    "normalizer.json",
    "preprocessor_config.json",
    "tokenizer_config.json",
    "special_tokens_map.json",
]


def _download_model(source_dir: Path, revision: str) -> None:
    from huggingface_hub import snapshot_download

    snapshot_download(
        repo_id=MODEL_ID,
        revision=revision,
        local_dir=source_dir,
        allow_patterns=ALLOW_PATTERNS,
    )
    missing = [name for name in REQUIRED_MODEL_FILES if not (source_dir / name).is_file()]
    if missing:
        raise FileNotFoundError(f"Model snapshot is missing required files: {', '.join(missing)}")


def _prepare_tokenizer(source_dir: Path) -> None:
    from transformers import WhisperTokenizerFast

    tokenizer = WhisperTokenizerFast.from_pretrained(source_dir, local_files_only=True)
    tokenizer.save_pretrained(source_dir)
    if not (source_dir / "tokenizer.json").is_file():
        raise FileNotFoundError("Fast tokenizer did not produce tokenizer.json")


def _convert(source_dir: Path, output_dir: Path, force: bool) -> None:
    name = "ct2-transformers-converter"
    executable = shutil.which(name) or str(Path(sys.executable).with_name(name))
    if not Path(executable).is_file():
        raise RuntimeError(
            "ct2-transformers-converter is missing; install the model-conversion extra"
        )
    output_dir.parent.mkdir(parents=True, exist_ok=True)
    if output_dir.exists() and not force:
        raise FileExistsError(
            f"Conversion output already exists: {output_dir} (use --force to replace it)"
        )
    command = [
        executable,
        "--model",
        str(source_dir),
        "--output_dir",
        str(output_dir),
        "--quantization",
        "int8",
        "--copy_files",
        "tokenizer.json",
        "preprocessor_config.json",
    ]
    if force:
        command.append("--force")
    subprocess.run(command, check=True)


def _load_faster_whisper(model_dir: Path) -> Any:
    from faster_whisper import WhisperModel

    return WhisperModel(str(model_dir), device="cpu", compute_type="int8", cpu_threads=2)


def verify_transcription(model_dir: Path, audio_url: str = EVERYAYAH_URL) -> tuple[str, float]:
    from app.matching.normalize import normalize_ar
    from rapidfuzz.fuzz import ratio

    model = _load_faster_whisper(model_dir)
    request = urllib.request.Request(
        audio_url, headers={"User-Agent": "HafidzAppModelConversion/0.1"}
    )
    with tempfile.TemporaryDirectory(prefix="hafidz-model-audio-") as directory:
        audio_path = Path(directory) / "001002.mp3"
        with (
            urllib.request.urlopen(request, timeout=30) as response,
            audio_path.open("wb") as target,
        ):
            shutil.copyfileobj(response, target)
        segments, _ = model.transcribe(
            str(audio_path),
            language="ar",
            task="transcribe",
            beam_size=5,
            temperature=0.0,
            condition_on_previous_text=False,
            without_timestamps=True,
            vad_filter=False,
        )
        transcript = " ".join(segment.text.strip() for segment in segments).strip()
    score = float(ratio(normalize_ar(transcript), normalize_ar("الحمد لله رب العالمين")))
    if score < 90.0:
        raise RuntimeError(
            "Reference transcription score did not meet the 90.0 threshold: "
            f"score={score:.2f}, transcript={transcript!r}"
        )
    return transcript, score


def convert(
    source_dir: Path = SOURCE_DIR,
    output_dir: Path = OUTPUT_DIR,
    revision: str = MODEL_REVISION,
    force: bool = False,
    verify_audio: bool = False,
) -> None:
    _download_model(source_dir, revision)
    _prepare_tokenizer(source_dir)
    _convert(source_dir, output_dir, force)
    _load_faster_whisper(output_dir)
    print(f"Converted {MODEL_ID}@{revision} to {output_dir}")
    if verify_audio:
        transcript, score = verify_transcription(output_dir)
        print(f"EveryAyah 001002 transcript: {transcript}")
        print(f"Normalized reference similarity: {score:.2f}%")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=SOURCE_DIR)
    parser.add_argument("--output-dir", type=Path, default=OUTPUT_DIR)
    parser.add_argument("--revision", default=MODEL_REVISION)
    parser.add_argument("--force", action="store_true", help="replace an existing converted model")
    parser.add_argument(
        "--verify-audio",
        action="store_true",
        help=(
            "transcribe EveryAyah Alafasy 001002.mp3 and enforce a 90-percent normalized "
            "similarity score"
        ),
    )
    args = parser.parse_args()
    convert(args.source_dir, args.output_dir, args.revision, args.force, args.verify_audio)


if __name__ == "__main__":
    main()
