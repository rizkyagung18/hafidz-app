# 06 — Data Model

Two SQLite databases on device (drift), plus an in-memory index on the server.

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
-- rows: db_version, built_at, tanzil_version, sources_json, sha256

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
  text_uthmani  TEXT NOT NULL,                    -- VERBATIM Tanzil Uthmani — never modified
  text_simple   TEXT NOT NULL,                    -- VERBATIM Tanzil Simple Clean
  text_norm     TEXT NOT NULL,                    -- normalize_ar(text_simple) — search only, never displayed
  text_latin    TEXT,                             -- Kemenag transliteration (equran teksLatin)
  translation_id TEXT NOT NULL,                   -- Kemenag Indonesian (equran teksIndonesia)
  translation_en TEXT,                            -- optional (e.g. Saheeh International via Quran Foundation, check license)
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
- `page` and `juz` from alquran.cloud equal the corresponding full-Qur'an boundaries in Tanzil `quran-data.xml` for all ayat (cross-source check). Tanzil metadata has no hizb-quarter boundaries; alquran.cloud supplies `hizbQuarter`, which is range-checked (1..240). Quran Foundation pre-live only exposes surahs 1–2, so a full-Qur'an Quran Foundation page comparison is an optional release check after production access is approved.
- SHA-256 of Tanzil source files matches the pinned value in `tools/build_quran_db/sources.lock.json`.
- Spot checks: `2:255 → page 42, juz 3`; `1:1 → page 1`; `114:6 → page 604`; `18:1 → juz 15`.

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
