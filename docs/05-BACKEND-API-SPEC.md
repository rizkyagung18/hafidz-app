# 05 — Backend (BFF) API Specification

**Current Qur'an and live voice contract:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md). Planned legacy content proxies below are deferred and must not fetch Qur'an content from non-QUL providers.

Base URL: `https://api.example.com` (replace with the owned deployment domain before release) · `http://localhost:8000` (dev). All paths prefixed with `/v1`.
Machine-readable contract: [`docs/api/openapi.yaml`](api/openapi.yaml) — keep both in sync. FastAPI also serves
`/docs` (Swagger) and `/openapi.json` in non-prod.

## 1. Conventions

| Topic | Rule |
|---|---|
| Format | JSON UTF-8; `snake_case` fields; times ISO-8601 with offset; ayah key `"{surah}:{ayah}"` |
| Headers (request) | `X-Device-Id: <uuid>` (required), `Accept-Language: id|en`, `X-App-Version: 1.0.0+12` |
| Headers (response) | `X-Request-Id`, `Cache-Control`, `ETag` on cacheable GETs |
| Errors | RFC 7807 `application/problem+json`: `{type, title, status, detail, code, request_id}` |
| Rate limit | 429 with `Retry-After`; voice: 10/min + 200/day per device; others 120/min |
| Auth | v1 anonymous (device id). Phase 2: Bearer JWT for sync endpoints |
| Pagination | `?limit=&cursor=` → `{items, next_cursor}` |

### Error codes

| `code` | HTTP | Meaning |
|---|---|---|
| `AUDIO_TOO_SHORT` | 422 | < 1 s of audio |
| `AUDIO_TOO_LONG` | 413 | > 30.5 s or > 2 MB |
| `AUDIO_UNSUPPORTED` | 415 | Cannot decode |
| `AUDIO_SILENT` | 422 | RMS below threshold / no speech |
| `NOT_FOUND` | 404 | Resource (surah/city) not found |
| `UPSTREAM_UNAVAILABLE` | 503 | All providers failed; client should use offline fallback |
| `RATE_LIMITED` | 429 | Too many requests |
| `VALIDATION_ERROR` | 400 | Bad params |

## 2. Endpoints

### 2.1 Voice Ayah Finder

`POST /v1/voice/detect` — `multipart/form-data`

| Field | Type | Req | Notes |
|---|---|---|---|
| `audio` | file | ✓ | wav / ogg-opus / m4a / mp3 / webm, ≤ 2 MB, 1–30 s |
| `hint_surah` | int 1–114 | | Surah currently open in reader (tie-breaker) |
| `locale` | `id`/`en` | | Language for `surah_name_translation` |
| `max_candidates` | int 1–5 | | default 5 |

200 response: see docs/03 §6. Schema `VoiceDetectResponse`:

```text
request_id: str
transcript: str                  # normalized-for-display ASR text (not Qur'an text!)
confidence: float 0..1
margin: float
ambiguous: bool
reason: null | "too_short" | "basmala_only" | "identical_ayat" | "low_confidence"
best: AyahMatch | null
candidates: AyahMatch[]
thresholds: {auto, min, margin}
timing_ms: {decode, asr, match, total}

AyahMatch:
  key: "2:255" | "2:255-256"
  surah, ayah_start, ayah_end, page, juz: int
  surah_name_arabic, surah_name_latin: str
  surah_name_translation: str | null   # null until a QUL meaning source is selected
  score: float
  match_span: {ayah:int, word_start:int, word_end:int} | null
```

### 2.1a Live Voice Finder WebSocket

`WS /v1/voice/live?hint_surah=1..114` requires `X-Device-Id: <uuid>`. The server sends
`{"type":"ready","sequence":0,"sample_rate":16000,"format":"pcm_s16le_mono"}`
before accepting audio. The client then sends ordered binary PCM16LE mono frames of
0.5–1 second (maximum 32,000 bytes per frame), or `{"type":"stop"}` to finish.

Server JSON events have increasing `sequence`: `candidate`, `ayah`, `ambiguous`,
`error`, and `stopped`. A stable `ayah` also has an increasing session-local
`revision`, `surah`, `ayah_start`, `ayah_end`, and `confidence` in 0..1.
`candidate` and `ambiguous` never move the reader. The optional response `page`
is informational; mobile resolves the canonical ayah range against its installed
QUL edition. Errors end the session: `INVALID_PCM_FRAME`, `INVALID_COMMAND`,
`BACKPRESSURE`, `SESSION_EXPIRED`, or `INFERENCE_FAILED`. Invalid headers or
query values close with 4400; rate or concurrent-session limits close with 4429.
The server starts matching after 1.5 seconds of audio, schedules another window
after each further second when inference capacity is available, and retains at
most four seconds of rolling audio per session. It permits one
inference per session and limits process-wide simultaneous inferences to the
configured ASR worker count. A session lasts at most 180 seconds. Audio and
transcripts are processed in memory and are not persisted or logged.

WebSockets are outside this project's REST OpenAPI file; this section and
[docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) define the live protocol.

### 2.2 Qur'an content (cached proxy; the app normally uses the bundled DB)

These endpoints are unimplemented roadmap placeholders. If implemented during the QUL-only phase, they must use the pinned QUL corpus; Latin and tafsir fields/endpoints are unavailable until QUL sources are selected.

| Method & path | Description | Cache |
|---|---|---|
| `GET /v1/quran/surahs` | 114 surahs metadata | 30 d |
| `GET /v1/quran/surahs/{n}?include=translation,latin,audio&qari=05` | Surah with ayat | 30 d |
| `GET /v1/quran/ayah/{key}` | Single ayah (+page, juz, translation, audio urls) | 30 d |
| `GET /v1/quran/page/{page}` | Ayat on Madani page 1–604 | 30 d |
| `GET /v1/quran/tafsir/{surah}` | Kemenag tafsir for surah | 30 d |
| `GET /v1/quran/reciters` | Curated reciters with URL templates | 1 d |
| `GET /v1/quran/search?q=&lang=id&limit=20` | Text search (Arabic normalized or translation) | 1 d |
| `GET /v1/quran/db/manifest` | `{version, sha256, url, size}` of latest offline DB bundle | 1 h |

`GET /v1/quran/reciters` response item:

```json
{"id":"alafasy","name":"Mishary Rashid Alafasy","style":"murattal",
 "ayah_url_template":"https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3",
 "surah_url_template":"https://cdn.equran.id/audio-full/Misyari-Rasyid-Al-Afasi/{sss}.mp3",
 "fallback_ayah_url_template":"https://cdn.equran.id/audio-partial/Misyari-Rasyid-Al-Afasi/{sss}{aaa}.mp3"}
```

### 2.3 Prayer times

| Method & path | Description |
|---|---|
| `GET /v1/prayer/locations/provinces` | Indonesian provinces |
| `GET /v1/prayer/locations/cities?province=Jawa%20Barat` | Kab/kota list |
| `GET /v1/prayer/locations/search?q=bogor` | City search (returns our `location_id`) |
| `GET /v1/prayer/locations/reverse?lat=&lng=` | Nearest Indonesian kab/kota for GPS |
| `GET /v1/prayer/times?location_id=&year=&month=` | Monthly schedule (Kemenag for ID) |
| `GET /v1/prayer/times?lat=&lng=&year=&month=&method=20&school=0&tz=Asia/Jakarta` | Monthly schedule by coordinates (Aladhan) |

Response:

```json
{
  "location": {"id":"id-jabar-kota-bogor","name":"Kota Bogor","province":"Jawa Barat","tz":"Asia/Jakarta","lat":-6.595,"lng":106.816},
  "source": "kemenag:equran",
  "method": {"id": 20, "name": "KEMENAG", "school": 0, "ihtiyat_min": 2},
  "days": [
    {"date":"2026-09-28","hijri":"1448-04-17",
     "times":{"imsak":"04:15","subuh":"04:25","terbit":"05:36","dhuha":"06:03","dzuhur":"11:47","ashar":"14:54","maghrib":"17:51","isya":"18:59"}}
  ]
}
```

`source` ∈ `kemenag:equran | kemenag:myquran | aladhan | calc`. The app caches 2 months ahead for offline adzan scheduling.

### 2.4 Calendar, qibla, content

| Method & path | Description | Upstream |
|---|---|---|
| `GET /v1/hijri/convert?date=2026-09-28` | Gregorian → Hijri | Aladhan `/gToH` |
| `GET /v1/hijri/calendar?year=2026&month=9` | Month with Hijri dates | Aladhan `/gToHCalendar` |
| `GET /v1/hijri/holidays?hijri_year=1448` | Islamic holidays | Aladhan |
| `GET /v1/qibla?lat=&lng=` | Bearing (computed locally; Aladhan for validation) | — |
| `GET /v1/doa?grup=&tag=` , `GET /v1/doa/{id}` | Du'a & dzikir | equran.id |
| `GET /v1/hadith/books` | Kitab list | gading.dev → fawazahmed0 |
| `GET /v1/hadith/{book}?from=1&to=50` | Range (≤ 300) | same |
| `GET /v1/hadith/{book}/{number}` | Single hadith | same |
| `GET /v1/asmaul-husna` | 99 names | bundled / Aladhan |

### 2.5 Ops

| Path | Description |
|---|---|
| `GET /healthz` | Liveness |
| `GET /readyz` | Planned readiness endpoint; not implemented yet. Do not use for current local checks. |
| `GET /metrics` | Prometheus (internal network only) |

## 3. Server configuration (`.env.example`)

```dotenv
APP_ENV=dev
LOG_LEVEL=INFO
REDIS_URL=redis://localhost:6379/0
ASR_MODEL_DIR=/models/whisper-base-ar-quran-ct2-int8
ASR_CPU_THREADS=2
ASR_NUM_WORKERS=2
ASR_BEAM_SIZE=5
QURAN_INDEX_PATH=/data/quran_index.pkl
QURAN_DB_PATH=/data/quran.sqlite
MATCH_AUTO_THRESHOLD=0.80
MATCH_MIN_THRESHOLD=0.55
MATCH_MIN_MARGIN=0.10
VOICE_MAX_BYTES=2097152
VOICE_MAX_SECONDS=30.5
QF_ENV=prelive                   # prelive | production
QF_CLIENT_ID=
QF_CLIENT_SECRET=
EQURAN_BASE_URL=https://equran.id
MYQURAN_BASE_URL=https://api.myquran.com
ALADHAN_BASE_URL=https://api.aladhan.com/v1
HADITH_PRIMARY_URL=https://api.hadith.gading.dev
HADITH_FALLBACK_URL=https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1
PRAYER_IHTIYAT_MIN=2
RATE_LIMIT_VOICE_PER_MIN=10
RATE_LIMIT_VOICE_PER_DAY=200
SENTRY_DSN=
STORE_AUDIO_OPT_IN=false
```

## 4. FastAPI skeleton

```python
# app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.asr.model import QuranAsr
from app.matching.index import QuranIndex
from app.settings import settings
from app.routers import voice, quran, prayer, hijri, doa, hadith, health

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.asr = QuranAsr(settings.asr_model_dir, settings.asr_cpu_threads, settings.asr_num_workers)
    app.state.index = QuranIndex.load(settings.quran_index_path)   # verifies sha256
    app.state.asr.warmup()
    yield

app = FastAPI(title="Hafidz App BFF", version="1.0.0", lifespan=lifespan)
for r in (voice, quran, prayer, hijri, doa, hadith, health):
    app.include_router(r.router)
```

```python
# app/routers/voice.py
from fastapi import APIRouter, UploadFile, File, Form, Request, Depends
from anyio import to_thread
router = APIRouter(prefix="/v1/voice", tags=["voice"])

@router.post("/detect", response_model=VoiceDetectResponse)
async def detect(request: Request, audio: UploadFile = File(...),
                 hint_surah: int | None = Form(None, ge=1, le=114),
                 locale: str = Form("id"), max_candidates: int = Form(5, ge=1, le=5),
                 _rl = Depends(voice_rate_limit)):
    raw = await read_limited(audio, settings.voice_max_bytes)      # raises AUDIO_TOO_LONG
    pcm = decode_to_pcm16k(raw)                                     # raises AUDIO_UNSUPPORTED / TOO_SHORT / SILENT
    del raw
    asr_res = await to_thread.run_sync(request.app.state.asr.transcribe, pcm)
    del pcm                                                         # never persisted
    result = request.app.state.index.match(asr_res, hint_surah=hint_surah, top_k=max_candidates)
    return build_response(asr_res, result, locale)
```
