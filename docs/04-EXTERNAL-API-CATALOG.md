# 04 — External API & Data Catalog

**Current Qur'an-source decision:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) supersedes the historical provider catalog below for Qur'an content. Only pinned QUL sources may feed the new database, fonts, and future Murattal. Tanzil, EQuran, AlQuran.cloud, and Quran Foundation are not fallback content providers. Non-Qur'an daily-needs providers and the independent Tarteel ASR model remain in scope.

API endpoints below were checked against official docs and/or live requests on 2026-09-28.
The QUL resource documentation in §13 was checked on 2026-09-30; its downloadable artifacts have not yet been audited.
Free community APIs have **no SLA** — every runtime provider must have a fallback (§11) and responses must be cached in the BFF.

Legend — **Auth:** none / key / OAuth2. **Used by:** `APP` = mobile calls directly, `BFF` = backend proxy only.

## Summary

| # | Provider | Purpose | Auth | Used by | Role |
|---|---|---|---|---|---|
| 1 | Quran Foundation (Quran.com) Content API v4 | Verses, scripts, translations, tafsir, recitations, page/juz metadata, search | OAuth2 client credentials | BFF | Primary Qur'an content (international) |
| 2 | EQuran.id API v2 | Surah + ayah (Arabic, Latin, Indonesian Kemenag), tafsir, audio 6 qari, **jadwal shalat**, **doa** | none | BFF | Primary for Indonesian content |
| 3 | AlQuran.cloud | Full Qur'an editions (text + audio), page/juz/hizb metadata | none | BFF + build tools | Fallback content + DB build |
| 4 | Aladhan | Prayer times worldwide (incl. method 20 = KEMENAG), Hijri calendar, qibla, asmaul husna | none | BFF | Prayer fallback / non-ID locations, Hijri |
| 5 | myQuran API (v2/v3) | Kemenag jadwal sholat by kota id, Hijri, qibla | none | BFF | Fallback prayer schedule for ID |
| 6 | EveryAyah | Per-ayah MP3 files for 50+ reciters | none | APP (stream) | Primary ayah-by-ayah audio |
| 7 | MP3Quran.net API v3 | Reciters, full-surah MP3s, riwayat, ayat timing, radios | none | BFF (list) + APP (stream) | Full-surah audio catalog |
| 8 | Hadith API (gading.dev) | 9 kitab hadith with Indonesian translation | none | BFF | Hadith primary |
| 9 | fawazahmed0/hadith-api (jsDelivr) | Hadith editions incl. Indonesian (`ind-*`) | none | BFF | Hadith fallback |
| 10 | Tanzil | Verified Qur'an text files (Uthmani, Simple Clean) | none (download) | build tools | Bundled offline text |
| 11 | Hugging Face Hub | `tarteel-ai/whisper-base-ar-quran` weights | none (public) | build tools | ASR model |
| 12 | QUL (Tarteel) | KFGQPC V1 1405H layout, word glyphs, page fonts | Download workflow; no public resource API | build tools (planned) | Faithful Mushaf presentation; see §13 |

---

## 1. Quran Foundation — Content API v4 (Quran.com)

Docs: <https://api-docs.quran.foundation> · LLM index: <https://api-docs.quran.foundation/llms.txt> ·
OpenAPI: <https://api-docs.quran.foundation/openAPI/content/v4.json>

| Item | Pre-live (dev/staging) | Production |
|---|---|---|
| Token URL | `https://prelive-oauth2.quran.foundation/oauth2/token` | `https://oauth2.quran.foundation/oauth2/token` |
| API base | `https://apis-prelive.quran.foundation` | `https://apis.quran.foundation` |
| Content prefix | `/content/api/v4` | `/content/api/v4` |
| Dataset | **Only surah 1 and 2** in pre-live | Full Qur'an (after production approval) |

Auth flow (**server-side only**, never in the app):

```bash
curl -X POST https://prelive-oauth2.quran.foundation/oauth2/token \
  --user "$QF_CLIENT_ID:$QF_CLIENT_SECRET" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=client_credentials&scope=content'
# → {"access_token":"…","expires_in":3600,"token_type":"bearer","scope":"content"}

curl https://apis-prelive.quran.foundation/content/api/v4/chapters \
  -H "x-auth-token: $ACCESS_TOKEN" -H "x-client-id: $QF_CLIENT_ID"
```

- Token lifetime 3600 s, no refresh token → cache in Redis until `expires_in − 60 s`; on 401 clear + re-request once.
- 403 = wrong env / missing `content` scope (don't retry loop). 429 → exponential backoff with jitter.
- Official JS SDK exists (`@quranjs/api`); in our Python BFF implement a thin client.

Endpoints we use (relative to `/content/api/v4`):

| Endpoint | Purpose |
|---|---|
| `GET /chapters?language=id` | Surah list |
| `GET /chapters/{id}` , `GET /chapters/{id}/info` | Surah detail / intro |
| `GET /verses/by_key/{surah:ayah}?translations={id}&fields=text_uthmani,page_number,juz_number` | Single ayah |
| `GET /verses/by_page/{page}` | All ayat on a Madani page |
| `GET /verses/by_chapter/{id}` , `/verses/by_juz/{n}` | Ranges |
| `GET /quran/verses/uthmani?chapter_number=` | Uthmani script bulk |
| `GET /resources/translations` , `/resources/tafsirs` , `/resources/recitations` | Resource ids (pick Indonesian ids at runtime, don't hardcode) |
| `GET /recitations/{recitation_id}/by_ayah/{key}` | Ayah audio for a reciter |
| `GET /chapter_recitations/{reciter_id}/{chapter}` | Full chapter audio |
| Search API v1 (separate spec) | Full-text search across Arabic + translations |

## 2. EQuran.id API v2 (Kemenag data) — Indonesian primary

Docs: <https://equran.id/apidev> · v2: <https://equran.id/apidev/v2> · Shalat: <https://equran.id/apidev/shalat> ·
Doa: <https://equran.id/apidev/doa>. Source data: Kemenag RI (quran.kemenag.go.id). 24 h CDN cache. No auth.

| Method | URL | Notes |
|---|---|---|
| GET | `https://equran.id/api/v2/surat` | 114 surah, each with `audioFull` (6 qari) |
| GET | `https://equran.id/api/v2/surat/{nomor}` | Surah + `ayat[]`: `nomorAyat`, `teksArab`, `teksLatin`, `teksIndonesia`, `audio{"01".."06"}` |
| GET | `https://equran.id/api/v2/tafsir/{nomor}` | Tafsir Kemenag per ayah |
| GET | `https://equran.id/api/v2/shalat/provinsi` | Province list |
| POST | `https://equran.id/api/v2/shalat/kabkota` body `{"provinsi":"Jawa Barat"}` | Kab/kota list (517 kab/kota, 34 provinces) |
| POST | `https://equran.id/api/v2/shalat` body `{"provinsi","kabkota","bulan","tahun"}` | Monthly schedule: `imsak, subuh, terbit, dhuha, dzuhur, ashar, maghrib, isya` |
| GET | `https://equran.id/api/doa?grup=&tag=` , `https://equran.id/api/doa/{id}` | Doa & dzikir (ids 1–228): `grup, nama, ar, tr, idn, tentang, tag[]` |

Response wrapper: `{ "code": 200, "message": "...", "data": ... }` (doa uses `{ "status": "success", "data": ... }`).

Audio qari keys (both full-surah and per-ayah CDN):

| Key | Qari | Per-ayah URL pattern |
|---|---|---|
| 01 | Abdullah Al-Juhany | `https://cdn.equran.id/audio-partial/Abdullah-Al-Juhany/{SSS}{AAA}.mp3` |
| 02 | Abdul Muhsin Al-Qasim | `…/Abdul-Muhsin-Al-Qasim/{SSS}{AAA}.mp3` |
| 03 | Abdurrahman as-Sudais | `…/Abdurrahman-as-Sudais/…` |
| 04 | Ibrahim Al-Dossari | `…/Ibrahim-Al-Dossari/…` |
| 05 | Misyari Rasyid Al-Afasi | `…/Misyari-Rasyid-Al-Afasi/…` |
| 06 | Yasser Al-Dosari | `…/Yasser-Al-Dosari/…` |

Full surah: `https://cdn.equran.id/audio-full/{Qari}/{SSS}.mp3`.

## 3. AlQuran.cloud

Docs: <https://alquran.cloud/api> (legacy page <https://legacy.alquran.cloud/api>). Bases: `https://api.alquran.cloud`,
mirror `https://alquran.api.islamic.network`. GET only, JSON, supports gzip/zstd.

| Endpoint | Purpose |
|---|---|
| `/v1/edition?format=&language=&type=` | List editions (text/audio/translation/tafsir) |
| `/v1/quran/{edition}` | Whole Qur'an in one call (e.g. `quran-uthmani`, `id.indonesian`, `ar.alafasy`) — **used by DB build** |
| `/v1/surah/{n}/{edition}` , `/v1/juz/{n}/{edition}` , `/v1/page/{n}/{edition}` | Ranges |
| `/v1/ayah/{ref}/{edition}` (`ref` = `2:255` or global 262) | Single ayah |
| `/v1/search/{keyword}/{surah|all}/{edition}` | Keyword search |

Ayah objects include `number` (global 1..6236), `numberInSurah`, `juz`, `manzil`, `page` (Madani 604), `ruku`,
`hizbQuarter`, `sajda`. Verified: `2:255` → `page: 42, juz: 3`.

## 4. Aladhan (prayer times, Hijri, qibla, asmaul husna)

Site/API: <https://aladhan.com> · OpenAPI: <https://api.aladhan.com/v1/documentation/openapi/prayer-times/yaml>.
Base `https://api.aladhan.com/v1`. No auth. Open source.

| Endpoint | Purpose |
|---|---|
| `GET /timings/{DD-MM-YYYY}?latitude=&longitude=&method=20&school=0&timezonestring=Asia/Jakarta` | Daily times |
| `GET /calendar/{year}/{month}?latitude=&longitude=&method=20` | Monthly calendar |
| `GET /timingsByCity/{date}?city=&country=&method=` , `/calendarByCity/{y}/{m}` | By city |
| `GET /methods` | Calc methods — **`KEMENAG` id 20** (Kementerian Agama RI), `JAKIM` 17, `SINGAPORE` 11, `MWL` 3, … |
| `GET /gToH/{DD-MM-YYYY}` , `/hToG/{DD-MM-YYYY}` , `/gToHCalendar/{m}/{y}` | Hijri conversion |
| `GET /islamicHolidaysByHijriYear/{year}` , `/currentIslamicMonth` | Holidays |
| `GET /qibla/{lat}/{lng}` | Qibla bearing (Jakarta −6.2, 106.8 → 295.16°) |
| `GET /asmaAlHusna` , `/asmaAlHusna/{1..99}` | 99 names |

`school`: 0 = Shafi'i (default for Indonesia), 1 = Hanafi. Use `tune=` for ihtiyat offsets if needed.

> Observed 2026-09-28, Jakarta (−6.2, 106.8): Aladhan method 20 Fajr **04:22**, Dhuhr 11:44, Maghrib 17:48 vs
> myQuran (Kemenag, Kota Jakarta) Subuh **04:25**, Dzuhur 11:47, Maghrib 17:51. Kemenag schedules include ~2–3 min
> ihtiyat. When calculating (Aladhan or on-device), apply a configurable ihtiyat (`tune`, default +2 min for all
> prayers except terbit −2) and validate against Kemenag data in tests (≤ 2 min tolerance, PRD §2).

## 5. myQuran API (Kemenag Bimas Islam schedules)

Home: <https://api.myquran.com> (v3 recommended, v2 legacy still live). No auth. Community support on Telegram.

Verified v2 endpoints:

| Endpoint | Example |
|---|---|
| `GET https://api.myquran.com/v2/sholat/kota/cari/{keyword}` | `/kota/cari/jakarta` → `{"id":"1301","lokasi":"KOTA JAKARTA"}` |
| `GET https://api.myquran.com/v2/sholat/kota/semua` | All kota ids |
| `GET https://api.myquran.com/v2/sholat/jadwal/{kotaId}/{YYYY-MM-DD}` | Daily: `imsak, subuh, terbit, dhuha, dzuhur, ashar, maghrib, isya` |
| `GET https://api.myquran.com/v2/sholat/jadwal/{kotaId}/{YYYY}/{MM}` | Monthly |

v3 docs: <https://api.myquran.com/v3/doc> (jadwal sholat, kalender Hijriah, arah kiblat). Implement v2 first; migrate to v3
behind the same client interface once response shapes are confirmed.

## 6. EveryAyah (per-ayah audio)

Site: <https://everyayah.com/recitations_ayat.html>. Pattern:

```
https://everyayah.com/data/{ReciterFolder}/{SSS}{AAA}.mp3      e.g. https://everyayah.com/data/Alafasy_128kbps/002255.mp3
```

Example folders: `Alafasy_128kbps`, `Abdul_Basit_Murattal_192kbps`, `Abdurrahmaan_As-Sudais_192kbps`,
`Husary_128kbps`, `Husary_128kbps_Mujawwad`, `Minshawy_Murattal_128kbps`, `Abdullah_Basfar_192kbps`.
Keep a curated `reciters.json` (id, display name, folder, bitrate, style) in the app; verify each folder at build time
with a HEAD request on `001001.mp3`. Also the best source to build the **ASR golden set** (docs/09).

## 7. MP3Quran.net API v3

Docs: <https://www.mp3quran.net/eng/api>. Base `https://mp3quran.net/api/v3`. No auth. `language` param: `ar`, `eng`, `id`, …

| Endpoint | Purpose |
|---|---|
| `/reciters?language=id[&reciter={id}]` | Reciters with `moshaf[]` (`server`, `surah_list`, `moshaf_type`) |
| `/suwar?language=id` , `/riwayat` , `/languages` | Metadata |
| `/ayat_timing?surah={n}&read={id}` , `/ayat_timing/reads` , `/ayat_timing/soar?read=` | Ayah timestamps inside full-surah files (for follow-along highlight) |
| `/radios?language=id` , `/live-tv` | Qur'an radio / Makkah & Madinah live |
| `/tafasir` , `/tafsir?tafsir=&sura=` | Audio tafsir |

Audio URL: `{moshaf.server}{SSS}.mp3` (surah zero-padded to 3 digits).

## 8. Hadith

**Primary — gading.dev** (<https://github.com/gadingnst/hadith-api>, deployed at `https://api.hadith.gading.dev`):

| Endpoint | Purpose |
|---|---|
| `GET /books` | List of 9 kitab |
| `GET /books/{name}?range={a}-{b}` | Range (max 300 per call) — e.g. `/books/muslim?range=1-150` |
| `GET /books/{name}/{number}` | Single hadith, e.g. `/books/bukhari/52` |

Observed intermittent connection failures from our test environment — treat as **best-effort**, cache aggressively
(7 d), and prefer self-hosting (repo is open source).

**Fallback — fawazahmed0/hadith-api** via jsDelivr CDN:
`https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions.json`,
`https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/{edition}/{number}.json`.
Indonesian editions: `ind-bukhari`, `ind-muslim`, `ind-abudawud`, `ind-tirmidhi`, `ind-nasai`, `ind-ibnmajah`, `ind-malik`.

## 9. Tanzil (bundled Qur'an text)

Download: <https://tanzil.net/download/>. License: <https://tanzil.net/docs/text_license> — CC BY 3.0; verbatim copies only
(changing the text is not allowed), must credit "Tanzil Project" and link to tanzil.net. We use **Uthmani** for display
and **Simple Clean** for the search index variant B (docs/03 §3).

## 10. Hugging Face model

`tarteel-ai/whisper-base-ar-quran` (Apache-2.0): <https://huggingface.co/tarteel-ai/whisper-base-ar-quran>.
Downloaded at image build time only (docs/03 §2.1); production pods never call HF.

---

## 11. Provider fallback matrix

| Capability | Primary | Fallback 1 | Fallback 2 (offline) |
|---|---|---|---|
| Surah/ayah text + ID translation | Bundled SQLite | equran.id v2 | Quran Foundation |
| Tafsir (ID) | equran.id `/tafsir` (cached to device) | Quran Foundation tafsirs | — |
| Ayah audio | EveryAyah | cdn.equran.id audio-partial | Quran Foundation recitations |
| Surah audio | cdn.equran.id audio-full | mp3quran.net | EveryAyah (concatenate playlist) |
| Prayer times (Indonesia) | equran.id `/shalat` (month) | myQuran v2 `/jadwal` | On-device `adhan` calc (KEMENAG params) |
| Prayer times (other countries) | Aladhan `/calendar` (method per country) | — | On-device `adhan` calc |
| Hijri date | Aladhan `/gToH` | myQuran v3 | On-device Umm al-Qura conversion (`hijri` Dart pkg) |
| Qibla | On-device great-circle bearing | Aladhan `/qibla` (validation only) | — |
| Doa | equran.id `/api/doa` (synced to device) | Bundled snapshot | — |
| Hadith | gading.dev | fawazahmed0 hadith-api | Cached pages |
| Asmaul Husna | Bundled JSON (from Aladhan `/asmaAlHusna`) | — | — |

## 12. BFF client conventions (Python)

```python
class ProviderClient(Protocol):
    name: str                       # "equran", "myquran", "aladhan", …
    async def health(self) -> bool: ...

# httpx.AsyncClient(timeout=httpx.Timeout(8.0, connect=3.0), headers={"User-Agent": "HafidzApp/1.0 (+contact@…)"})
# retry: tenacity, stop_after_attempt(3), wait_exponential_jitter(initial=0.5, max=4), retry on 429/5xx/httpx.TransportError
# cache: Redis key f"{provider}:{endpoint}:{sha1(params)}", TTL per docs/02 §7
# circuit breaker: open after 5 consecutive failures, half-open after 30 s
# metrics: provider_requests_total{provider,status}, provider_latency_seconds{provider}
```

Be a good citizen: identify via `User-Agent`, respect cache headers, never hammer free APIs from app clients
directly (all traffic goes through the BFF cache, except static audio CDNs).

## 13. QUL — Madinah 1405H Mushaf resources (planned)

Status: source documentation reviewed; downloads, import, native rendering and validation are **planned**.
See the [redesign plan](11-MUSHAF-1405H-REDESIGN.md) and
[ADR-006](adr/ADR-006-madinah-1405h-mushaf.md). QUL provides downloadable resources for packaging with a project;
it currently has [no public resource API](https://qul.tarteel.ai/resources). Reading must use local verified assets.

The selected resources are the compatible trio linked by the official layout page:

- [Layout 15 — KFGQPC V1 layout (1405H print)](https://qul.tarteel.ai/resources/mushaf-layout/15):
  604 pages, nominally 15 lines; SQLite and DOCX offered. Its documented `pages` rows describe
  `page_number`, `line_number`, `line_type`, `is_centered`, `first_word_id`, `last_word_id`, and `surah_number`.
  Preserve source-driven opening-page exceptions rather than forcing 15 occupied rows everywhere.
- [Script 57 — QPC V1 Glyphs, Word by Word](https://qul.tarteel.ai/resources/quran-script/57):
  SQLite and JSON offered. Layout help describes a `words` table joined by `word_index`, with canonical surah/ayah
  references and glyph text. Inspect the actual export schema, word identifiers and ayah end-marker records before import.
- [Font 238 — QPC V1 Font](https://qul.tarteel.ai/resources/font/238): page fonts offered in TTF, WOFF and WOFF2.
  Evaluate TTF for the native Flutter renderer; confirm every page's font association from the downloaded package.

The proposed renderer uses the prescribed line membership and alignment with matching V1 glyphs/fonts.
Pressable ayah regions will be measured from the rendered glyphs and grouped by canonical ayah; the same geometry
will drive highlight overlays. This is an application design choice, not a claim that QUL supplies bounding boxes.
No edition-matched complete page-image pack or pixel-coordinate dataset has been verified. Do not substitute
unverified images, V2 fonts, generic Unicode rendering, or freely wrapped paragraphs for this edition.
The [official layout tutorial](https://qul.tarteel.ai/docs/tutorial-mushaf-layout-end-to-end) explains the line/word joins.

Before implementation, record exact download URLs, artifact versions or retrieval dates, SHA-256 hashes,
actual schemas, font coverage and compressed/uncompressed sizes. Keep QUL presentation identifiers separate from
the application's stable `surah:ayah` and global ayah IDs. Canonical Tanzil text remains the source for list mode,
copy/share, accessibility text and search; glyph codes are presentation data only.

Resource-specific licensing evidence is unresolved. The [QUL FAQ](https://qul.tarteel.ai/faq) states that terms vary
by resource. Pin the applicable license and attribution evidence for all three resources before redistribution;
QUL's CMS software license does not establish rights to its font/content downloads. See docs/10 §4.1.
