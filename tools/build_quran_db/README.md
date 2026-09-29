# Offline Qur’an database builder

This tool creates `apps/mobile/assets/db/quran.sqlite` from locked upstream snapshots.

## Sources and attribution

- Qur’an Uthmani and Simple Clean text: Tanzil Project, text release 1.1. Preserve both text columns exactly as downloaded. Verbatim text may not be changed; the application must credit Tanzil and link to [tanzil.net](https://tanzil.net).
- Page, juz, hizb-quarter, ruku, manzil, sajda, and surah metadata: AlQuran.cloud API and Tanzil Quran metadata XML. The builder cross-checks page and juz boundaries against Tanzil metadata; AlQuran.cloud supplies hizb-quarter because Tanzil's XML does not include those boundaries.
- Indonesian translation, Latin transliteration, and tafsir: Kemenag RI data via EQuran.id. Attribution must credit Kemenag RI and EQuran.id. Review upstream redistribution terms before public release.

The normalized Arabic column is derived only for search. It must never be displayed as Qur’an text. The displayed Uthmani and Simple Clean columns remain source-exact.

## Build and verify

Run `python3 tools/build_quran_db/build.py --update-lock` once to fetch current snapshots, record their SHA-256 values in `sources.lock.json`, and build the database. Review source changes before updating those pins again.

Later builds use the pinned cache and fail if a source hash changes. Run `python3 tools/build_quran_db/build.py` to build from pinned sources and `python3 tools/build_quran_db/verify.py` to check source identity, metadata, schema invariants, FTS, checksum, and size.

Downloaded source snapshots are kept in the ignored `.cache/` directory. The generated SQLite database and checksum are local build artifacts; regenerate them before packaging the mobile app.

The Quran Foundation pre-live API contains only surahs 1 and 2. Therefore it cannot be used for a 6,236-ayah page comparison. Production Quran Foundation cross-checking is an optional release verification after production API access is approved.

## Build the ASR search index

From `services/api`, run `uv run python ../../tools/build_quran_db/build_index.py`. The builder reads the local Quran database, uses the shared normalizer, and writes `services/api/data/quran_index.pkl` plus its SHA-256 sidecar. The index contains all single-ayah units, every within-surah two- and three-ayah window, and reading aliases for muqatta'at. It checks unit counts, checksum, serialized size (under 30 MiB), and reload time (under one second).
