# 04 — External API & Data Catalog

**Current Qur'an-source decision:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) defines the current Qur'an content boundary. Only pinned QUL sources may feed the new database, fonts, and future Murattal. No external Qur'an API or font fallback is used. Non-Qur'an daily-needs providers and the independent Tarteel ASR model remain in scope.

API endpoints below were checked against official docs and/or live requests on 2026-09-28.
The QUL resource documentation in §13 was checked on 2026-09-30; the current local imports are pinned in the source locks and docs/06.
Free community APIs have **no SLA** — every runtime provider must have a fallback (§11) and responses must be cached in the BFF.

Legend — **Auth:** none / key / OAuth2. **Used by:** `APP` = mobile calls directly, `BFF` = backend proxy only.

## Summary

| # | Provider | Purpose | Auth | Used by | Role |
|---|---|---|---|---|---|
| 2 | EQuran.id | Prayer schedules and du'a | none | BFF | Daily-needs data only |
| 4 | Aladhan | Prayer times worldwide (incl. method 20 = KEMENAG), Hijri calendar, qibla, asmaul husna | none | BFF | Prayer fallback / non-ID locations, Hijri |
| 5 | myQuran API (v2/v3) | Kemenag jadwal sholat by kota id, Hijri, qibla | none | BFF | Fallback prayer schedule for ID |
| 8 | Hadith API (gading.dev) | 9 kitab hadith with Indonesian translation | none | BFF | Hadith primary |
| 9 | fawazahmed0/hadith-api (jsDelivr) | Hadith editions incl. Indonesian (`ind-*`) | none | BFF | Hadith fallback |
| 11 | Hugging Face Hub | `tarteel-ai/whisper-base-ar-quran` weights | none (public) | build tools | ASR model |
| 12 | QUL (Tarteel) | Canonical text, Indonesian translation, metadata, V1 layout, word/ayah glyphs, page fonts | Local downloads | build tools + app assets | Exclusive Qur'an content/font source; see §13 |

---

## 2. EQuran.id — prayer and du'a only

Docs: <https://equran.id/apidev> · v2: <https://equran.id/apidev/v2> · Shalat: <https://equran.id/apidev/shalat> ·
Doa: <https://equran.id/apidev/doa>. Source data: Kemenag RI (quran.kemenag.go.id). 24 h CDN cache. No auth.

| Method | URL | Notes |
|---|---|---|
| GET | `https://equran.id/api/v2/shalat/provinsi` | Province list |
| POST | `https://equran.id/api/v2/shalat/kabkota` body `{"provinsi":"Jawa Barat"}` | Kab/kota list (517 kab/kota, 34 provinces) |
| POST | `https://equran.id/api/v2/shalat` body `{"provinsi","kabkota","bulan","tahun"}` | Monthly schedule: `imsak, subuh, terbit, dhuha, dzuhur, ashar, maghrib, isya` |
| GET | `https://equran.id/api/doa?grup=&tag=` , `https://equran.id/api/doa/{id}` | Doa & dzikir (ids 1–228): `grup, nama, ar, tr, idn, tentang, tag[]` |

Response wrapper: `{ "code": 200, "message": "...", "data": ... }` (doa uses `{ "status": "success", "data": ... }`).

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

## 10. Hugging Face model

`tarteel-ai/whisper-base-ar-quran` (Apache-2.0): <https://huggingface.co/tarteel-ai/whisper-base-ar-quran>.
Downloaded at image build time only (docs/03 §2.1); production pods never call HF.

---

## 11. Provider fallback matrix

| Capability | Primary | Fallback 1 | Fallback 2 (offline) |
|---|---|---|---|
| Surah/ayah text + ID translation | Bundled pinned QUL SQLite | — | Same local QUL corpus |
| Tafsir (ID) | Deferred until a QUL source is chosen | — | — |
| Ayah audio | Deferred QUL recitation source | — | — |
| Surah audio | Deferred QUL recitation source | — | — |
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

## 13. QUL — Qur'an content and Madinah 1405H presentation

Status: local semantic and print imports are implemented; redistribution rights and remaining offline/performance proof are pending.
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

The current renderer uses the prescribed line membership and alignment with matching V1 glyphs/fonts.
Pressable ayah regions will be measured from the rendered glyphs and grouped by canonical ayah; the same geometry
will drive highlight overlays. This is an application design choice, not a claim that QUL supplies bounding boxes.
No edition-matched complete page-image pack or pixel-coordinate dataset has been verified. Do not substitute
unverified images, V2 fonts, generic Unicode rendering, or freely wrapped paragraphs for this edition.
The [official layout tutorial](https://qul.tarteel.ai/docs/tutorial-mushaf-layout-end-to-end) explains the line/word joins.

Before implementation, record exact download URLs, artifact versions or retrieval dates, SHA-256 hashes,
actual schemas, font coverage and compressed/uncompressed sizes. Keep QUL presentation identifiers separate from
the application's stable `surah:ayah` and global ayah IDs. Canonical QUL Uthmani remains the source for copy/share, accessibility text and search. The Surah reader uses the supplied QPC V1 ayah-by-ayah SQLite and matching fonts; glyph codes are presentation data only. See docs/06 for its schema, hashes, and local staging command.

Resource-specific licensing evidence is unresolved. The [QUL FAQ](https://qul.tarteel.ai/faq) states that terms vary
by resource. Pin the applicable license and attribution evidence for all three resources before redistribution;
QUL's CMS software license does not establish rights to its font/content downloads. See docs/10 §4.1.
