"""Build the local QUL-only Qur'an and 1405H print database (version 3).

The QUL archives are deliberately kept in the ignored local cache while their
resource-specific redistribution terms are unresolved. This builder never
downloads or falls back to another Qur'an provider.
"""

from __future__ import annotations

import hashlib
import json
import os
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any
from zipfile import ZipFile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
API_ROOT = ROOT / "services/api"
if str(API_ROOT) not in sys.path:
    sys.path.insert(0, str(API_ROOT))

from app.matching.normalize import normalize_ar  # noqa: E402

LOCK_PATH = HERE / "sources.lock.json"
PRINT_LOCK_PATH = HERE / "print_sources.lock.json"
OUTPUT = ROOT / "apps/mobile/assets/db/quran.sqlite"
SIDECAR = OUTPUT.with_suffix(".sqlite.sha256")
PRINT_ASSETS = ROOT / "apps/mobile/assets/mushaf"
EDITION = "madinah-1405h-qpc-v1"
EXPECTED_AYAT = 6236
EXPECTED_WORDS = 83668
SOURCE_DATABASES = {
    "uthmani", "imlaei_simple", "translation_id", "ayah_metadata",
    "surah_metadata", "juz_metadata", "hizb_metadata", "sajda_metadata",
    "layout_1405h", "word_glyphs_1405h",
}


class BuildError(RuntimeError):
    """A pinned source or the derived database violates a build invariant."""


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_lock() -> dict[str, Any]:
    lock = json.loads(LOCK_PATH.read_text(encoding="utf-8"))
    if lock.get("schema_version") != 2 or not SOURCE_DATABASES <= set(lock["sources"]):
        raise BuildError("QUL v2 source lock is missing required entries")
    return lock


def read_print_pack(lock: dict[str, Any]) -> tuple[dict[str, Any], dict[str, Any], str, list[tuple[Any, ...]]]:
    """Verify every local print input and staged asset before building content."""
    print_lock = json.loads(PRINT_LOCK_PATH.read_text(encoding="utf-8"))
    required = {"surah_header_font", "surah_name_v1_font", "surah_name_v2_font",
                "quran_common_font", "surah_header_ligatures"}
    if print_lock.get("schema_version") != 1 or set(print_lock.get("sources", {})) != required:
        raise BuildError("QUL print source lock is incomplete")
    combined = {**lock["sources"], **print_lock["sources"]}
    if len(combined) != len(lock["sources"]) + len(required):
        raise BuildError("Duplicate semantic and print source names")
    all_lock = {**lock, "sources": combined}
    for name in required:
        source_path(all_lock, name)

    manifest_path = PRINT_ASSETS / "manifest.json"
    raw = manifest_path.read_bytes()
    manifest = json.loads(raw)
    if (manifest.get("pack_version"), manifest.get("edition"), manifest.get("pages")) != (3, EDITION, 604):
        raise BuildError("Staged QUL print manifest has the wrong edition or version")
    expected_sources = {name: item["sha256"] for name, item in combined.items()}
    if manifest.get("source_sha256") != expected_sources:
        raise BuildError("Staged QUL print manifest uses a different source set")
    fonts = manifest.get("font_sha256")
    headers = manifest.get("header_png_sha256")
    if not isinstance(fonts, dict) or not isinstance(headers, dict):
        raise BuildError("Staged QUL print manifest lacks asset hashes")
    if set(fonts) != {*(f"p{page}.ttf" for page in range(1, 605)),
                      "quran-common.ttf", "surah_name_v1.ttf", "surah-name-v2.ttf",
                      "QCF_SurahHeader_COLOR-Regular.ttf"}:
        raise BuildError("Staged QUL print pack does not have exactly 604 page fonts and four auxiliary fonts")
    if set(headers) != {str(surah) for surah in range(1, 115)}:
        raise BuildError("Staged QUL print pack does not have 114 headers")
    assets: list[tuple[Any, ...]] = []
    for name, digest in sorted(fonts.items()):
        page = int(name[1:-4]) if name.startswith("p") and name[1:-4].isdigit() else None
        path = PRINT_ASSETS / "fonts" / name
        if sha256_bytes(path.read_bytes()) != digest:
            raise BuildError(f"Staged QUL font checksum mismatch: {name}")
        source = "page_fonts_1405h" if page is not None else {
            "quran-common.ttf": "quran_common_font",
            "surah_name_v1.ttf": "surah_name_v1_font",
            "surah-name-v2.ttf": "surah_name_v2_font",
            "QCF_SurahHeader_COLOR-Regular.ttf": "surah_header_font",
        }[name]
        assets.append((EDITION, f"font:{name}", "font", page, f"fonts/{name}",
                       digest, path.stat().st_size, source, "unverified"))
    for number, digest in sorted(headers.items(), key=lambda item: int(item[0])):
        path = PRINT_ASSETS / "headers" / f"{number}.png"
        if sha256_bytes(path.read_bytes()) != digest:
            raise BuildError(f"Staged QUL header checksum mismatch: {number}")
        assets.append((EDITION, f"header:{number}", "header", None,
                       f"headers/{number}.png", digest, path.stat().st_size,
                       "surah_header_font", "unverified"))
    return print_lock, manifest, sha256_bytes(raw), assets


def source_path(lock: dict[str, Any], name: str) -> Path:
    item = lock["sources"][name]
    path = (HERE / item["path"]).resolve()
    if not path.is_relative_to(HERE / ".cache"):
        raise BuildError(f"Source {name} must be in the ignored local cache")
    if not path.is_file():
        raise BuildError(f"Missing QUL source {name}: {path}")
    if sha256_bytes(path.read_bytes()) != item["sha256"]:
        raise BuildError(f"Pinned SHA-256 mismatch for QUL source {name}")
    return path


def open_source(lock: dict[str, Any], name: str) -> sqlite3.Connection:
    path = source_path(lock, name)
    with ZipFile(path) as archive:
        names = [item.filename for item in archive.infolist() if not item.is_dir()]
        if len(names) != 1 or not names[0].endswith((".db", ".sqlite")):
            raise BuildError(f"Unexpected SQLite archive for {name}: {names}")
        raw = archive.read(names[0])
    connection = sqlite3.connect(":memory:")
    connection.deserialize(raw)
    connection.row_factory = sqlite3.Row
    return connection


def _key(surah: int, ayah: int) -> str:
    return f"{surah}:{ayah}"


def _verses(connection: sqlite3.Connection, label: str) -> dict[str, tuple[int, str]]:
    result: dict[str, tuple[int, str]] = {}
    for row in connection.execute("SELECT id, verse_key, surah, ayah, text FROM verses"):
        key = _key(row["surah"], row["ayah"])
        if row["verse_key"] != key or key in result or not row["text"]:
            raise BuildError(f"Invalid {label} verse key/text: {key}")
        result[key] = (int(row["id"]), str(row["text"]))
    if len(result) != EXPECTED_AYAT:
        raise BuildError(f"{label} has {len(result)} verses, expected {EXPECTED_AYAT}")
    return result


def _map_parts(connection: sqlite3.Connection, table: str, number: str) -> tuple[dict[str, int], list[tuple[int, str, str]]]:
    mapping: dict[str, int] = {}
    boundaries: list[tuple[int, str, str]] = []
    for row in connection.execute(f"SELECT * FROM {table} ORDER BY {number}"):
        group = int(row[number])
        keys: list[str] = []
        for surah, span in json.loads(row["verse_mapping"]).items():
            first, last = (int(part) for part in span.split("-", 1))
            if first < 1 or last < first:
                raise BuildError(f"Invalid {table} range {surah}:{span}")
            keys.extend(_key(int(surah), ayah) for ayah in range(first, last + 1))
        if len(keys) != row["verses_count"] or keys[0] != row["first_verse_key"] or keys[-1] != row["last_verse_key"]:
            raise BuildError(f"Invalid {table} boundary/count {group}")
        for key in keys:
            if key in mapping:
                raise BuildError(f"Overlapping {table} at {key}")
            mapping[key] = group
        boundaries.append((group, keys[0], keys[-1]))
    if len(mapping) != EXPECTED_AYAT:
        raise BuildError(f"{table} covers {len(mapping)} ayat, expected {EXPECTED_AYAT}")
    return mapping, boundaries


def _page_mapping(layout: sqlite3.Connection, glyphs: sqlite3.Connection) -> tuple[dict[str, int], dict[int, set[str]]]:
    words: dict[int, str] = {}
    for row in glyphs.execute("SELECT id, location, surah, ayah, word FROM words ORDER BY id"):
        wid = int(row["id"])
        if wid != len(words) + 1 or row["location"] != f'{row["surah"]}:{row["ayah"]}:{row["word"]}':
            raise BuildError(f"Invalid 1405H word identity at {wid}")
        words[wid] = _key(int(row["surah"]), int(row["ayah"]))
    if len(words) != EXPECTED_WORDS:
        raise BuildError(f"1405H word count {len(words)} != {EXPECTED_WORDS}")

    first_page: dict[str, int] = {}
    page_members: dict[int, set[str]] = defaultdict(set)
    previous_word = 0
    rows = layout.execute(
        "SELECT page_number, line_number, line_type, first_word_id, last_word_id "
        "FROM pages ORDER BY page_number, line_number"
    )
    page_lines: dict[int, int] = defaultdict(int)
    for row in rows:
        page = int(row["page_number"])
        page_lines[page] += 1
        if row["line_number"] != page_lines[page]:
            raise BuildError(f"Noncontiguous line number on page {page}")
        if row["line_type"] != "ayah":
            continue
        first, last = int(row["first_word_id"]), int(row["last_word_id"])
        if first != previous_word + 1 or last < first:
            raise BuildError(f"Word range breaks at page {page}, line {row['line_number']}")
        for wid in range(first, last + 1):
            key = words.get(wid)
            if key is None:
                raise BuildError(f"Missing word {wid} on page {page}")
            first_page.setdefault(key, page)
            page_members[page].add(key)
        previous_word = last
    if sorted(page_lines) != list(range(1, 605)) or previous_word != EXPECTED_WORDS:
        raise BuildError("1405H layout does not cover all pages and words")
    if len(first_page) != EXPECTED_AYAT:
        raise BuildError(f"1405H layout maps {len(first_page)} ayat, expected {EXPECTED_AYAT}")
    return first_page, page_members


SCHEMA = """
PRAGMA foreign_keys=ON;
PRAGMA page_size=4096;
PRAGMA user_version=3;
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE surah (
 number INTEGER PRIMARY KEY, name_arabic TEXT NOT NULL, name_latin TEXT NOT NULL,
 translation_id TEXT, translation_en TEXT, ayah_count INTEGER NOT NULL,
 revelation_place TEXT NOT NULL CHECK(revelation_place IN ('makkah','madinah')),
 revelation_order INTEGER, first_page INTEGER NOT NULL, bismillah_pre INTEGER NOT NULL DEFAULT 1
);
CREATE TABLE ayah (
 id INTEGER PRIMARY KEY, surah INTEGER NOT NULL REFERENCES surah(number), ayah INTEGER NOT NULL,
 page INTEGER NOT NULL, juz INTEGER NOT NULL, hizb_quarter INTEGER,
 ruku INTEGER, manzil INTEGER, sajda INTEGER NOT NULL DEFAULT 0,
 text_uthmani TEXT NOT NULL, text_simple TEXT NOT NULL, text_norm TEXT NOT NULL,
 text_latin TEXT, translation_id TEXT NOT NULL, translation_en TEXT,
 hizb INTEGER NOT NULL, UNIQUE(surah,ayah)
);
CREATE INDEX ix_ayah_page ON ayah(page);
CREATE INDEX ix_ayah_juz ON ayah(juz);
CREATE INDEX ix_ayah_hizb ON ayah(hizb);
CREATE TABLE tafsir (ayah_id INTEGER NOT NULL REFERENCES ayah(id), source TEXT NOT NULL,
 text TEXT NOT NULL, PRIMARY KEY(ayah_id,source));
CREATE TABLE page (number INTEGER PRIMARY KEY, first_ayah INTEGER NOT NULL REFERENCES ayah(id),
 last_ayah INTEGER NOT NULL REFERENCES ayah(id), juz INTEGER NOT NULL);
CREATE TABLE juz (number INTEGER PRIMARY KEY, first_ayah INTEGER NOT NULL,
 last_ayah INTEGER NOT NULL);
CREATE TABLE hizb (number INTEGER PRIMARY KEY, first_ayah INTEGER NOT NULL,
 last_ayah INTEGER NOT NULL);
CREATE VIRTUAL TABLE ayah_fts USING fts5(text_norm,translation_id,translation_en,
 content='ayah',content_rowid='id',tokenize='unicode61 remove_diacritics 2');
CREATE TABLE doa (id INTEGER PRIMARY KEY,grup TEXT,nama TEXT,ar TEXT,tr TEXT,idn TEXT,tentang TEXT,tags TEXT);
CREATE TABLE asmaul_husna (number INTEGER PRIMARY KEY,arabic TEXT,latin TEXT,meaning_id TEXT,meaning_en TEXT);
CREATE TABLE prayer_location (id TEXT PRIMARY KEY,name TEXT NOT NULL,province TEXT NOT NULL,
 lat REAL NOT NULL,lng REAL NOT NULL,tz TEXT NOT NULL,myquran_id TEXT);
CREATE TABLE mushaf_edition (
 id TEXT PRIMARY KEY, pack_version INTEGER NOT NULL, page_count INTEGER NOT NULL,
 source_sha256 TEXT NOT NULL, manifest_sha256 TEXT NOT NULL,
 design_width REAL NOT NULL, word_font_size REAL NOT NULL
);
CREATE TABLE mushaf_asset (
 edition_id TEXT NOT NULL REFERENCES mushaf_edition(id), id TEXT NOT NULL,
 kind TEXT NOT NULL CHECK(kind IN ('font','header')), page INTEGER,
 path TEXT NOT NULL, sha256 TEXT NOT NULL, byte_size INTEGER NOT NULL,
 source_name TEXT NOT NULL, rights_status TEXT NOT NULL,
 PRIMARY KEY(edition_id,id), UNIQUE(edition_id,path)
);
CREATE TABLE mushaf_page (
 edition_id TEXT NOT NULL REFERENCES mushaf_edition(id), page INTEGER NOT NULL,
 font_asset_id TEXT NOT NULL, line_count INTEGER NOT NULL,
 PRIMARY KEY(edition_id,page),
 FOREIGN KEY(edition_id,font_asset_id) REFERENCES mushaf_asset(edition_id,id)
);
CREATE TABLE mushaf_line (
 edition_id TEXT NOT NULL, page INTEGER NOT NULL, line INTEGER NOT NULL,
 kind TEXT NOT NULL CHECK(kind IN ('ayah','surah_name','basmallah')),
 centered INTEGER NOT NULL CHECK(centered IN (0,1)), surah INTEGER,
 first_word_id INTEGER, last_word_id INTEGER,
 PRIMARY KEY(edition_id,page,line),
 FOREIGN KEY(edition_id,page) REFERENCES mushaf_page(edition_id,page)
);
CREATE TABLE mushaf_word (
 edition_id TEXT NOT NULL, id INTEGER NOT NULL, ayah_id INTEGER NOT NULL REFERENCES ayah(id),
 word_key TEXT NOT NULL, glyph TEXT NOT NULL, page INTEGER NOT NULL, line INTEGER NOT NULL,
 position INTEGER NOT NULL,
 PRIMARY KEY(edition_id,id), UNIQUE(edition_id,word_key),
 FOREIGN KEY(edition_id,page,line) REFERENCES mushaf_line(edition_id,page,line)
);
CREATE INDEX ix_mushaf_word_page_line ON mushaf_word(edition_id,page,line,position);
CREATE TABLE mushaf_ayah_page (
 edition_id TEXT NOT NULL, ayah_id INTEGER NOT NULL REFERENCES ayah(id), page INTEGER NOT NULL,
 first_line INTEGER NOT NULL, last_line INTEGER NOT NULL,
 first_word_id INTEGER NOT NULL, last_word_id INTEGER NOT NULL,
 PRIMARY KEY(edition_id,ayah_id,page),
 FOREIGN KEY(edition_id,page) REFERENCES mushaf_page(edition_id,page)
);
CREATE INDEX ix_mushaf_ayah_page_page ON mushaf_ayah_page(edition_id,page,ayah_id);
"""


def _insert_print_data(
    db: sqlite3.Connection,
    layout: sqlite3.Connection,
    glyphs: sqlite3.Connection,
    metadata: dict[str, int],
    assets: list[tuple[Any, ...]],
    source_digest: str,
    manifest_digest: str,
) -> None:
    db.execute("INSERT INTO mushaf_edition VALUES (?,?,?,?,?,?,?)",
               (EDITION, 3, 604, source_digest, manifest_digest, 660.0, 42.0))
    db.executemany("INSERT INTO mushaf_asset VALUES (?,?,?,?,?,?,?,?,?)", assets)
    words = {int(row["id"]): row for row in glyphs.execute(
        "SELECT id,location,surah,ayah,word,text FROM words ORDER BY id"
    )}
    if len(words) != EXPECTED_WORDS or sorted(words) != list(range(1, EXPECTED_WORDS + 1)):
        raise BuildError("QUL print word IDs must cover 1..83668")
    word_rows: list[tuple[Any, ...]] = []
    membership: dict[tuple[int, int], list[int]] = {}
    last_word = 0
    line_count = 0
    for page in range(1, 605):
        lines = list(layout.execute(
            "SELECT line_number,line_type,is_centered,first_word_id,last_word_id,surah_number "
            "FROM pages WHERE page_number=? ORDER BY line_number", (page,)
        ))
        if not lines or len(lines) not in (8, 15):
            raise BuildError(f"Unexpected line count on 1405H page {page}")
        db.execute("INSERT INTO mushaf_page VALUES (?,?,?,?)",
                   (EDITION, page, f"font:p{page}.ttf", len(lines)))
        for position, row in enumerate(lines, start=1):
            line = int(row["line_number"])
            kind = str(row["line_type"])
            if line != position or kind not in ("ayah", "surah_name", "basmallah"):
                raise BuildError(f"Invalid source line {page}:{line}")
            surah = int(row["surah_number"]) if row["surah_number"] not in (None, "") else None
            if kind == "surah_name" and (surah is None or not 1 <= surah <= 114):
                raise BuildError(f"Missing Surah heading identity on {page}:{line}")
            if kind != "surah_name" and surah is not None:
                raise BuildError(f"Unexpected Surah heading identity on {page}:{line}")
            first = int(row["first_word_id"]) if kind == "ayah" else None
            last = int(row["last_word_id"]) if kind == "ayah" else None
            if kind == "ayah" and (first != last_word + 1 or last is None or last < first):
                raise BuildError(f"Discontinuous QUL words on {page}:{line}")
            if kind != "ayah" and (row["first_word_id"] not in (None, "") or
                                   row["last_word_id"] not in (None, "")):
                raise BuildError(f"Decorative source line has word IDs on {page}:{line}")
            db.execute("INSERT INTO mushaf_line VALUES (?,?,?,?,?,?,?,?)",
                       (EDITION, page, line, kind, int(row["is_centered"]), surah, first, last))
            if first is not None and last is not None:
                for word_position, word_id in enumerate(range(first, last + 1), start=1):
                    word = words.get(word_id)
                    if word is None:
                        raise BuildError(f"Missing QUL glyph word {word_id}")
                    key = _key(int(word["surah"]), int(word["ayah"]))
                    expected_word_key = f'{key}:{word["word"]}'
                    if word["location"] != expected_word_key or key not in metadata or not word["text"]:
                        raise BuildError(f"Invalid QUL glyph identity at word {word_id}")
                    ayah_id = metadata[key]
                    word_rows.append((EDITION, word_id, ayah_id, expected_word_key,
                                      str(word["text"]), page, line, word_position))
                    segment = membership.setdefault((ayah_id, page), [line, line, word_id, word_id])
                    segment[1] = line
                    segment[3] = word_id
                last_word = last
            line_count += 1
    if last_word != EXPECTED_WORDS or len(word_rows) != EXPECTED_WORDS:
        raise BuildError("QUL print package has missing word glyphs")
    if {ayah_id for ayah_id, _ in membership} != set(metadata.values()):
        raise BuildError("QUL print package does not cover every canonical ayah")
    db.executemany("INSERT INTO mushaf_word VALUES (?,?,?,?,?,?,?,?)", word_rows)
    db.executemany("INSERT INTO mushaf_ayah_page VALUES (?,?,?,?,?,?,?)", (
        (EDITION, ayah_id, page, *segment)
        for (ayah_id, page), segment in sorted(membership.items())
    ))
    if line_count != layout.execute("SELECT COUNT(*) FROM pages").fetchone()[0]:
        raise BuildError("QUL print package dropped a source line")


def build_database(lock: dict[str, Any]) -> Path:
    # Verify *all* pinned archives, including the local-only fonts used by the later renderer.
    for name in lock["sources"]:
        source_path(lock, name)
    print_lock, manifest, manifest_digest, assets = read_print_pack(lock)
    sources = {name: open_source(lock, name) for name in SOURCE_DATABASES}
    try:
        uthmani = _verses(sources["uthmani"], "QUL Uthmani")
        imlaei = _verses(sources["imlaei_simple"], "QUL Imlaei Simple")
        translations: dict[str, str] = {}
        for row in sources["translation_id"].execute("SELECT sura,ayah,ayah_key,text FROM translation"):
            key = _key(int(row["sura"]), int(row["ayah"]))
            if key != row["ayah_key"] or key in translations or not row["text"]:
                raise BuildError(f"Invalid QUL Indonesian translation at {key}")
            translations[key] = str(row["text"])
        if set(uthmani) != set(imlaei) or set(uthmani) != set(translations):
            raise BuildError("QUL text/translation key sets do not match")

        metadata: dict[str, int] = {}
        for row in sources["ayah_metadata"].execute("SELECT id,surah_number,ayah_number,verse_key FROM verses"):
            key = _key(int(row["surah_number"]), int(row["ayah_number"]))
            if row["verse_key"] != key or key in metadata or key not in uthmani:
                raise BuildError(f"Invalid QUL ayah metadata at {key}")
            gid = int(row["id"])
            if uthmani[key][0] != gid or imlaei[key][0] != gid:
                raise BuildError(f"Global ayah ID mismatch at {key}")
            metadata[key] = gid
        if sorted(metadata.values()) != list(range(1, EXPECTED_AYAT + 1)):
            raise BuildError("Global ayah IDs are not contiguous 1..6236")

        juz_map, juz_bounds = _map_parts(sources["juz_metadata"], "juz", "juz_number")
        hizb_map, hizb_bounds = _map_parts(sources["hizb_metadata"], "hizbs", "hizb_number")
        if len(juz_bounds) != 30 or len(hizb_bounds) != 60:
            raise BuildError("Expected 30 juz and 60 hizb")
        sajda = {
            str(row["verse_key"])
            for row in sources["sajda_metadata"].execute("SELECT verse_key FROM sajdah")
        }
        if len(sajda) != 15 or not sajda <= set(metadata):
            raise BuildError("Invalid QUL sajda set")
        first_page, page_members = _page_mapping(
            sources["layout_1405h"], sources["word_glyphs_1405h"]
        )
        if set(first_page) != set(metadata):
            raise BuildError("QUL layout and canonical ayah key sets differ")

        chapters = list(sources["surah_metadata"].execute(
            "SELECT id,name_simple,name_arabic,revelation_order,revelation_place,verses_count,bismillah_pre "
            "FROM chapters ORDER BY id"
        ))
        if len(chapters) != 114 or [int(row["id"]) for row in chapters] != list(range(1, 115)):
            raise BuildError("QUL Surah metadata must contain 114 sequential chapters")

        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        temporary = OUTPUT.with_suffix(".sqlite.building")
        temporary.unlink(missing_ok=True)
        connection = sqlite3.connect(temporary)
        try:
            connection.executescript(SCHEMA)
            for chapter in chapters:
                number = int(chapter["id"])
                chapter_keys = [key for key in metadata if key.startswith(f"{number}:")]
                if len(chapter_keys) != chapter["verses_count"]:
                    raise BuildError(f"QUL Surah count mismatch for {number}")
                connection.execute(
                    "INSERT INTO surah VALUES (?,?,?,?,?,?,?,?,?,?)",
                    (number, chapter["name_arabic"], chapter["name_simple"], None, None,
                     len(chapter_keys), chapter["revelation_place"], chapter["revelation_order"],
                     first_page[_key(number, 1)], chapter["bismillah_pre"]),
                )
            for key, gid in sorted(metadata.items(), key=lambda item: item[1]):
                surah, ayah = (int(part) for part in key.split(":"))
                simple = imlaei[key][1]
                connection.execute(
                    "INSERT INTO ayah VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                    (gid, surah, ayah, first_page[key], juz_map[key], None, None, None,
                     int(key in sajda), uthmani[key][1], simple, normalize_ar(simple),
                     None, translations[key], None, hizb_map[key]),
                )
            for page in range(1, 605):
                ids = sorted(metadata[key] for key in page_members[page])
                if not ids:
                    raise BuildError(f"Empty QUL page {page}")
                connection.execute("INSERT INTO page VALUES (?,?,?,?)",
                                   (page, ids[0], ids[-1], juz_map[next(key for key, gid in metadata.items() if gid == ids[0])]))
            for table, bounds in (("juz", juz_bounds), ("hizb", hizb_bounds)):
                for number, first, last in bounds:
                    connection.execute(f"INSERT INTO {table} VALUES (?,?,?)",
                                       (number, metadata[first], metadata[last]))
            connection.execute("INSERT INTO ayah_fts(ayah_fts) VALUES ('rebuild')")
            hashes = {name: item["sha256"] for name, item in
                      {**lock["sources"], **print_lock["sources"]}.items()}
            fingerprint = sha256_bytes(json.dumps(hashes, sort_keys=True).encode())
            _insert_print_data(connection, sources["layout_1405h"],
                               sources["word_glyphs_1405h"], metadata,
                               assets, fingerprint, manifest_digest)
            connection.executemany("INSERT INTO meta VALUES (?,?)", [
                ("db_version", "3"), ("built_at", f'{lock["snapshot_date"]}T00:00:00Z'),
                ("source", "QUL"), ("sources_json", json.dumps(lock, sort_keys=True)),
                ("print_sources_json", json.dumps(print_lock, sort_keys=True)),
                ("print_manifest_sha256", manifest_digest),
                ("print_edition", manifest["edition"]),
                ("sha256", fingerprint),
            ])
            connection.commit()
            if connection.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
                raise BuildError("Built SQLite integrity check failed")
            if connection.execute("PRAGMA foreign_key_check").fetchone() is not None:
                raise BuildError("Built SQLite foreign key check failed")
            connection.execute("VACUUM")
        except BaseException:
            connection.close()
            temporary.unlink(missing_ok=True)
            raise
        else:
            connection.close()
        os.replace(temporary, OUTPUT)
        digest = sha256_bytes(OUTPUT.read_bytes())
        SIDECAR.write_text(f"{digest}  {OUTPUT.name}\n", encoding="utf-8")
        print(f"Built QUL database v3: {OUTPUT} ({OUTPUT.stat().st_size:,} bytes; SHA-256 {digest})")
        return OUTPUT
    finally:
        for source in sources.values():
            source.close()


def main() -> None:
    try:
        build_database(read_lock())
    except (BuildError, OSError, sqlite3.Error, ValueError, KeyError) as error:
        raise SystemExit(f"QUL database build failed: {error}") from error


if __name__ == "__main__":
    main()
