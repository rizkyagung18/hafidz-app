# Local QUL Qur’an assets

This builder produces QUL-only `quran.sqlite` v3 with semantic Qur'an content and the Madinah 1405H print layout, plus the ASR search index. See [docs/12](../../docs/12-QUL-CORE-AND-LIVE-VOICE.md) for the content contract, [sources.lock.json](sources.lock.json) for semantic/layout inputs, and [print_sources.lock.json](print_sources.lock.json) for auxiliary font and ligature hashes.

## Inputs

Place the supplied QUL archives at their paths in `sources.lock.json`, under the ignored `tools/build_quran_db/.cache/` directory. Keep the original archives. The builder verifies every hash and fails if a file is missing or changed. It uses only the supplied pinned QUL sources, without external content fallbacks. Do not commit or distribute the archives, generated database, index, or fonts until resource-specific redistribution rights are established.

The print staging command also needs the QPC V1 page-font archive, the user-supplied QUL font ZIPs for the Surah header, top-left Surah name, and Juz/common glyphs, the pinned `surah_name_v1.ttf`, and the Surah header ligature map. All are listed in the locks. Install HarfBuzz's `hb-view` CLI locally to rasterize each color-font Surah header into a transparent PNG. Inspect or audit sources with `audit_qul_1405h.py` before staging. The staged mobile print pack is ignored by Git.

## Local build and verification

Run from the repository root:

```bash
uv sync --project services/api --locked --extra dev
uv run --project services/api python tools/build_quran_db/stage_mushaf_local.py
uv run --project services/api python tools/build_quran_db/build.py
uv run --project services/api python tools/build_quran_db/verify.py
uv run --project services/api python tools/build_quran_db/build_index.py
```

The v3 builder checks 114 surahs, 6,236 canonical ayat, 604 page boundaries, 30 juz, 60 hizb, 83,668 print words, all source lines, and 722 font/header assets. The verifier compares those rows and hashes against the pinned QUL sources. The index embeds the database SHA-256 and is rejected by the backend if it differs. `stage_mushaf_local.py` writes the local font/header pack before the database build. Neither staging nor data verification establishes visual fidelity or redistribution rights.

Run the source-independent audit tests anywhere:

```bash
uv run --project services/api python -m unittest tools.build_quran_db.test_audit_qul_1405h tools.build_quran_db.test_preview_qul_1405h
```

GitHub CI runs those source-independent tests and Dart source analysis. Full database, index, print, Flutter analysis, and reader tests run locally while the QUL resources remain untracked. Do not interpret a green CI result as a verified content build.

The Surah reader additionally uses the supplied `qpc-v1-ayah-by-ayah-glyphs.db` as a local presentation asset. Extract it into `apps/mobile/assets/db/` using the command in docs/06. It does not replace canonical QUL Uthmani or rebuild the ASR index. Its exact checksum is pinned by the glyph loader.
