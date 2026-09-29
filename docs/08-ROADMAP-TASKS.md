# 08 — Roadmap & Agent Task Breakdown

Each task is sized for one coding-agent session (≈ 1 PR). Give the agent the task ID, e.g.
"Implement **T-B05** per docs/08-ROADMAP-TASKS.md". Tasks list dependencies (`deps`) and acceptance criteria (AC).

## Milestones

| Milestone | Scope | Exit criteria |
|---|---|---|
| **M0 Foundation** (week 1) | Repo, CI, data build, model conversion | `quran.sqlite` + `quran_index.pkl` built & verified in CI; model converted |
| **M1 AI core** (weeks 2–3) | BFF voice endpoint + matcher + golden eval | Top-1 ≥ 90 % on golden-v1; p95 server latency ≤ 1.5 s |
| **M2 App core** (weeks 3–5) | Flutter shell, Qur'an reader, Voice Ayah Finder UI | End-to-end: record → page highlight on device |
| **M3 Daily needs** (weeks 5–7) | Prayer + adzan, qibla, hijri, doa, murottal | PRD F-03..F-08 ACs pass |
| **M4 Content & polish** (weeks 7–8) | Hadith, tafsir, asmaul husna, tasbih, search, settings, attribution | All P0/P1 ACs; accessibility pass |
| **M5 Beta** (weeks 9–10) | Observability, load test, closed beta (Play Console internal track) | Crash-free ≥ 99.5 %, no P0 bugs |

---

## M0 — Foundation

**T-F01 Monorepo scaffold** — deps: none
- Create layout from AGENTS.md §4; `services/api` with `pyproject.toml` (uv), ruff, mypy, pytest; `apps/mobile` via
  `flutter create --org app.hafidz --platforms android,ios`; `infra/docker-compose.yml` (api + redis).
- GitHub Actions: `api-ci.yml` (ruff, mypy, pytest), `mobile-ci.yml` (flutter analyze, test), `data-ci.yml` (T-F02 verify).
- AC: `docker compose up` serves `GET /healthz → 200`; both CI workflows green.

**T-F02 Qur'an DB builder** — deps: T-F01
- `tools/build_quran_db/build.py`: download pinned Tanzil Uthmani + Simple Clean, alquran.cloud `quran-uthmani`
  (for page/juz/hizb/ruku/manzil/sajda), equran.id v2 surat 1..114 (Latin + Indonesian) and tafsir; write
  `apps/mobile/assets/db/quran.sqlite` using schema docs/06 §1; populate FTS5.
- `verify.py` implements every invariant in docs/06 §1.
- `sources.lock.json` pins URLs + SHA-256; build is reproducible (same inputs ⇒ same DB hash).
- Cross-check AlQuran.cloud page/juz data against full-Qur'an Tanzil metadata; range-check its hizb-quarter data because Tanzil metadata has no hizb-quarter boundaries. A Quran Foundation full-Qur'an check is optional after production access is approved because pre-live only includes surahs 1–2.
- AC: invariants pass; `2:255 → page 42`; DB ≤ 25 MB.

**T-F03 Normalization module** — deps: T-F01
- `services/api/app/matching/normalize.py` exactly as docs/03 §4 + `cleanup_query()` (isti'adha, basmala, sadaqa).
- AC: ≥ 40 unit tests (alef variants, tashkeel removal, Uthmani dagger alef, tatweel, Farsi yeh, ayah-number digits
  removed, idempotence `n(n(x)) == n(x)`).

**T-F04 Search index builder** — deps: T-F02, T-F03
- `tools/build_quran_db/build_index.py`: units (single + 2/3 windows + muqatta'at aliases), char 3-gram TF-IDF,
  word IDF, offsets → `services/api/data/quran_index.pkl` + `.sha256`.
- AC: 6,236 single units; window count correct; load time < 1 s; pickle < 30 MB.

**T-F05 Model conversion** — deps: T-F01
- `tools/convert_model/convert.py` per docs/03 §2.1; Dockerfile stage that runs it and copies output to `/models`.
- AC: faster-whisper loads the dir; transcribing EveryAyah `Alafasy_128kbps/001002.mp3` yields text whose
  normalized form has ratio ≥ 90 vs `الحمد لله رب العالمين`.

## M1 — AI core

**T-A01 Audio decoding** — deps: T-F01
- `app/asr/audio.py`: PyAV decode → 16 kHz mono float32; size/duration/silence validation → Problem errors.
- AC: tests for wav/opus/m4a/mp3 fixtures; `AUDIO_TOO_SHORT`, `AUDIO_TOO_LONG`, `AUDIO_SILENT`, `AUDIO_UNSUPPORTED`.

**T-A02 ASR service** — deps: T-F05, T-A01
- `app/asr/model.py` per docs/03 §2.2, lifespan load + warmup, thread offload.
- AC: concurrent 8 requests don't block `/healthz`; memory < 1 GB.

**T-A03 Matcher** — deps: T-F04
- `app/matching/matcher.py`: stages 1–4 of docs/03 §5; returns `MatchResult`.
- AC: unit tests with synthetic transcripts: exact ayah, partial long ayah (2:282 fragment), 2-ayah span (2:255–256),
  30 % char corruption still top-1, 55:13 refrain ⇒ `ambiguous=true`, basmala-only ⇒ `reason=basmala_only`,
  muqatta'at `الف لام ميم` ⇒ 2:1 among candidates. Match time p95 < 30 ms.

**T-A04 `/v1/voice/detect` endpoint** — deps: T-A02, T-A03
- Router per docs/05 §4, response model, rate limit (Redis), metrics, no audio persistence.
- AC: contract test against `docs/api/openapi.yaml` (schemathesis); audio buffers freed (no temp files left).

**T-A05 Golden set & eval harness** — deps: T-A04
- `services/api/eval/`: build golden-v1 per docs/09 §2 (manifest CSV: `path, surah, ayah_start, ayah_end, condition`),
  `run_eval.py` → metrics JSON + markdown report; threshold tuning script (grid over auto/min/margin).
- AC: report produced in CI (nightly); results committed to `docs/eval/golden-v1-report.md`.

## M2 — App core

**T-M01 App shell** — deps: T-F01
- Theme tokens (docs/07 §8), go_router routes (docs/07 §2), bottom nav, i18n ARB, Riverpod, dio client with
  `X-Device-Id`, error mapping to `AppError`.
- AC: all routes navigable with placeholder screens; dark/light/sepia switch.

**T-M02 Local DB layer** — deps: T-F02, T-M01
- drift definitions for `quran.sqlite` (read-only, copied from assets with version check) and `user.sqlite`.
- Repositories: `QuranRepository` (surahs, ayah by key, page, juz, search), `BookmarkRepository`, `ReadingRepository`.
- AC: unit tests with in-memory DB; `pageOf(AyahRef(2,255)) == 42`.

**T-M03 Surah list & list reader** — deps: T-M02
- AC: PRD F-02 AC1, AC3; smooth scrolling 60 fps through Al-Baqarah (286 ayat).

**T-M04 Mushaf page reader + highlight** — deps: T-M02
- RTL PageView, page layout, `ReaderController.highlight`, route `/quran/page/:p?ayah=&hl=1`.
- AC: deep link `hafidz://quran/ayah/2:255` opens page 42 and pulses 2:255.

**T-M05 Voice Ayah Finder UI** — deps: T-M04, T-A04
- `VoiceController` state machine (docs/07 §3), recorder config, client VAD, upload with cancel, decision logic
  using server thresholds, candidate sheet, not-found, history table.
- AC: PRD US-01.1 AC1–AC12 (widget tests with mocked repository + one integration test against local BFF).

**T-M06 Share-to-app audio** — deps: T-M05
- Android intent filter + iOS share extension; transcode to 16 kHz mono (e.g. `ffmpeg_kit_flutter_min` or native) and
  trim to first 30 s.
- AC: sharing a WhatsApp `.opus` voice note triggers detection.

## M3 — Daily needs

**T-D01 Prayer BFF** — deps: T-F01
- Clients: equran shalat, myQuran v2, Aladhan; fallback chain docs/04 §11; `/v1/prayer/*` endpoints; location table
  (517 kab/kota with lat/lng/tz, mapped to myQuran ids).
- AC: Jakarta Sep 2026 matches Kemenag within ±1 min; with equran mocked down → myQuran used; both down → 503.

**T-D02 Prayer screen + offline calc** — deps: T-D01, T-M01
- Today/month UI, countdown, `adhan` fallback with KEMENAG params + ihtiyat.
- AC: offline mode shows `source=calc` times within ±2 min of Kemenag for 10 sample cities.

**T-D03 Adzan notifications** — deps: T-D02
- Scheduling rules docs/07 §6; settings per prayer.
- AC: notifications fire on time on Android 14 emulator in Doze (adb `dumpsys deviceidle force-idle`) test; reboot reschedules.

**T-D04 Qibla** — deps: T-M01
- AC: bearing Jakarta (−6.2, 106.8) = 295.2° ± 0.2 (matches Aladhan 295.16°); calibration prompt.

**T-D05 Murottal player** — deps: T-M03, T-M04
- Reciters endpoint + app player per docs/07 §5; follow-along highlight; downloads.
- AC: PRD F-03 AC1–AC3; background playback with lock-screen controls.

**T-D06 Hijri calendar & holidays** — deps: T-M01
- AC: 2026-09-28 shows 17 Rabi'ul Akhir 1448 (matches Aladhan `gToH`); offline conversion fallback.

**T-D07 Doa** — deps: T-M02
- Sync equran doa → local `doa` table; list with grup/tag filters; detail with ar/tr/idn/tentang.

## M4 — Content & polish

- **T-C01 Hadith** (BFF clients gading.dev → fawazahmed0 fallback, app browser with cache).
- **T-C02 Tafsir** (Kemenag tafsir in `tafsir` table, bottom sheet from ayah actions).
- **T-C03 Asmaul Husna** (bundled JSON, grid + detail, optional audio).
- **T-C04 Tasbih** (haptic counter, targets 33/99/100, multiple counters persisted).
- **T-C05 Global search** (FTS5 over translation + normalized Arabic, surah name fuzzy).
- **T-C06 Settings & About/Attribution** (all sources from docs/10 §4 with links).
- **T-C07 Accessibility & performance pass** (semantics labels, font scaling, cold start profiling).

## M5 — Beta

- **T-O01 Observability**: Sentry (app + API), Prometheus metrics, Grafana dashboard (ASR latency, confidence
  histogram, provider errors), alert rules.
- **T-O02 Load test**: k6 script 50 req/s `/v1/voice/detect` with 10 s clips; document pod sizing.
- **T-O03 Release**: Play Console internal track, TestFlight, privacy policy page, data-safety form.

## Phase 2 backlog (post-MVP)

On-device ASR (whisper.cpp / sherpa-onnx) + Dart matcher port · user accounts & sync · streaming follow-along
recitation · recitation mistake hints · Qur'an glyph-accurate Mushaf (QCF fonts) · widgets (home-screen prayer
widget) · Wear OS / watchOS prayer complications.
