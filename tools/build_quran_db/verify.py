"""Verify the generated QUL-only semantic database against pinned source ZIPs."""

from __future__ import annotations

import json
import sqlite3

from build import (  # type: ignore[import-not-found]
    EXPECTED_AYAT,
    OUTPUT,
    SIDECAR,
    EDITION,
    BuildError,
    _map_parts,
    _page_mapping,
    _verses,
    normalize_ar,
    open_source,
    read_lock,
    read_print_pack,
    sha256_bytes,
    source_path,
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise BuildError(message)


def verify() -> list[str]:
    require(OUTPUT.is_file() and SIDECAR.is_file(), "QUL database or checksum is missing")
    lock = read_lock()
    for name in lock["sources"]:
        source_path(lock, name)
    print_lock, manifest, manifest_digest, assets = read_print_pack(lock)
    passed = ["All pinned QUL archive hashes match"]
    digest = sha256_bytes(OUTPUT.read_bytes())
    require(SIDECAR.read_text(encoding="utf-8").split()[0] == digest,
            "QUL database checksum mismatch")
    db = sqlite3.connect(f"file:{OUTPUT}?mode=ro", uri=True)
    db.row_factory = sqlite3.Row
    sources = {name: open_source(lock, name) for name in (
        "uthmani", "imlaei_simple", "translation_id", "ayah_metadata", "surah_metadata",
        "juz_metadata", "hizb_metadata", "sajda_metadata", "layout_1405h", "word_glyphs_1405h",
    )}
    try:
        require(db.execute("PRAGMA integrity_check").fetchone()[0] == "ok", "SQLite integrity failed")
        require(db.execute("PRAGMA foreign_key_check").fetchone() is None, "Foreign keys failed")
        require(db.execute("PRAGMA user_version").fetchone()[0] == 3, "Wrong user_version")
        meta = dict(db.execute("SELECT key,value FROM meta"))
        require(meta.get("db_version") == "3" and meta.get("source") == "QUL", "Wrong DB source/version")
        require(json.loads(meta["sources_json"]) == lock, "DB source lock does not match")
        require(json.loads(meta["print_sources_json"]) == print_lock,
                "DB print source lock does not match")
        require(meta.get("print_manifest_sha256") == manifest_digest and
                meta.get("print_edition") == EDITION, "DB print manifest identity differs")
        counts = {name: db.execute(f"SELECT COUNT(*) FROM {name}").fetchone()[0]
                  for name in ("surah", "ayah", "page", "juz", "hizb", "tafsir")}
        require(counts == {"surah": 114, "ayah": 6236, "page": 604, "juz": 30,
                           "hizb": 60, "tafsir": 0}, f"Unexpected row counts: {counts}")
        require(db.execute("SELECT MIN(id),MAX(id) FROM ayah").fetchone()[:] == (1, 6236),
                "Global ayah ID range changed")
        require(db.execute("SELECT SUM(ayah_count) FROM surah").fetchone()[0] == EXPECTED_AYAT,
                "Surah counts do not sum to 6236")
        require(db.execute("SELECT COUNT(*) FROM surah WHERE translation_id IS NOT NULL OR translation_en IS NOT NULL").fetchone()[0] == 0,
                "Unsourced Surah meanings must be null")
        require(db.execute("SELECT COUNT(*) FROM ayah WHERE text_latin IS NOT NULL OR translation_en IS NOT NULL OR hizb_quarter IS NOT NULL OR ruku IS NOT NULL OR manzil IS NOT NULL").fetchone()[0] == 0,
                "Unsourced optional ayah fields must be null")
        passed.append("Schema v3 semantic counts, IDs, and deferred fields are valid")

        uthmani = _verses(sources["uthmani"], "QUL Uthmani")
        imlaei = _verses(sources["imlaei_simple"], "QUL Imlaei Simple")
        translation = {str(row["ayah_key"]): str(row["text"])
                       for row in sources["translation_id"].execute("SELECT ayah_key,text FROM translation")}
        first_page, page_members = _page_mapping(sources["layout_1405h"], sources["word_glyphs_1405h"])
        juz, _ = _map_parts(sources["juz_metadata"], "juz", "juz_number")
        hizb, _ = _map_parts(sources["hizb_metadata"], "hizbs", "hizb_number")
        sajda = {str(row[0]) for row in sources["sajda_metadata"].execute("SELECT verse_key FROM sajdah")}
        require(set(uthmani) == set(imlaei) == set(translation) == set(first_page) == set(juz) == set(hizb),
                "QUL source key sets differ")
        require(len(sajda) == 15, "Sajda count differs")
        for row in db.execute("SELECT * FROM ayah ORDER BY id"):
            key = f'{row["surah"]}:{row["ayah"]}'
            require(key in uthmani, f"Unexpected ayah {key}")
            require(row["id"] == uthmani[key][0] == imlaei[key][0], f"ID mismatch at {key}")
            require(row["text_uthmani"] == uthmani[key][1], f"Uthmani changed at {key}")
            require(row["text_simple"] == imlaei[key][1], f"Imlaei changed at {key}")
            require(row["translation_id"] == translation[key], f"Indonesian translation changed at {key}")
            require(row["text_norm"] == normalize_ar(imlaei[key][1]), f"Normalization changed at {key}")
            require((row["page"], row["juz"], row["hizb"], row["sajda"]) ==
                    (first_page[key], juz[key], hizb[key], int(key in sajda)),
                    f"QUL location metadata mismatch at {key}")
        for page in range(1, 605):
            ids = sorted(uthmani[key][0] for key in page_members[page])
            actual = db.execute("SELECT first_ayah,last_ayah FROM page WHERE number=?", (page,)).fetchone()
            require(actual is not None and tuple(actual) == (ids[0], ids[-1]),
                    f"1405H page boundaries differ at {page}")
        require(db.execute("SELECT page,juz FROM ayah WHERE surah=2 AND ayah=255").fetchone()[:] == (42, 3),
                "2:255 spot check failed")
        require(db.execute("SELECT COUNT(*) FROM ayah_fts WHERE ayah_fts MATCH 'الحمد'").fetchone()[0] > 0,
                "Arabic FTS query failed")
        passed.append("Every ayah matches QUL text, translation, page, juz, hizb, and sajda")
        passed.append("All 604 page boundaries and Arabic FTS are valid")
        print_counts = {name: db.execute(f"SELECT COUNT(*) FROM {name}").fetchone()[0]
                        for name in ("mushaf_edition", "mushaf_asset", "mushaf_page",
                                     "mushaf_line", "mushaf_word", "mushaf_ayah_page")}
        require(print_counts["mushaf_edition"] == 1 and print_counts["mushaf_asset"] == 722 and
                print_counts["mushaf_page"] == 604 and
                print_counts["mushaf_line"] == sources["layout_1405h"].execute(
                    "SELECT COUNT(*) FROM pages").fetchone()[0] and
                print_counts["mushaf_word"] == 83668 and
                print_counts["mushaf_ayah_page"] >= EXPECTED_AYAT,
                f"Incomplete v3 print tables: {print_counts}")
        edition = db.execute("SELECT * FROM mushaf_edition").fetchone()
        require(edition["id"] == EDITION and edition["pack_version"] == 3 and
                edition["page_count"] == 604 and edition["manifest_sha256"] == manifest_digest and
                (edition["design_width"], edition["word_font_size"]) == (660.0, 42.0),
                "Invalid print edition profile")
        asset_rows = [tuple(row) for row in db.execute(
            "SELECT edition_id,id,kind,page,path,sha256,byte_size,source_name,rights_status "
            "FROM mushaf_asset ORDER BY kind,id"
        )]
        require(sorted(asset_rows) == sorted(assets), "DB asset records differ from verified local pack")
        require(manifest["edition"] == EDITION, "Local pack edition differs")
        source_words = {int(row["id"]): row for row in sources["word_glyphs_1405h"].execute(
            "SELECT id,location,surah,ayah,word,text FROM words"
        )}
        seen_words: set[int] = set()
        seen_ayat: set[int] = set()
        for page in range(1, 605):
            source_lines = list(sources["layout_1405h"].execute(
                "SELECT line_number,line_type,is_centered,first_word_id,last_word_id,surah_number "
                "FROM pages WHERE page_number=? ORDER BY line_number", (page,)
            ))
            page_row = db.execute("SELECT line_count,font_asset_id FROM mushaf_page "
                                  "WHERE edition_id=? AND page=?", (EDITION, page)).fetchone()
            require(page_row is not None and tuple(page_row) ==
                    (len(source_lines), f"font:p{page}.ttf"), f"Invalid print page {page}")
            lines = list(db.execute("SELECT * FROM mushaf_line WHERE edition_id=? AND page=? ORDER BY line",
                                    (EDITION, page)))
            require(len(lines) == len(source_lines), f"Print line count differs on page {page}")
            for source, actual in zip(source_lines, lines, strict=True):
                first = int(source["first_word_id"]) if source["line_type"] == "ayah" else None
                last = int(source["last_word_id"]) if source["line_type"] == "ayah" else None
                surah = int(source["surah_number"]) if source["surah_number"] not in (None, "") else None
                require((actual["line"], actual["kind"], actual["centered"], actual["surah"],
                         actual["first_word_id"], actual["last_word_id"]) ==
                        (source["line_number"], source["line_type"], source["is_centered"],
                         surah, first, last), f"Print line differs at {page}:{actual['line']}")
                word_rows = list(db.execute(
                    "SELECT id,ayah_id,word_key,glyph,position FROM mushaf_word "
                    "WHERE edition_id=? AND page=? AND line=? ORDER BY position",
                    (EDITION, page, actual["line"]),
                ))
                require(len(word_rows) == (last - first + 1 if first is not None else 0),
                        f"Print word count differs at {page}:{actual['line']}")
                for position, row in enumerate(word_rows, start=1):
                    source_word = source_words[row["id"]]
                    key = f'{source_word["surah"]}:{source_word["ayah"]}'
                    require(row["id"] == first + position - 1 and
                            (row["ayah_id"], row["word_key"], row["glyph"], row["position"]) ==
                            (uthmani[key][0], source_word["location"], source_word["text"], position),
                            f"Print word differs at {page}:{actual['line']}:{position}")
                    seen_words.add(row["id"])
                    seen_ayat.add(row["ayah_id"])
        require(len(seen_words) == 83668 and len(seen_ayat) == EXPECTED_AYAT,
                "Print word or canonical ayah coverage differs")
        segment_rows = list(db.execute(
            "SELECT ayah_id,page,first_line,last_line,first_word_id,last_word_id "
            "FROM mushaf_ayah_page WHERE edition_id=? ORDER BY ayah_id,page", (EDITION,)
        ))
        require(len(segment_rows) == print_counts["mushaf_ayah_page"], "Missing ayah page segments")
        for segment in segment_rows:
            actual = db.execute(
                "SELECT MIN(line),MAX(line),MIN(id),MAX(id) FROM mushaf_word "
                "WHERE edition_id=? AND ayah_id=? AND page=?",
                (EDITION, segment["ayah_id"], segment["page"]),
            ).fetchone()
            require(tuple(segment)[2:] == tuple(actual),
                    f"Incorrect ayah page segment {segment['ayah_id']}:{segment['page']}")
        passed.append("All QUL print lines, words, ayah segments, and 722 asset hashes match")
        return passed
    finally:
        db.close()
        for source in sources.values():
            source.close()


def main() -> None:
    try:
        for item in verify():
            print(f"PASS  {item}")
    except (BuildError, OSError, sqlite3.Error, ValueError, KeyError) as error:
        raise SystemExit(f"QUL database verification failed: {error}") from error


if __name__ == "__main__":
    main()
