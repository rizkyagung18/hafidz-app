"""Load and validate the prebuilt search index used by the voice matcher."""

from __future__ import annotations

import hashlib
import pickle
from pathlib import Path
from typing import Any

MAX_INDEX_BYTES = 30 * 1024 * 1024
EXPECTED_SINGLE_UNITS = 6_236


def load_index(path: Path) -> dict[str, Any]:
    """Load a generated index only after checking its size and SHA-256 sidecar."""
    if not path.is_file():
        raise FileNotFoundError(f"Quran search index not found: {path}")
    if path.stat().st_size > MAX_INDEX_BYTES:
        raise ValueError("Quran search index exceeds the 30 MiB size limit.")
    sidecar = path.with_suffix(".sha256")
    if not sidecar.is_file():
        raise FileNotFoundError(f"Quran search index checksum not found: {sidecar}")
    expected_hash = sidecar.read_text(encoding="ascii").split()[0]
    actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual_hash != expected_hash:
        raise ValueError("Quran search index checksum does not match.")

    with path.open("rb") as stream:
        index: dict[str, Any] = pickle.load(stream)
    counts = index.get("counts", {})
    units = index.get("units", [])
    if counts.get("single") != EXPECTED_SINGLE_UNITS:
        raise ValueError("Quran search index does not contain 6,236 single-ayah units.")
    if len(units) != sum(counts.values()):
        raise ValueError("Quran search index unit counts are inconsistent.")
    return index
