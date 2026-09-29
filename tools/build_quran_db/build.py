"""Build the bundled, read-only Qur'an content database from locked sources."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import random
import re
import sqlite3
import sys
import time
import urllib.error
import urllib.request
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
API_ROOT = ROOT / "services/api"
if str(API_ROOT) not in sys.path:
    sys.path.insert(0, str(API_ROOT))

CACHE = HERE / ".cache"
LOCK_PATH = HERE / "sources.lock.json"
OUTPUT = ROOT / "apps/mobile/assets/db/quran.sqlite"
SIDECAR = OUTPUT.with_suffix(".sqlite.sha256")
USER_AGENT = "HafidzAppQuranDatabaseBuilder/0.1"


def normalize_ar(text: str) -> str:
    """Use the API's canonical search normalizer while building the bundled index."""
    from app.matching.normalize import normalize_ar as normalize

    return normalize(text)

SOURCE_DEFINITIONS: dict[str, dict[str, str]] = {
    "tanzil_uthmani": {
        "url": "https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true&marks=true&sajdah=true&rub=true&tatweel=true",
        "file": "tanzil-uthmani.txt",
    },
    "tanzil_simple_clean": {
        "url": "https://tanzil.net/pub/download/index.php?quranType=simple-clean&outType=txt-2&agree=true&marks=false&sajdah=false&rub=false&tatweel=false",
        "file": "tanzil-simple-clean.txt",
    },
    "tanzil_metadata": {
        "url": "https://tanzil.net/res/text/metadata/quran-data.xml",
        "file": "tanzil-quran-data.xml",
    },
    "alquran_cloud": {
        "url": "https://api.alquran.cloud/v1/quran/quran-uthmani",
        "file": "alquran-cloud-quran-uthmani.json",
    },
    "equran_details": {
        "url": "https://equran.id/api/v2/surat/{surah}",
        "file": "equran-detail-{surah:03d}.json",
    },
    "equran_tafsir": {
        "url": "https://equran.id/api/v2/tafsir/{surah}",
        "file": "equran-tafsir-{surah:03d}.json",
    },
}

_TAG = re.compile(r"<(sura|page|juz|sajda)\s+([^>]*?)/>")
_ATTRIBUTE = re.compile(r'([A-Za-z]+)="([^"]*)"')


class BuildError(RuntimeError):
    """Raised when a source or invariant prevents a safe database build."""


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def aggregate_digest(files: list[tuple[str, bytes]]) -> str:
    digest = hashlib.sha256()
    for name, content in sorted(files):
        digest.update(name.encode("utf-8"))
        digest.update(b"\0")
        digest.update(content)
        digest.update(b"\0")
    return digest.hexdigest()


def _fetch(url: str) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=10) as response:
                body = response.read()
            time.sleep(0.08)
            return body
        except urllib.error.HTTPError as error:
            if error.code not in {429, 500, 502, 503, 504} or attempt == 2:
                raise BuildError(f"Source returned HTTP {error.code}: {url}") from error
        except (TimeoutError, urllib.error.URLError) as error:
            if attempt == 2:
                raise BuildError(f"Could not download source: {url} ({error})") from error
        time.sleep((0.4 * (2**attempt)) + random.uniform(0, 0.2))
    raise BuildError(f"Could not download source: {url}")


def _read_lock() -> dict[str, Any]:
    if not LOCK_PATH.exists():
        raise BuildError(f"Missing source lock: {LOCK_PATH}")
    return json.loads(LOCK_PATH.read_text(encoding="utf-8"))


def _load_file(name: str, definition: dict[str, str], refresh: bool, offline: bool) -> bytes:
    CACHE.mkdir(parents=True, exist_ok=True)
    path = CACHE / definition["file"]
    if refresh or not path.exists():
        if offline:
            raise BuildError(f"Required cached source is missing: {path}")
        data = _fetch(definition["url"])
        path.write_bytes(data)
    else:
        data = path.read_bytes()

    lock = _read_lock()
    expected = lock.get("sources", {}).get(name, {}).get("sha256")
    if not refresh and not expected:
        raise BuildError(
            f"Source {name} has no pinned SHA-256. Review sources, then run build.py --update-lock."
        )
    if not refresh and expected != sha256_bytes(data):
        raise BuildError(
            f"SHA-256 changed for {name}; inspect the upstream change before using --update-lock."
        )
    return data


def _load_equran_group(
    name: str, definition: dict[str, str], refresh: bool, offline: bool
) -> dict[int, bytes]:
    CACHE.mkdir(parents=True, exist_ok=True)
    files: dict[int, bytes] = {}
    for surah in range(1, 115):
        filename = definition["file"].format(surah=surah)
        path = CACHE / filename
        if refresh or not path.exists():
            if offline:
                raise BuildError(f"Required cached source is missing: {path}")
            path.write_bytes(_fetch(definition["url"].format(surah=surah)))
        files[surah] = path.read_bytes()

    lock = _read_lock()
    expected = lock.get("sources", {}).get(name, {}).get("sha256")
    actual = aggregate_digest(
        [(definition["file"].format(surah=surah), content) for surah, content in files.items()]
    )
    if not refresh and not expected:
        raise BuildError(
            f"Source {name} has no pinned SHA-256. Review sources, then run build.py --update-lock."
        )
    if not refresh and expected != actual:
        raise BuildError(
            f"SHA-256 changed for {name}; inspect the upstream change before using --update-lock."
        )
    return files


def load_sources(refresh: bool = False, offline: bool = False) -> dict[str, Any]:
    files: dict[str, bytes] = {}
    groups: dict[str, dict[int, bytes]] = {}
    for name in ("tanzil_uthmani", "tanzil_simple_clean", "tanzil_metadata", "alquran_cloud"):
        files[name] = _load_file(name, SOURCE_DEFINITIONS[name], refresh, offline)
    for name in ("equran_details", "equran_tafsir"):
        groups[name] = _load_equran_group(name, SOURCE_DEFINITIONS[name], refresh, offline)
    return {"files": files, "groups": groups}


def _source_hashes(sources: dict[str, Any]) -> dict[str, str]:
    hashes = {
        name: sha256_bytes(content) for name, content in sources["files"].items()
    }
    for name, group in sources["groups"].items():
        definition = SOURCE_DEFINITIONS[name]
        hashes[name] = aggregate_digest(
            [
                (definition["file"].format(surah=surah), content)
                for surah, content in group.items()
            ]
        )
    return hashes


def _update_lock(sources: dict[str, Any]) -> dict[str, Any]:
    previous = _read_lock()
    source_hashes = _source_hashes(sources)
    definitions: dict[str, dict[str, str]] = {}
    for name, definition in SOURCE_DEFINITIONS.items():
        definitions[name] = {
            "url": definition["url"],
            "sha256": source_hashes[name],
        }
    lock = {
        "schema_version": 1,
        "snapshot_date": datetime.now(tz=UTC).date().isoformat(),
        "tanzil_text_version": "1.1",
        "sources": definitions,
    }
    LOCK_PATH.write_text(json.dumps(lock, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if previous.get("sources") != definitions:
        print("Updated source pins in tools/build_quran_db/sources.lock.json")
    return lock


def _json_payload(raw: bytes, label: str) -> dict[str, Any]:
    try:
        payload = json.loads(raw.decode("utf-8-sig"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise BuildError(f"Invalid JSON from {label}: {error}") from error
    if not isinstance(payload, dict) or payload.get("code") != 200:
        raise BuildError(f"Unexpected API response from {label}")
    return payload


def _parse_tanzil_text(raw: bytes, label: str) -> dict[tuple[int, int], str]:
    verses: dict[tuple[int, int], str] = {}
    for line_number, line in enumerate(raw.decode("utf-8-sig").splitlines(), start=1):
        if not line or line.startswith("#"):
            continue
        parts = line.split("|", 2)
        if len(parts) != 3:
            raise BuildError(f"Malformed {label} line {line_number}")
        try:
            key = (int(parts[0]), int(parts[1]))
        except ValueError as error:
            raise BuildError(f"Malformed verse key in {label} line {line_number}") from error
        if key in verses or not parts[2]:
            raise BuildError(f"Duplicate or empty verse in {label}: {key}")
        verses[key] = parts[2]
    if len(verses) != 6236:
        raise BuildError(f"Expected 6,236 verses in {label}; got {len(verses)}")
    return verses


def _parse_tanzil_metadata(raw: bytes) -> dict[str, Any]:
    """Parse Tanzil's small, pinned metadata XML without external dependencies."""
    text = raw.decode("utf-8-sig")
    blocks: dict[str, list[dict[str, str]]] = {
        "sura": [],
        "page": [],
        "juz": [],
        "sajda": [],
    }
    for match in _TAG.finditer(text):
        tag = match.group(1)
        attributes = {key: html.unescape(value) for key, value in _ATTRIBUTE.findall(match.group(2))}
        blocks[tag].append(attributes)
    if len(blocks["sura"]) != 114 or len(blocks["page"]) != 604 or len(blocks["juz"]) != 30:
        raise BuildError("Tanzil metadata is missing surah, page, or juz boundaries")
    return blocks


def _key_to_global(key: tuple[int, int], surah_offsets: dict[int, int]) -> int:
    return surah_offsets[key[0]] + key[1]


def _reference_map(
    starts: list[dict[str, str]], surah_offsets: dict[int, int], count: int
) -> list[int]:
    boundaries = sorted(
        (_key_to_global((int(item["sura"]), int(item["aya"])), surah_offsets), int(item["index"]))
        for item in starts
    )
    values = [0] * (count + 1)
    current = 0
    position = 0
    for global_id in range(1, count + 1):
        while position < len(boundaries) and boundaries[position][0] == global_id:
            current = boundaries[position][1]
            position += 1
        if current == 0:
            raise BuildError(f"No Tanzil metadata boundary for global ayah {global_id}")
        values[global_id] = current
    return values


def _load_all_payloads(sources: dict[str, Any]) -> dict[str, Any]:
    files = sources["files"]
    tanzil_uthmani = _parse_tanzil_text(files["tanzil_uthmani"], "Tanzil Uthmani")
    tanzil_simple = _parse_tanzil_text(files["tanzil_simple_clean"], "Tanzil Simple Clean")
    metadata = _parse_tanzil_metadata(files["tanzil_metadata"])
    cloud_wrapper = json.loads(files["alquran_cloud"].decode("utf-8-sig"))
    if cloud_wrapper.get("code") != 200 or cloud_wrapper.get("status") != "OK":
        raise BuildError("Unexpected AlQuran.cloud response")
    cloud_surahs = cloud_wrapper["data"]["surahs"]
    if len(cloud_surahs) != 114:
        raise BuildError(f"Expected 114 AlQuran.cloud surahs; got {len(cloud_surahs)}")

    details: dict[int, dict[str, Any]] = {}
    tafsir: dict[int, dict[str, Any]] = {}
    for surah in range(1, 115):
        details[surah] = _json_payload(
            sources["groups"]["equran_details"][surah], f"EQuran details for surah {surah}"
        )["data"]
        tafsir[surah] = _json_payload(
            sources["groups"]["equran_tafsir"][surah], f"EQuran tafsir for surah {surah}"
        )["data"]
    return {
        "tanzil_uthmani": tanzil_uthmani,
        "tanzil_simple": tanzil_simple,
        "tanzil_metadata": metadata,
        "cloud_surahs": cloud_surahs,
        "equran_details": details,
        "equran_tafsir": tafsir,
    }


def _schema(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        PRAGMA foreign_keys = ON;
        PRAGMA journal_mode = DELETE;
        PRAGMA page_size = 4096;
        PRAGMA user_version = 1;
        CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
        CREATE TABLE surah (
          number INTEGER PRIMARY KEY,
          name_arabic TEXT NOT NULL,
          name_latin TEXT NOT NULL,
          translation_id TEXT NOT NULL,
          translation_en TEXT NOT NULL,
          ayah_count INTEGER NOT NULL,
          revelation_place TEXT NOT NULL CHECK (revelation_place IN ('makkah','madinah')),
          revelation_order INTEGER,
          first_page INTEGER NOT NULL,
          bismillah_pre INTEGER NOT NULL DEFAULT 1
        );
        CREATE TABLE ayah (
          id INTEGER PRIMARY KEY,
          surah INTEGER NOT NULL REFERENCES surah(number),
          ayah INTEGER NOT NULL,
          page INTEGER NOT NULL,
          juz INTEGER NOT NULL,
          hizb_quarter INTEGER NOT NULL,
          ruku INTEGER,
          manzil INTEGER,
          sajda INTEGER NOT NULL DEFAULT 0,
          text_uthmani TEXT NOT NULL,
          text_simple TEXT NOT NULL,
          text_norm TEXT NOT NULL,
          text_latin TEXT,
          translation_id TEXT NOT NULL,
          translation_en TEXT,
          UNIQUE (surah, ayah)
        );
        CREATE INDEX ix_ayah_page ON ayah(page);
        CREATE INDEX ix_ayah_juz ON ayah(juz);
        CREATE TABLE tafsir (
          ayah_id INTEGER NOT NULL REFERENCES ayah(id),
          source TEXT NOT NULL,
          text TEXT NOT NULL,
          PRIMARY KEY (ayah_id, source)
        );
        CREATE TABLE page (
          number INTEGER PRIMARY KEY,
          first_ayah INTEGER NOT NULL REFERENCES ayah(id),
          last_ayah INTEGER NOT NULL REFERENCES ayah(id),
          juz INTEGER NOT NULL
        );
        CREATE TABLE juz (
          number INTEGER PRIMARY KEY,
          first_ayah INTEGER NOT NULL,
          last_ayah INTEGER NOT NULL
        );
        CREATE TABLE doa (
          id INTEGER PRIMARY KEY, grup TEXT, nama TEXT, ar TEXT, tr TEXT,
          idn TEXT, tentang TEXT, tags TEXT
        );
        CREATE TABLE asmaul_husna (
          number INTEGER PRIMARY KEY, arabic TEXT, latin TEXT,
          meaning_id TEXT, meaning_en TEXT
        );
        CREATE TABLE prayer_location (
          id TEXT PRIMARY KEY, name TEXT NOT NULL, province TEXT NOT NULL,
          lat REAL NOT NULL, lng REAL NOT NULL, tz TEXT NOT NULL, myquran_id TEXT
        );
        CREATE VIRTUAL TABLE ayah_fts USING fts5(
          text_norm, translation_id, translation_en,
          content='ayah', content_rowid='id', tokenize='unicode61 remove_diacritics 2'
        );
        """
    )


def build_database(sources: dict[str, Any], lock: dict[str, Any]) -> Path:
    data = _load_all_payloads(sources)
    cloud_by_surah = {int(item["number"]): item for item in data["cloud_surahs"]}
    surah_offsets: dict[int, int] = {}
    offset = 0
    for surah in range(1, 115):
        surah_offsets[surah] = offset
        offset += len(cloud_by_surah[surah]["ayahs"])
    if offset != 6236:
        raise BuildError(f"Expected 6,236 total ayahs; AlQuran.cloud reports {offset}")

    reference_pages = _reference_map(data["tanzil_metadata"]["page"], surah_offsets, 6236)
    reference_juz = _reference_map(data["tanzil_metadata"]["juz"], surah_offsets, 6236)
    rows: list[tuple[Any, ...]] = []
    surah_rows: list[tuple[Any, ...]] = []
    tafsir_rows: list[tuple[Any, ...]] = []

    for surah_number in range(1, 115):
        cloud_surah = cloud_by_surah[surah_number]
        equran = data["equran_details"][surah_number]
        equran_tafsir = data["equran_tafsir"][surah_number]
        tanzil_surah = data["tanzil_metadata"]["sura"][surah_number - 1]
        cloud_ayahs = cloud_surah["ayahs"]
        equran_ayahs = equran.get("ayat", [])
        equran_tafsir_ayahs = equran_tafsir.get("tafsir", [])
        if len(cloud_ayahs) != len(equran_ayahs) or len(cloud_ayahs) != int(equran["jumlahAyat"]):
            raise BuildError(f"Ayah count mismatch for surah {surah_number}")
        if int(tanzil_surah["ayas"]) != len(cloud_ayahs):
            raise BuildError(f"Tanzil ayah count mismatch for surah {surah_number}")
        tafsir_by_ayah = {int(item["ayat"]): item["teks"] for item in equran_tafsir_ayahs}

        revelation = str(cloud_surah["revelationType"]).lower()
        revelation_place = "makkah" if revelation.startswith("mecc") else "madinah"
        first_page = int(cloud_ayahs[0]["page"])
        surah_rows.append(
            (
                surah_number,
                str(equran["nama"]),
                str(equran["namaLatin"]),
                str(equran["arti"]),
                str(tanzil_surah["ename"]),
                len(cloud_ayahs),
                revelation_place,
                int(tanzil_surah["order"]),
                first_page,
                0 if surah_number in {1, 9} else 1,
            )
        )

        for position, (cloud_ayah, equran_ayah) in enumerate(zip(cloud_ayahs, equran_ayahs, strict=True), 1):
            key = (surah_number, position)
            if key not in data["tanzil_uthmani"] or key not in data["tanzil_simple"]:
                raise BuildError(f"Tanzil text missing ayah {surah_number}:{position}")
            global_id = int(cloud_ayah["number"])
            page = int(cloud_ayah["page"])
            juz = int(cloud_ayah["juz"])
            hizb_quarter = int(cloud_ayah["hizbQuarter"])
            if page != reference_pages[global_id]:
                raise BuildError(f"Page metadata mismatch at {surah_number}:{position}")
            if juz != reference_juz[global_id]:
                raise BuildError(f"Juz metadata mismatch at {surah_number}:{position}")
            if not 1 <= hizb_quarter <= 240:
                raise BuildError(f"Invalid hizb-quarter metadata at {surah_number}:{position}")
            sajda = cloud_ayah.get("sajda", False)
            rows.append(
                (
                    global_id,
                    surah_number,
                    position,
                    page,
                    juz,
                    hizb_quarter,
                    int(cloud_ayah["ruku"]) if cloud_ayah.get("ruku") is not None else None,
                    int(cloud_ayah["manzil"]) if cloud_ayah.get("manzil") is not None else None,
                    int(bool(sajda)),
                    data["tanzil_uthmani"][key],
                    data["tanzil_simple"][key],
                    normalize_ar(data["tanzil_simple"][key]),
                    str(equran_ayah.get("teksLatin") or ""),
                    str(equran_ayah["teksIndonesia"]),
                    None,
                )
            )
            if tafsir_by_ayah.get(position):
                tafsir_rows.append((global_id, "kemenag", str(tafsir_by_ayah[position])))

    if len(rows) != 6236:
        raise BuildError(f"Expected 6,236 built ayah rows; got {len(rows)}")
    if len(tafsir_rows) != 6236:
        raise BuildError(f"Expected 6,236 Kemenag tafsir rows; got {len(tafsir_rows)}")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    if OUTPUT.exists():
        OUTPUT.unlink()
    connection = sqlite3.connect(OUTPUT)
    try:
        _schema(connection)
        connection.executemany(
            "INSERT INTO surah VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", surah_rows
        )
        connection.executemany(
            "INSERT INTO ayah VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", rows
        )
        connection.executemany("INSERT INTO tafsir VALUES (?, ?, ?)", tafsir_rows)
        connection.execute("INSERT INTO ayah_fts(ayah_fts) VALUES ('rebuild')")

        for page_number in range(1, 605):
            page_rows = [row for row in rows if row[3] == page_number]
            if not page_rows:
                raise BuildError(f"No ayahs mapped to Madani page {page_number}")
            connection.execute(
                "INSERT INTO page VALUES (?, ?, ?, ?)",
                (page_number, page_rows[0][0], page_rows[-1][0], page_rows[0][4]),
            )
        for juz_number in range(1, 31):
            juz_rows = [row for row in rows if row[4] == juz_number]
            if not juz_rows:
                raise BuildError(f"No ayahs mapped to juz {juz_number}")
            connection.execute(
                "INSERT INTO juz VALUES (?, ?, ?)",
                (juz_number, juz_rows[0][0], juz_rows[-1][0]),
            )

        source_hashes = _source_hashes(sources)
        sources_json = json.dumps(
            {
                "sources": lock["sources"],
                "attribution": {
                    "quran_text": "Tanzil Project (tanzil.net)",
                    "indonesian_translation_and_tafsir": "Kemenag RI via EQuran.id",
                    "metadata": ["Tanzil Project", "AlQuran.cloud"],
                },
            },
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        fingerprint = sha256_bytes(
            json.dumps(source_hashes, sort_keys=True, separators=(",", ":")).encode("utf-8")
        )
        meta_rows = [
            ("db_version", "1"),
            ("built_at", f"{lock['snapshot_date']}T00:00:00Z"),
            ("tanzil_version", lock["tanzil_text_version"]),
            ("sources_json", sources_json),
            ("sha256", fingerprint),
        ]
        connection.executemany("INSERT INTO meta VALUES (?, ?)", meta_rows)
        connection.commit()
        connection.execute("VACUUM")
    finally:
        connection.close()

    artifact_hash = sha256_bytes(OUTPUT.read_bytes())
    SIDECAR.write_text(f"{artifact_hash}  {OUTPUT.name}\n", encoding="utf-8")
    print(f"Built {OUTPUT} ({OUTPUT.stat().st_size:,} bytes)")
    print(f"Source fingerprint: {fingerprint}")
    print(f"Database SHA-256: {artifact_hash}")
    return OUTPUT


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--update-lock",
        action="store_true",
        help="Refresh all upstream snapshots and their pinned SHA-256 values after review.",
    )
    args = parser.parse_args()
    try:
        sources = load_sources(refresh=args.update_lock)
        if args.update_lock:
            lock = _update_lock(sources)
        else:
            lock = _read_lock()
        build_database(sources, lock)
    except (BuildError, OSError, sqlite3.Error, KeyError, ValueError) as error:
        raise SystemExit(f"Database build failed: {error}") from error


if __name__ == "__main__":
    main()
