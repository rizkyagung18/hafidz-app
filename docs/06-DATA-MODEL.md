# 06 — Data Model

**Current target:** QUL-only `quran.sqlite` v3 extends the implemented v2 semantic content with the Madinah 1405H print records in §1.1. The older v1 SQL in §1 is retained as migration history only; its former content sources and required Latin, tafsir, Surah meanings, and hizb-quarter fields are not current contracts. The exact semantic SQL is `tools/build_quran_db/build.py` and `apps/mobile/lib/core/database/quran_schema.drift`.

Two SQLite databases on device (drift), plus an in-memory index on the server.

The current mobile layer mirrors the QUL schema in `apps/mobile/lib/core/database/*.drift`.
`openLocalDatabases()` checks the bundled SHA-256 sidecar, copies a changed
`quran.sqlite` into the app support directory, and checks both `PRAGMA user_version`
and `meta.db_version` before use. The content connection runs with SQLite
`query_only=ON` and Drift migrations disabled. `user.sqlite` is stored separately
in the same directory and keeps bookmarks and reading progress when content is
replaced. Mobile CI builds and verifies the ignored content asset before tests.

The Madinah 1405H print records are specified below. `user.sqlite` remains independently mutable.

| Store | Location | Mutable | Content |
|---|---|---|---|
| `quran.sqlite` | App assets (copied to app support dir on first launch) | No (replaced on DB version upgrade) | Qur'an text, metadata, translation, tafsir, search index |
| `user.sqlite` | App support dir | Yes | Bookmarks, last read, history, settings, cached schedules, downloads |
| `quran_index.pkl` | Server image `/data` | No | TF-IDF matrix + units for the matcher (docs/03 §3) |
| Redis | Server | TTL | Provider cache, QF token, rate-limit counters |
| PostgreSQL | Server (Phase 2) | Yes | Users, synced bookmarks, opt-in audio consent records |

## 1. `quran.sqlite` (read-only content DB)

```sql
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- rows: db_version, built_at, source_revision, sources_json, sha256

CREATE TABLE surah (
  number            INTEGER PRIMARY KEY,          -- 1..114
  name_arabic       TEXT NOT NULL,
  name_latin        TEXT NOT NULL,                -- "Al-Baqarah"
  translation_id    TEXT NOT NULL,                -- "Sapi Betina"
  translation_en    TEXT NOT NULL,
  ayah_count        INTEGER NOT NULL,
  revelation_place  TEXT NOT NULL CHECK (revelation_place IN ('makkah','madinah')),
  revelation_order  INTEGER,
  first_page        INTEGER NOT NULL,
  bismillah_pre     INTEGER NOT NULL DEFAULT 1    -- 0 for surah 1 (basmala is ayah 1) and 9
);

CREATE TABLE ayah (
  id            INTEGER PRIMARY KEY,              -- global index 1..6236
  surah         INTEGER NOT NULL REFERENCES surah(number),
  ayah          INTEGER NOT NULL,
  page          INTEGER NOT NULL,                 -- Madani 1..604
  juz           INTEGER NOT NULL,                 -- 1..30
  hizb_quarter  INTEGER NOT NULL,                 -- 1..240
  ruku          INTEGER,
  manzil        INTEGER,
  sajda         INTEGER NOT NULL DEFAULT 0,
  text_uthmani  TEXT NOT NULL,                    -- VERBATIM QUL Uthmani — never modified
  text_simple   TEXT NOT NULL,                    -- VERBATIM QUL Imlaei Simple
  text_norm     TEXT NOT NULL,                    -- normalize_ar(text_simple) — search only, never displayed
  text_latin    TEXT,                             -- deferred; null in the QUL-only corpus
  translation_id TEXT NOT NULL,                   -- verbatim pinned QUL Indonesian translation
  translation_en TEXT,                            -- deferred until a QUL source is selected
  UNIQUE (surah, ayah)
);
CREATE INDEX ix_ayah_page ON ayah(page);
CREATE INDEX ix_ayah_juz ON ayah(juz);

CREATE TABLE tafsir (
  ayah_id  INTEGER NOT NULL REFERENCES ayah(id),
  source   TEXT NOT NULL,                         -- 'kemenag'
  text     TEXT NOT NULL,
  PRIMARY KEY (ayah_id, source)
);

CREATE TABLE page (
  number      INTEGER PRIMARY KEY,                -- 1..604
  first_ayah  INTEGER NOT NULL REFERENCES ayah(id),
  last_ayah   INTEGER NOT NULL REFERENCES ayah(id),
  juz         INTEGER NOT NULL
);

CREATE TABLE juz (
  number      INTEGER PRIMARY KEY,
  first_ayah  INTEGER NOT NULL,
  last_ayah   INTEGER NOT NULL
);

-- Full-text search for translation + normalized Arabic
CREATE VIRTUAL TABLE ayah_fts USING fts5(
  text_norm, translation_id, translation_en,
  content='ayah', content_rowid='id', tokenize='unicode61 remove_diacritics 2'
);

CREATE TABLE doa (           -- snapshot from equran.id, refreshed via sync
  id INTEGER PRIMARY KEY, grup TEXT, nama TEXT, ar TEXT, tr TEXT, idn TEXT, tentang TEXT, tags TEXT
);

CREATE TABLE asmaul_husna (
  number INTEGER PRIMARY KEY, arabic TEXT, latin TEXT, meaning_id TEXT, meaning_en TEXT
);

CREATE TABLE prayer_location (   -- Indonesian kab/kota for offline picker + reverse geocode
  id TEXT PRIMARY KEY,           -- 'id-jabar-kota-bogor'
  name TEXT NOT NULL, province TEXT NOT NULL,
  lat REAL NOT NULL, lng REAL NOT NULL, tz TEXT NOT NULL,   -- Asia/Jakarta | Asia/Makassar | Asia/Jayapura
  myquran_id TEXT                                          -- e.g. '1301'
);
```

Build invariants (checked by `tools/build_quran_db/verify.py`, CI fails otherwise):
- `COUNT(ayah) = 6236`, `COUNT(surah) = 114`, `MAX(page) = 604`, `MAX(juz) = 30`.
- Sum of `surah.ayah_count` = 6236; each `(surah, ayah)` contiguous from 1.
- `page` and `juz` come from audited QUL mappings; optional divisions remain absent unless a QUL source has been supplied.
- SHA-256 of QUL source archives matches the pinned value in `tools/build_quran_db/sources.lock.json`.
- Spot checks: `2:255 → page 42, juz 3`; `1:1 → page 1`; `114:6 → page 604`; `18:1 → juz 15`.

## 1.1 Madinah 1405H presentation data, schema v3

Design contract for T-M04-R1–R3; see [docs/11](11-MUSHAF-1405H-REDESIGN.md) and
[ADR-006](adr/ADR-006-madinah-1405h-mushaf.md). This is an additive rebuild of immutable mobile content, not a
replacement of canonical Qur'an text or the user database. Final SQL and the upstream-to-local adapter follow
inspection of the actual QUL exports in R1.

### Source identity and local records

Pin these sources together: [layout resource 15](https://qul.tarteel.ai/resources/mushaf-layout/15),
[word glyphs 57](https://qul.tarteel.ai/resources/quran-script/57), and
[page fonts 238](https://qul.tarteel.ai/resources/font/238). QUL's preview tool identifies this edition as
`mushaf_layouts/2`; that tool ID is distinct from download resource 15.

The inspected layout export has `info(name, number_of_pages, lines_per_page, font_name)` and
`pages(page_number, line_number, line_type, is_centered, first_word_id, last_word_id, surah_number)`. The
inspected word export has `words(id, location, surah, ayah, word, text)`; `id` joins the page-line word ranges,
and `location` is `surah:ayah:word`. QUL's website example names `word_index` and `word_key`, which are absent
from this actual export. Validate the pinned source hash and schema before import. Neither these resources nor
this contract promise upstream pixel rectangles.

Local records (names describe our schema, not asserted upstream table names):

| Record | Required identity and content |
|---|---|
| `mushaf_edition` | Key `madinah-1405h-qpc-v1`; print identity, resource/tool IDs, source revision or snapshot date, pack version, source-lock hash, provenance/license references, page count 604 |
| `mushaf_asset` | Composite edition/asset ID; kind, optional page number, local path, SHA-256, byte size, source URL, license evidence reference; includes fonts and any approved auxiliary artwork |
| `mushaf_page` | Composite edition/page key; exact font asset reference, visual-reference/layout-profile ID, fixed design dimensions established by the visual proof |
| `mushaf_line` | Composite edition/page/line key; source line type and centered flag, first/last source word IDs when present, surah number when applicable; preserve source ordering and special rows |
| `mushaf_word` | Composite edition/source word ID; canonical `ayah_id` reference, source word key/position, exact glyph string, derived page/line/order membership; font via page or explicit asset reference if the export requires it |
| `mushaf_ayah_page` | Derived table of canonical ayah membership on edition pages and lines; retains every segment, including an ayah spanning pages |

The v3 package has one edition `madinah-1405h-qpc-v1`. `mushaf_page` holds each page's font asset and exact source line count. `mushaf_line` holds the source kind (`ayah`, `surah_name`, `basmallah`), centered flag, optional surah, and the source word range. `mushaf_word` holds source word ID, `surah:ayah:word` key, exact glyph, canonical ayah ID, page, line, and position; its page/line order must agree with the layout. `mushaf_ayah_page` records the first/last line and word for each ayah segment on a page. All print tables use the edition key. `mushaf_asset` holds each of 604 page fonts, four auxiliary fonts, and 114 generated headers with a local relative path, hash, byte count, source reference, and unresolved rights status. `mushaf_edition` pins the combined source hash and manifest hash. The approved local renderer uses a 660-unit page width with 8-unit horizontal insets and a 42-unit QPC word font; extra portrait height becomes line leading and never changes source word or line membership.

The build order is: stage and hash the ignored QUL fonts and header images, build v3 SQLite from the pinned semantic and print locks, verify the database and pack together, then rebuild the ASR index from that exact SQLite checksum. The mobile loader reads line and word rows from SQLite and verifies the matching manifest, font, and header hashes before displaying a page. Page JSON files are no longer runtime content. Packaging remains local while resource-specific redistribution rights are unresolved.

`mushaf_page` design dimensions come from our approved rendering profile, not invented QUL coordinate fields.
Marker ownership and token roles must follow the inspected source: an ayah end ornament may be part of a glyph
token rather than a standalone word. Never infer a universal word count or strip marker glyphs. Non-ayah line
assets (surah headers, unnumbered basmala) have no fake canonical ayah ID. Source adapters must document how they
map any separately encoded markers or auxiliary fonts before the local schema is finalized.

Word IDs are not ayah IDs. Join QUL words to existing canonical ayat by validated `surah:ayah`; keep all 6,236
canonical IDs, verbatim text, translations, tafsir, and FTS content unchanged. Preserve the v1 `ayah.page`, `page`,
and `surah.first_page` values for existing consumers. New Mushaf navigation derives the first page of an ayah,
surah, or juz from the edition's membership and existing canonical boundaries. Report every difference from the
legacy page map rather than rewriting it silently.

Runtime token boxes are derived from the exact shaped line. They are not an authoritative content table. Any
geometry cache is keyed by edition, pack version, font hash, and layout profile; invalidate it when these change.

### Additional v3 build invariants

- Exactly one complete active edition with contiguous pages 1–604 and complete source line coverage. Ordinary
  pages follow 15-line layout rules; opening pages, headers, and basmala rows follow verified source exceptions.
- Every source word is accounted for in its prescribed order and valid line range. No dropped, duplicated, or
  orphaned ayah tokens; canonical references resolve within the existing 114 surahs and 6,236 ayat.
- Every canonical ayah has complete rendering membership, including all segments and its numbered end marker.
  Preserve Al-Fatihah's numbered basmala and separate unnumbered basmala rows; At-Tawbah has no added basmala.
- Fonts cover every used glyph and match the pinned edition/page. Missing fonts, missing glyphs, mixed revisions,
  or unknown line/token kinds fail verification; no fallback to another print or generic font.
- Canonical text hashes and IDs stay unchanged; existing v1 semantic invariants still pass. Compare the full
  1405H page map with legacy metadata and retain the comparison report even if all boundaries agree.
- Spot checks include pages 1, 2, 42 (2:253–256), 48 (2:282), 121 (5:77–82), 187 (9:1–6), and 604, confirmed
  against the pinned source. A passing 2:255 check alone does not prove the whole edition.
- Source-lock, asset paths, sizes, checksums, provenance, and resource-specific redistribution evidence cover
  every shipped input. Verify all 604 pages offline; measure the final package against the provisional size goal.

### Coordinated loading and user-data preservation

Advance `PRAGMA user_version` and `meta.db_version` together to 3 with matching builder, verifier, Drift, loader,
manifest and checksum changes. The v2 semantic database alone cannot render the v3 print view. Verify staged
content and matching assets before replacing installed content; preserve the last verified v3 package on a failed
update. A first v1/v2 → v3 failure must preserve existing data and show a recoverable print-content error. Never
reset `user.sqlite` to repair content loading.

Keep bookmarks, notes, history, and settings by their canonical references. Recompute `reading_position.page`
from its saved `ayah_id` in the new edition, preserving the ayah and mode. Record edition/pack identity in
`kv_setting` for page-based state. Preserve existing khatam page progress with its original mapping; do not
relabel completed pages as 1405H if boundaries differ. Any conversion must use the full page-map comparison
and keep the original state recoverable.

The existing `/v1/quran/db/manifest` contract stays unchanged. Mobile schema v3 is not permission to replace
the artifact served to v1 clients. A later remote package update needs a separately
documented version/asset negotiation contract in both API specs; none is introduced by this redesign.

## 2. `user.sqlite` (mutable)

```sql
CREATE TABLE bookmark (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  ayah_id    INTEGER NOT NULL,
  folder     TEXT NOT NULL DEFAULT 'default',
  note       TEXT,
  color      TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  UNIQUE (ayah_id, folder)
);

CREATE TABLE reading_position (   -- single-row "last read" + khatam progress
  id           INTEGER PRIMARY KEY CHECK (id = 1),
  ayah_id      INTEGER NOT NULL,
  page         INTEGER NOT NULL,
  mode         TEXT NOT NULL CHECK (mode IN ('mushaf','list')),
  updated_at   TEXT NOT NULL
);

CREATE TABLE khatam_plan (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  started_at TEXT NOT NULL, target_days INTEGER NOT NULL,
  pages_read_json TEXT NOT NULL DEFAULT '[]', completed_at TEXT
);

CREATE TABLE voice_search_history (  -- NO AUDIO stored
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  best_key    TEXT,                   -- '2:255' or '2:255-256'
  confidence  REAL,
  transcript  TEXT,                   -- optional; user can disable in settings
  created_at  TEXT NOT NULL
);

CREATE TABLE prayer_cache (
  location_id TEXT NOT NULL,
  date        TEXT NOT NULL,          -- YYYY-MM-DD
  source      TEXT NOT NULL,          -- kemenag:equran | kemenag:myquran | aladhan | calc
  times_json  TEXT NOT NULL,
  fetched_at  TEXT NOT NULL,
  PRIMARY KEY (location_id, date)
);

CREATE TABLE adzan_setting (
  prayer        TEXT PRIMARY KEY CHECK (prayer IN ('imsak','subuh','terbit','dhuha','dzuhur','ashar','maghrib','isya')),
  enabled       INTEGER NOT NULL DEFAULT 1,
  sound         TEXT NOT NULL DEFAULT 'adzan_makkah',
  pre_minutes   INTEGER NOT NULL DEFAULT 0,
  offset_minutes INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE audio_download (
  reciter_id TEXT NOT NULL, surah INTEGER NOT NULL,
  path TEXT NOT NULL, bytes INTEGER, downloaded_at TEXT NOT NULL,
  PRIMARY KEY (reciter_id, surah)
);

CREATE TABLE tasbih_counter (
  id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT NOT NULL, count INTEGER NOT NULL DEFAULT 0,
  target INTEGER, updated_at TEXT NOT NULL
);

CREATE TABLE kv_setting (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- keys: locale, theme, arabic_font, arabic_font_size, show_latin, show_translation, reciter_id,
--       prayer_location_id, prayer_method, prayer_school, prayer_ihtiyat, device_id, save_voice_transcript
```

## 3. Domain entities (Dart, freezed)

```dart
@freezed class AyahRef with _$AyahRef {           // canonical identifier
  const factory AyahRef({required int surah, required int ayah}) = _AyahRef;
  factory AyahRef.parse(String key) { final p = key.split(':'); return AyahRef(surah: int.parse(p[0]), ayah: int.parse(p[1])); }
}
@freezed class AyahRange with _$AyahRange {
  const factory AyahRange({required int surah, required int start, required int end}) = _AyahRange;
}
@freezed class VoiceMatch with _$VoiceMatch {
  const factory VoiceMatch({required AyahRange range, required int page, required int juz,
    required String surahNameLatin, required double score}) = _VoiceMatch;
}
@freezed class VoiceDetectResult with _$VoiceDetectResult {
  const factory VoiceDetectResult({required String transcript, required double confidence,
    required double margin, required bool ambiguous, String? reason, VoiceMatch? best,
    required List<VoiceMatch> candidates, required Thresholds thresholds}) = _VoiceDetectResult;
}
enum VoiceDecision { autoNavigate, pickCandidate, notFound }
```

`VoiceDecision decide(VoiceDetectResult r)` lives in the domain layer and uses `r.thresholds` (docs/03 §5.1).

## 4. Server index objects (Python)

```python
@dataclass(frozen=True)
class Unit:
    unit_id: int
    surah: int
    ayah_start: int
    ayah_end: int
    text_a: str                 # normalized Uthmani
    text_b: str                 # normalized Simple Clean
    offsets_a: tuple[int, ...]  # char offset where each ayah starts in text_a
    offsets_b: tuple[int, ...]
    is_alias: bool = False      # huruf muqatta'at spelled-out alias

@dataclass
class QuranIndex:
    units: list[Unit]
    vectorizer: TfidfVectorizer
    matrix: scipy.sparse.csr_matrix
    word_idf: dict[str, float]
    word_to_ayat: dict[str, set[int]]
    ayah_meta: dict[tuple[int, int], AyahMeta]   # page, juz, names
```

### Surah reader presentation database (2026-10-05)

The local-only asset `apps/mobile/assets/db/qpc-v1-ayah-by-ayah-glyphs.db` is extracted unchanged from the owner-supplied QUL ZIP. Its `verses(id, verse_key, surah, ayah, text, page_number)` table has all 6,236 canonical ayat. `text` contains the exact QPC V1 ayah glyph string, including its ending ornament; `page_number` selects the existing matching font. Join by `verse_key`, never row order. This sidecar changes no canonical schema, content version, user database, or ASR index. Runtime verifies its pinned SHA-256, reads it once off the UI thread, closes SQLite, and retains only the glyph lookup.

- ZIP SHA-256: `3e18dc1d5152358fb253d8e3183253ffb3c79f1f9f1e27d0fa21872f66eda3c0`
- SQLite SHA-256: `04c5d8f1df4f694983bbb4acfd9cd3c4a5f7f0a007927372ad9b6148bd1b9fa0`
- Restore locally: `unzip -p /path/to/qpc-v1-ayah-by-ayah-glyphs.db.zip qpc-v1-ayah-by-ayah-glyphs.db > apps/mobile/assets/db/qpc-v1-ayah-by-ayah-glyphs.db`

Canonical `ayah.text_uthmani` remains the source for copying, sharing, search, and accessibility. Glyph strings are presentation data only. The supplied source assigns one page to every ayah; future multi-page exports require explicit segments rather than guessing a font.
