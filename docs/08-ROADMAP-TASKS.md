# 08 — Roadmap & Agent Task Breakdown

Each task is sized for one coding-agent session (≈ 1 PR). Give the agent the task ID, e.g.
"Implement **T-B05** per docs/08-ROADMAP-TASKS.md". Tasks list dependencies (`deps`) and acceptance criteria (AC).

## Milestones

| Milestone | Scope | Exit criteria |
|---|---|---|
| **M0 Foundation** (week 1) | Repo, CI, data build, model conversion | `quran.sqlite` + `quran_index.pkl` built & verified in CI; model converted |
| **M1 AI core** (weeks 2–3) | BFF voice endpoint + matcher + golden eval | Top-1 ≥ 90 % on golden-v1; p95 server latency ≤ 1.5 s |
| **M2 App core** (weeks 3–5; re-estimate after T-M04-R1/R2) | Flutter shell, 1405H print-faithful Qur'an reader, Voice Ayah Finder UI | Approved 1405H appearance + pressable ayat; end-to-end record → page highlight on device |
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

**T-F02-QUL QUL content migration** — deps: T-F02, T-F04, T-M02; active replacement task
- Status: local v2 build, verifier, index, Drift loader, and user-data retention tests pass. Archive and generated
  asset redistribution remains pending; CI cannot run the full content build without the local QUL inputs.
- Rebuild the semantic Qur'an DB as v2 from pinned local QUL ZIPs: Uthmani, Imlaei Simple, Indonesian translation, Surah/Ayah/Juz/Hizb/Sajda metadata, and 1405H layout/word mapping. Preserve 6,236 global IDs and `user.sqlite`.
- Rebuild FTS and the backend matcher index; update Drift, the loader, voice metadata, source attribution, and contracts together. Latin, tafsir, Surah meanings, Rub, Manzil, and Ruku are deferred.
- AC: complete source-key coverage, 114 surahs, 6,236 ayat, 604 pages, 30 juz, 60 hizb, exact source text/hash checks, v1→v2 user-data preservation, and no dependency on legacy Qur'an providers. QUL assets remain local until redistribution rights are established.

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

**T-M01-R1 Navigation and visual refresh** — deps: T-F02-QUL, T-M03
- Status: implemented and covered by local Flutter tests; iOS Simulator launch confirmed the Surah-list start.
- Launch on Surah list; tabs Al-Qur'an, Sholat, Belajar, Lainnya. Put Kiblat under Lainnya. Surah tap offers Mushaf, Surah & Translation, and Murattal (coming soon until T-D05).
- Use warm cream, forest green, and muted gold outside the source-faithful Mushaf canvas. The mic FAB appears only on the Mushaf screen; Belajar is a clearly labeled Hafalan preview.
- AC: routes and deep links remain valid, four tabs and Surah actions work, and no Home/Qibla tab or mic control outside Mushaf remains.

**T-M02 Local DB layer** — deps: T-F02, T-M01
- drift definitions for `quran.sqlite` (read-only, copied from assets with version check) and `user.sqlite`.
- Repositories: `QuranRepository` (surahs, ayah by key, page, juz, search), `BookmarkRepository`, `ReadingRepository`.
- AC: unit tests with in-memory DB; `pageOf(AyahRef(2,255)) == 42`.

**T-M03 Surah list & list reader** — deps: T-M02
- AC: PRD F-02 AC1, AC3; smooth scrolling 60 fps through Al-Baqarah (286 ayat).

**T-M04 Mushaf page reader + highlight** — deps: T-M02
- Status: **reopened for redesign, 2026-09-30**. Existing flowing-text prototype is retained, but does not meet
  the requested print fidelity. Earlier routing/widget tests do not complete the replacement.
- Target: **Madinah 1405H / KFGQPC V1** fixed-page rendering with pressable ayat. Follow
  [docs/11](11-MUSHAF-1405H-REDESIGN.md), [ADR-006](adr/ADR-006-madinah-1405h-mushaf.md), and PRD F-02.
- AC: all 604 pages preserve source lines/glyphs/headings/basmala and approved print proportions; words and end
  markers select canonical ayat accurately under zoom; complete offline use; jumps and range highlight work.
  `hafidz://quran/ayah/2:255` opens page 42 and pulses only its segments for four seconds.
- The following tasks are **planned**, not implemented by the documentation update. Execute one at a time.

**T-M04-R1 Audit and pin the 1405H source set** — deps: T-M02
- Status: technical source audit passed on 2026-10-01. Layout, word-glyph, and all 604 page-font exports are
  pinned in `tools/build_quran_db/qul_1405h_source_manifest.json`. All 6,236 ayat map with zero legacy page
  differences and zero missing page glyphs. Resource-specific redistribution evidence is still pending.
- Inspect QUL layout 15, glyphs 57, fonts 238, and required heading/basmala/ornament assets. Record actual schemas,
  IDs, source revision or snapshot date, SHA-256, resource-specific licensing evidence, and archive/installed sizes.
- Compare all edition page boundaries against the existing DB; document the import mapping and source exceptions.
- AC: reviewable source manifest + schema map + full page-difference report. Confirm complete font/glyph coverage
  and redistribution terms before packaging. Unresolved source gaps remain explicit; do not substitute V2 or
  claim that unverified images/coordinates exist. Report feasibility of the provisional 60 MB budget.

**T-M04-R2 Prove the printed appearance and touch geometry** — deps: T-M04-R1
- Status: local browser proof generated for all seven representative pages. Provisional Flutter pages 1, 48,
  and 604 were screenshot inspected on an iOS Simulator; page 128 was inspected on iOS and Android after the
  full-height, full-width banner change. A page-4 widget-rendered image was compared with the denser reader
  reference after QPC glyph sizing was corrected. Page 42 deep-link, word-tap, and zoomed word-tap tests pass.
  Final Android/iOS comparison at the denser glyph size, memory/performance profiling, user appearance review,
  and rights are open.
- Build a limited visual proof for pages 1, 2, 42, 48, 121, 187, and 604 using the exact V1 fonts and source lines.
  Establish fixed design metrics, headings, basmala treatment, and auxiliary artwork against 1405H references.
- Derive token selection boxes from shaped lines; demonstrate a pressable multi-line ayah at default scale and
  zoom. Measure font/geometry memory use during repeated traversal, including engine-held fonts; plan a bounded cache.
- AC: iOS and Android visual comparisons plus a concrete appearance review by the user **before full integration**.
  No reflow or fallback font. Resolve source/renderer discrepancies before proceeding to the content rebuild.

**T-M04-R3 Rebuild the immutable Mushaf package** — deps: T-M04-R2, T-F02-QUL
- Extend the v2 semantic DB to a v3 print package with QUL page, line, word, font and source-asset membership. Do not use the flowing-text prototype as the final Mushaf.
- Add the planned edition/page/line/word/asset contracts in docs/06 §1.1; preserve canonical text and IDs. Pin and
  verify matching assets. Coordinate schema v3 across builder, verifier, Drift, loader, and checksum handling.
- AC: complete 604-page and 6,236-ayah membership verified; font coverage and hashes pass; source-driven line
  exceptions and markers handled. A v1 user fixture retains bookmarks, notes, reading position, and progress.
  Mixed/corrupt assets fail safely; old verified data survives a failed update. Reuse a compatible v3 pack after
  a v3 update failure; a failed first v2 → v3 transition shows a recoverable error without claiming v2 renders
  the new print. Keep v1 server distribution compatible.

**T-M04-R4 Replace the reader and ayah interactions** — deps: T-M04-R3
- Fixed-page RTL reader, fit-page default, pinch/pan without reflow. Share measured geometry between rendering,
  highlights, and inverse-transform hit tests. Words/end markers open canonical ayah actions; decorations do not.
- AC: translation/bookmark/copy/share actions use canonical data. Four-second pulse, persistent subtle
  marker, multi-line and cross-page range selection pass; gesture drags do not select ayat. Canonical accessibility
  labels and the independent list reader remain usable. Playback integration remains T-D05.

**T-M04-R5 Integrate navigation and accept the replacement** — deps: T-M04-R4
- Resolve page/juz/surah/ayah jumps, links, saved positions, and voice/audio navigation entry points from the
  local edition map; keep existing route and highlight interfaces compatible.
- AC: docs/09 §6 data, visual, interaction, migration, and offline cases pass; page 42 deep link pulses 2:255
  for four seconds. All pages work after fresh install in airplane mode. User reviews print fidelity; profile
  builds meet the 60 fps target on a chosen mid-range device; record bundle sizes and memory. Complete T-M04
  only after this evidence is recorded. Do not implement T-M05 or T-D05 as part of these reader tasks.

**T-M05 Voice Ayah Finder UI** — deps: T-M04-R5, T-A04
- Status: live capture, bounded framing, stable range follow, pause/resume, retry, and automated widget/transport
  tests implemented locally. On an iOS Simulator, live recitation followed Al-Baqarah 2:256 → 2:257 and turned
  page 42 → 43; the first pass took more than five seconds. A shorter inference cadence is implemented and its
  simulator retest is pending. Physical iPhone validation is deferred by user; T-M04-R5 checks are also deferred.
- Put the sole visible mic entry on the Mushaf outside its print canvas. Connect live PCM capture and stable ayah
  events to the fixed-page highlight; preserve `/voice` for shared files and existing links. See docs/12.
- AC: a session can keep listening, follow successive ayat across page boundaries, pause/stop, recover from
  disconnect, and avoid unstable jumps on repeated ayat. No raw audio persistence; device integration proof.

**T-A06 Live Voice Finder backend** — deps: T-A04, T-F02-QUL
- Status: bounded WebSocket, worker limit, stable-event protocol, cleanup and simulated streaming tests implemented
  locally. Real streaming latency/accuracy remain unmeasured while the consented golden set is empty.
- Add bounded WebSocket `/v1/voice/live` with ordered PCM chunks, rolling ASR windows, continuity/hysteresis,
  stable canonical ayah events, explicit backpressure, disconnect cleanup, and rate/connection limits (docs/12).
- AC: protocol, cleanup, bounded-memory, repeated-ayah, and simulated streaming tests pass. Report measured live
  latency/accuracy only after a nonempty consented streaming golden set exists.

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

**T-D05 Murottal player** — deps: T-M03, T-M04-R5
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
recitation · recitation mistake hints · additional Mushaf print editions (1405H is required in M2) · widgets (home-screen prayer
widget) · Wear OS / watchOS prayer complications.
