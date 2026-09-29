"""Build and validate the deterministic Quran retrieval index from quran.sqlite."""

from __future__ import annotations

import hashlib
import math
import os
import pickle
import sqlite3
import sys
import tempfile
import time
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
API_ROOT = ROOT / "services/api"
if str(API_ROOT) not in sys.path:
    sys.path.insert(0, str(API_ROOT))

from app.matching.normalize import normalize_ar  # noqa: E402

DATABASE = ROOT / "apps/mobile/assets/db/quran.sqlite"
OUTPUT = ROOT / "services/api/data/quran_index.pkl"
SIDECAR = OUTPUT.with_suffix(".sha256")
MAX_BYTES = 30 * 1024 * 1024
EXPECTED_AYAH_COUNT = 6236

# The reading aliases are retrieval-only; Quran display text always remains source-exact.
MUQATTAAT_ALIASES: dict[tuple[int, int, int], str] = {
    (2, 1, 1): "الف لام ميم",
    (3, 1, 1): "الف لام ميم",
    (7, 1, 1): "الف لام ميم صاد",
    (10, 1, 1): "الف لام را",
    (11, 1, 1): "الف لام را",
    (12, 1, 1): "الف لام را",
    (13, 1, 1): "الف لام ميم را",
    (14, 1, 1): "الف لام را",
    (15, 1, 1): "الف لام را",
    (19, 1, 1): "كاف ها يا عين صاد",
    (20, 1, 1): "طا ها",
    (26, 1, 1): "طا سين ميم",
    (27, 1, 1): "طا سين",
    (28, 1, 1): "طا سين ميم",
    (29, 1, 1): "الف لام ميم",
    (30, 1, 1): "الف لام ميم",
    (31, 1, 1): "الف لام ميم",
    (32, 1, 1): "الف لام ميم",
    (36, 1, 1): "يا سين",
    (38, 1, 1): "صاد",
    (40, 1, 1): "حا ميم",
    (41, 1, 1): "حا ميم",
    (42, 1, 1): "حا ميم",
    (42, 2, 2): "عين سين قاف",
    (42, 1, 2): "حا ميم عين سين قاف",
    (43, 1, 1): "حا ميم",
    (44, 1, 1): "حا ميم",
    (45, 1, 1): "حا ميم",
    (46, 1, 1): "حا ميم",
    (50, 1, 1): "قاف",
    (68, 1, 1): "نون",
}


def _read_ayahs(database: Path) -> tuple[list[dict[str, Any]], str]:
    if not database.is_file():
        raise FileNotFoundError(f"Quran database does not exist: {database}")
    database_hash = hashlib.sha256(database.read_bytes()).hexdigest()
    connection = sqlite3.connect(f"file:{database}?mode=ro", uri=True)
    connection.row_factory = sqlite3.Row
    try:
        rows = [
            dict(row)
            for row in connection.execute(
                "SELECT id, surah, ayah, text_uthmani, text_simple, text_norm "
                "FROM ayah ORDER BY id"
            )
        ]
    finally:
        connection.close()
    if len(rows) != EXPECTED_AYAH_COUNT:
        raise ValueError(f"Expected {EXPECTED_AYAH_COUNT:,} ayahs, found {len(rows):,}")
    return rows, database_hash


def _combine_texts(texts: list[str]) -> tuple[str, list[int]]:
    """Join normalized ayat and return each ayah's start offset plus the final end."""
    offsets: list[int] = []
    pieces: list[str] = []
    cursor = 0
    for text in texts:
        offsets.append(cursor)
        pieces.append(text)
        cursor += len(text) + 1
    combined = " ".join(pieces)
    offsets.append(len(combined))
    return combined, offsets


def _make_unit(
    ayahs: list[dict[str, Any]], unit_id: int, kind: str, alias: str | None = None
) -> dict[str, Any]:
    first = ayahs[0]
    last = ayahs[-1]
    if alias is None:
        text_a, offsets_a = _combine_texts(
            [normalize_ar(str(row["text_uthmani"])) for row in ayahs]
        )
        text_b, offsets_b = _combine_texts(
            [normalize_ar(str(row["text_simple"])) for row in ayahs]
        )
    else:
        text_a = normalize_ar(alias)
        text_b = text_a
        offsets_a = [0, len(text_a)]
        offsets_b = [0, len(text_b)]
    return {
        "unit_id": unit_id,
        "kind": kind,
        "surah": int(first["surah"]),
        "ayah_start": int(first["ayah"]),
        "ayah_end": int(last["ayah"]),
        "text_norm_A": text_a,
        "text_norm_B": text_b,
        "char_offsets_A": offsets_a,
        "char_offsets_B": offsets_b,
    }


def build_units(ayahs: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], dict[str, int]]:
    """Create all single-ayah, 2/3-ayah, and disconnected-letter alias units."""
    by_surah: dict[int, list[dict[str, Any]]] = defaultdict(list)
    for row in ayahs:
        by_surah[int(row["surah"])].append(row)

    units: list[dict[str, Any]] = []
    units.extend(_make_unit([row], len(units), "single") for row in ayahs)
    counts = {"single": len(units), "window_2": 0, "window_3": 0, "muqattaat_alias": 0}

    for window_size in (2, 3):
        kind = f"window_{window_size}"
        for surah in sorted(by_surah):
            verses = by_surah[surah]
            for start in range(len(verses) - window_size + 1):
                window = verses[start : start + window_size]
                units.append(_make_unit(window, len(units), kind))
                counts[kind] += 1

    for (surah, ayah_start, ayah_end), phrase in MUQATTAAT_ALIASES.items():
        if surah not in by_surah:
            continue
        verses = by_surah[surah]
        selected = [
            row for row in verses if ayah_start <= int(row["ayah"]) <= ayah_end
        ]
        if len(selected) != ayah_end - ayah_start + 1:
            raise ValueError(f"Muqatta'at alias range is absent: {surah}:{ayah_start}-{ayah_end}")
        units.append(_make_unit(selected, len(units), "muqattaat_alias", phrase))
        counts["muqattaat_alias"] += 1
    expected_window_2 = sum(max(0, len(verses) - 1) for verses in by_surah.values())
    expected_window_3 = sum(max(0, len(verses) - 2) for verses in by_surah.values())
    if counts["window_2"] != expected_window_2 or counts["window_3"] != expected_window_3:
        raise ValueError("2/3-ayah window counts do not match surah-local boundaries")
    return units, counts


def _build_word_index(units: list[dict[str, Any]]) -> tuple[dict[str, list[int]], dict[str, float]]:
    document_frequency: Counter[str] = Counter()
    word_to_units: dict[str, list[int]] = defaultdict(list)
    for unit in units:
        words = set(str(unit["text_norm_A"]).split()) | set(str(unit["text_norm_B"]).split())
        for word in sorted(words):
            document_frequency[word] += 1
            word_to_units[word].append(int(unit["unit_id"]))
    total_units = len(units)
    word_idf = {
        word: math.log((1 + total_units) / (1 + frequency)) + 1.0
        for word, frequency in document_frequency.items()
    }
    return dict(word_to_units), word_idf


def build_index(database: Path = DATABASE, output: Path = OUTPUT) -> dict[str, Any]:
    ayahs, database_hash = _read_ayahs(database)
    units, counts = build_units(ayahs)
    vectorizer = TfidfVectorizer(
        analyzer="char_wb",
        ngram_range=(3, 3),
        sublinear_tf=True,
        dtype=np.float32,
    )
    corpus = [f"{unit['text_norm_A']}\n{unit['text_norm_B']}" for unit in units]
    char_tfidf = vectorizer.fit_transform(corpus).tocsr()
    word_to_units, word_idf = _build_word_index(units)
    index: dict[str, Any] = {
        "schema_version": 1,
        "database_sha256": database_hash,
        "units": units,
        "counts": counts,
        "vectorizer": vectorizer,
        "char_tfidf": char_tfidf,
        "word_to_units": word_to_units,
        "word_idf": word_idf,
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        dir=output.parent, prefix=f".{output.name}.", delete=False
    ) as temp:
        temp_path = Path(temp.name)
        pickle.dump(index, temp, protocol=pickle.HIGHEST_PROTOCOL)
        temp.flush()
        os.fsync(temp.fileno())
    temp_path.chmod(0o644)
    temp_path.replace(output)
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    sidecar = output.with_suffix(".sha256")
    sidecar.write_text(f"{digest}  {output.name}\n", encoding="ascii")
    return index


def verify_index(
    output: Path = OUTPUT, expected_ayahs: int = EXPECTED_AYAH_COUNT
) -> tuple[dict[str, Any], float]:
    if not output.is_file():
        raise FileNotFoundError(f"Index does not exist: {output}")
    if output.stat().st_size > MAX_BYTES:
        raise ValueError(f"Index is larger than 30 MiB: {output.stat().st_size:,} bytes")
    sidecar = output.with_suffix(".sha256")
    if not sidecar.is_file():
        raise FileNotFoundError(f"Index checksum is missing: {sidecar}")
    expected_hash = sidecar.read_text(encoding="ascii").split()[0]
    actual_hash = hashlib.sha256(output.read_bytes()).hexdigest()
    if actual_hash != expected_hash:
        raise ValueError("Index checksum does not match the serialized index")

    started = time.perf_counter()
    with output.open("rb") as stream:
        index = pickle.load(stream)
    load_seconds = time.perf_counter() - started
    counts = index["counts"]
    if counts["single"] != expected_ayahs:
        raise ValueError(
            f"Expected {expected_ayahs:,} single-ayah units; found {counts['single']:,}"
        )
    if len(index["units"]) != sum(counts.values()):
        raise ValueError("Unit count does not match index metadata")
    if index["char_tfidf"].shape[0] != len(index["units"]):
        raise ValueError("TF-IDF rows do not match indexed units")
    if not index["word_to_units"] or not index["word_idf"]:
        raise ValueError("Word retrieval structures are empty")
    if load_seconds >= 1.0:
        raise ValueError(f"Index load took {load_seconds:.3f}s (limit: <1s)")
    return index, load_seconds


def main() -> None:
    built = build_index()
    verified, load_seconds = verify_index()
    print(f"Built {OUTPUT} ({OUTPUT.stat().st_size:,} bytes)")
    print(
        "Units: "
        f"{verified['counts']['single']:,} single, "
        f"{verified['counts']['window_2']:,} two-ayah, "
        f"{verified['counts']['window_3']:,} three-ayah, "
        f"{verified['counts']['muqattaat_alias']:,} muqatta'at aliases"
    )
    print(f"TF-IDF shape: {verified['char_tfidf'].shape}; load: {load_seconds:.3f}s")
    print(f"SHA-256: {hashlib.sha256(OUTPUT.read_bytes()).hexdigest()}")
    if built["database_sha256"] != verified["database_sha256"]:
        raise RuntimeError("Built and reloaded index source database fingerprints differ")


if __name__ == "__main__":
    main()
