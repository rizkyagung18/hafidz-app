"""Verify the bundled database against its pinned source snapshots and schema."""

from __future__ import annotations

import hashlib
import json
import sqlite3
from pathlib import Path
from typing import Any

from build import (
    OUTPUT,
    SIDECAR,
    BuildError,
    _load_all_payloads,
    _parse_tanzil_text,
    _read_lock,
    load_sources,
    normalize_ar,
    sha256_bytes,
)


def _require(condition: bool, message: str) -> None:
    if not condition:
        raise BuildError(message)


def _meta(connection: sqlite3.Connection) -> dict[str, str]:
    return dict(connection.execute("SELECT key, value FROM meta"))


def verify() -> list[str]:
    _require(OUTPUT.is_file(), f"Database does not exist: {OUTPUT}")
    _require(SIDECAR.is_file(), f"Database checksum sidecar does not exist: {SIDECAR}")
    sources = load_sources(offline=True)
    lock = _read_lock()
    data = _load_all_payloads(sources)
    passed: list[str] = []

    source_hashes = {
        name: sha256_bytes(content) for name, content in sources["files"].items()
    }
    from build import SOURCE_DEFINITIONS, aggregate_digest

    for name, group in sources["groups"].items():
        definition = SOURCE_DEFINITIONS[name]
        source_hashes[name] = aggregate_digest(
            [
                (definition["file"].format(surah=surah), content)
                for surah, content in group.items()
            ]
        )
    _require(
        all(lock["sources"][name]["sha256"] == digest for name, digest in source_hashes.items()),
        "One or more cached source hashes differ from sources.lock.json",
    )
    passed.append("Pinned upstream source hashes match the cached files")

    database_hash = sha256_bytes(OUTPUT.read_bytes())
    sidecar_hash = SIDECAR.read_text(encoding="utf-8").split()[0]
    _require(database_hash == sidecar_hash, "Database file does not match its SHA-256 sidecar")

    connection = sqlite3.connect(f"file:{OUTPUT}?mode=ro", uri=True)
    connection.row_factory = sqlite3.Row
    try:
        _require(connection.execute("PRAGMA integrity_check").fetchone()[0] == "ok", "SQLite integrity check failed")
        _require(not list(connection.execute("PRAGMA foreign_key_check")), "Foreign-key check failed")

        meta = _meta(connection)
        _require(meta.get("db_version") == "1", "Unexpected database schema version")
        _require(meta.get("tanzil_version") == lock["tanzil_text_version"], "Tanzil version metadata mismatch")
        source_fingerprint = hashlib.sha256(
            json.dumps(source_hashes, sort_keys=True, separators=(",", ":")).encode("utf-8")
        ).hexdigest()
        _require(meta.get("sha256") == source_fingerprint, "Source fingerprint metadata mismatch")
        sources_json: dict[str, Any] = json.loads(meta["sources_json"])
        _require(sources_json["sources"] == lock["sources"], "Database source manifest differs from lockfile")

        counts = {
            "surah": int(connection.execute("SELECT COUNT(*) FROM surah").fetchone()[0]),
            "ayah": int(connection.execute("SELECT COUNT(*) FROM ayah").fetchone()[0]),
            "page": int(connection.execute("SELECT COUNT(*) FROM page").fetchone()[0]),
            "juz": int(connection.execute("SELECT COUNT(*) FROM juz").fetchone()[0]),
            "tafsir": int(connection.execute("SELECT COUNT(*) FROM tafsir").fetchone()[0]),
        }
        _require(counts["surah"] == 114, f"Expected 114 surahs; got {counts['surah']}")
        _require(counts["ayah"] == 6236, f"Expected 6,236 ayahs; got {counts['ayah']}")
        _require(counts["page"] == 604, f"Expected 604 pages; got {counts['page']}")
        _require(counts["juz"] == 30, f"Expected 30 juz; got {counts['juz']}")
        _require(counts["tafsir"] == 6236, f"Expected 6,236 tafsir rows; got {counts['tafsir']}")
        _require(
            connection.execute("SELECT MIN(id), MAX(id) FROM ayah").fetchone()[:] == (1, 6236),
            "Global ayah IDs are not contiguous from 1 to 6,236",
        )
        _require(
            connection.execute("SELECT SUM(ayah_count) FROM surah").fetchone()[0] == 6236,
            "Surah ayah counts do not sum to 6,236",
        )
        _require(
            not list(
                connection.execute(
                    "SELECT number FROM surah s WHERE ayah_count != "
                    "(SELECT COUNT(*) FROM ayah a WHERE a.surah=s.number)"
                )
            ),
            "A surah's stored ayah count does not match its ayah rows",
        )
        _require(
            connection.execute("SELECT MAX(page), MAX(juz) FROM ayah").fetchone()[:] == (604, 30),
            "Page or juz range does not reach expected maximum",
        )
        passed.append("Database counts, IDs, and schema invariants are valid")

        tanzil_uthmani = _parse_tanzil_text(sources["files"]["tanzil_uthmani"], "Tanzil Uthmani")
        tanzil_simple = _parse_tanzil_text(sources["files"]["tanzil_simple_clean"], "Tanzil Simple Clean")
        cloud_ayahs = {
            int(ayah["number"]): ayah
            for surah in data["cloud_surahs"]
            for ayah in surah["ayahs"]
        }
        for row in connection.execute(
            "SELECT id, surah, ayah, page, juz, hizb_quarter, text_uthmani, text_simple, text_norm "
            "FROM ayah ORDER BY id"
        ):
            key = (int(row["surah"]), int(row["ayah"]))
            _require(row["text_uthmani"] == tanzil_uthmani[key], f"Uthmani text changed at {key}")
            _require(row["text_simple"] == tanzil_simple[key], f"Simple text changed at {key}")
            _require(row["text_norm"] == normalize_ar(row["text_simple"]), f"Search normalization mismatch at {key}")
            cloud = cloud_ayahs[int(row["id"])]
            _require(int(row["page"]) == int(cloud["page"]), f"AlQuran.cloud page mismatch at {key}")
            _require(int(row["juz"]) == int(cloud["juz"]), f"AlQuran.cloud juz mismatch at {key}")
            _require(
                int(row["hizb_quarter"]) == int(cloud["hizbQuarter"]),
                f"AlQuran.cloud hizb-quarter mismatch at {key}",
            )
        passed.append("Display texts are byte-identical to Tanzil sources; metadata matches AlQuran.cloud")

        spot_checks = {
            (2, 255): (42, 3),
            (1, 1): (1, 1),
            (114, 6): (604, 30),
            (18, 1): (293, 15),
        }
        for (surah, ayah), expected in spot_checks.items():
            result = connection.execute(
                "SELECT page, juz FROM ayah WHERE surah=? AND ayah=?", (surah, ayah)
            ).fetchone()
            _require(result is not None and tuple(result) == expected, f"Spot check failed: {surah}:{ayah}")
        page_42 = connection.execute("SELECT first_ayah, last_ayah FROM page WHERE number=42").fetchone()
        _require(page_42 is not None, "Missing page 42 boundary")
        _require(
            connection.execute("SELECT COUNT(*) FROM ayah_fts WHERE ayah_fts MATCH 'الحمد'").fetchone()[0] > 0,
            "FTS index did not return an expected Arabic search term",
        )
        passed.append("Madani page, juz, spot checks, and Arabic FTS search are valid")
    finally:
        connection.close()

    size = OUTPUT.stat().st_size
    _require(size <= 25 * 1024 * 1024, f"Database exceeds the 25 MiB target: {size:,} bytes")
    passed.append(f"Database size is within the 25 MiB target ({size:,} bytes)")
    return passed


def main() -> None:
    try:
        for item in verify():
            print(f"PASS  {item}")
    except (BuildError, OSError, sqlite3.Error, KeyError, ValueError) as error:
        raise SystemExit(f"Database verification failed: {error}") from error


if __name__ == "__main__":
    main()
