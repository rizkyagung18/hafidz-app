# 09 — Testing & QA Strategy

**Current release gates:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) adds source-exact QUL v2 checks, print-package v3 touch/visual proof, and live streaming follow tests. The existing audio golden set is empty; no measured live or one-shot accuracy threshold may be claimed from it.

**Live implementation evidence (2026-10-01):** T-A06 protocol tests cover stable revisions, repeated/ambiguous
matches, ordered events, invalid frames/commands, rate and connection rejection, inference saturation,
backpressure cancellation, and Redis session release. T-M05 tests cover fixed PCM framing, permission denial,
bounded send queue, disconnect cleanup, validated events, local page follow, pause/resume, and retry. On the
iOS Simulator, live microphone recitation followed 2:256 → 2:257 and moved from page 42 to 43. The user observed
more than five seconds of lag on the first pass. The backend now starts matching at 1.5 seconds, checks each
further second, and keeps a four-second rolling window; a simulator retest is pending. Physical iPhone proof is
deferred by user. Simulator behavior does not establish microphone or ASR accuracy on a phone.
With the local model, matching index, API and Redis running, a real WebSocket
connection accepted half-second silent PCM frames, emitted `ready → ambiguous → stopped`
with increasing sequence numbers, and allowed immediate reconnection with the
same device ID. This confirms transport and lock cleanup, not recitation accuracy.
An ephemeral macOS speech synthesis stream of QUL ayah 2:256 reached a stable
backend event in about 4.6 seconds with the original cadence and 3.9 seconds
with the shorter cadence. This is a local timing comparison, not a recitation
accuracy measurement or a latency guarantee for human speech.
In a two-ayah synthetic stream (2:256 then 2:257), the four-second context
produced the second stable event about 4.7 seconds after the second ayah began.
Reducing context to three seconds improved that by only about 0.1 seconds, so
the four-second context was retained for a fuller matching signal. Human
recitation latency on the simulator still needs the post-tuning retest.

## 1. Test pyramid

| Layer | Tooling | Scope | Gate |
|---|---|---|---|
| Unit (Python) | pytest, hypothesis | normalize, matcher, audio validation, provider clients (respx mocks) | PR |
| Unit (Dart) | flutter_test, mocktail | repositories, `decide()`, VAD, prayer calc, qibla math | PR |
| Contract | schemathesis vs `docs/api/openapi.yaml` | All `/v1` endpoints | PR |
| Widget | flutter_test golden images | Reader, voice states, prayer card (light/dark, id/en, RTL) | PR |
| Integration | integration_test + local BFF in docker | Record (fixture audio injected) → page highlight | nightly |
| AI eval | `services/api/eval/run_eval.py` | Golden set accuracy + latency | nightly + before release |
| Load | k6 | Voice endpoint 50 req/s | pre-release |
| Manual | Test matrix §5 | Devices, noise, permissions, adzan timing | beta |

## 2. Golden dataset for Voice Ayah Finder

Version everything (`golden-v1`, `golden-v2`…); store audio in object storage, manifest in git.

| Subset | Size | How to build | Purpose |
|---|---|---|---|
| `clean-full` | 600 | Random ayat (stratified by length: short < 40 chars, medium, long > 300) from 4+ EveryAyah reciters (e.g. Alafasy_128kbps, Husary_128kbps, Abdul_Basit_Murattal_192kbps, Minshawy_Murattal_128kbps) | Baseline |
| `clean-partial` | 400 | 3–10 s random slices of long ayat | Fragment matching |
| `span` | 300 | Concatenate 2–3 consecutive ayah files | Range detection |
| `noisy` | 400 | `clean-*` + MUSAN/café noise at SNR 10 dB and 5 dB, + reverb | Robustness |
| `speaker-replay` | 150 | Play clips from a phone speaker, record with another phone | PRD AC11 |
| `user-real` | ≥ 300 | Consented recordings from Indonesian volunteers (varied age/gender/tajwid level), 5–20 s | Real-world |
| `negative` | 150 | Non-Qur'an Arabic speech (du'a, hadith, khutbah), Indonesian speech, music, silence | False-positive control |
| `ambiguous` | 50 | Repeated refrains (55:13 etc.), basmala-only, muqatta'at | Ambiguity handling |

Public references: EveryAyah files (<https://everyayah.com/recitations_ayat.html>), the Tarteel dataset paper
(<https://openreview.net/pdf?id=TAdzPkgnnV8>), HF dataset `Rdyh/everyayah` (ayah-aligned recitations). Check each
dataset's license before redistribution; keep derived clips internal.

### Evaluation harness

- `services/api/eval/golden-v1/manifest.csv` is the tracked label manifest. Audio stays in a private/local directory;
  see its README for licensing, consent, path, and retention rules. Do not commit recordings or transcripts.
- From `services/api`, run `uv run python eval/run_eval.py --audio-root /path/to/private/golden-v1/audio` to write
  aggregate JSON under `eval/output/` and the report to `docs/eval/golden-v1-report.md`. The runner uses the configured
  ASR model, verified Quran index/database, and matcher. Metrics JSON has match identifiers and scores but no audio or
  transcript strings. CER/WER are measured only on `clean-full` samples against normalized search-index text.
- `uv run python eval/tune_thresholds.py [metrics.json]` sweeps auto/min/margin decision thresholds, selecting the
  configuration with the best correctly routed positive rate subject to false auto-navigation ≤1% and negative
  rejection ≥95%. Tuning output is provisional until the target dataset coverage is met.
- The nightly API evaluation workflow runs the same harness. If no dataset rows are present, it commits a `blocked`
  report instead of inventing metrics. Incomplete subsets are reported as provisional; only full target coverage can
  be treated as release-gate evidence.

The initial golden-v1 manifest is intentionally empty because no licensed, consented audio corpus is currently
available in this repository. The committed report therefore records that evaluation is blocked, not an accuracy
result.

## 3. Metrics & release thresholds

| Metric | Definition | Release gate |
|---|---|---|
| Top-1 accuracy | best range overlaps ground truth start ayah (all subsets except negative) | ≥ 90 % overall, ≥ 95 % `clean-full` |
| Top-3 accuracy | GT in first 3 candidates | ≥ 97 % |
| Range exact | `ayah_start` and `ayah_end` equal GT (`span`) | ≥ 80 % |
| **False auto-navigate** | auto-navigate decision **and** wrong ayah | ≤ 1 % (most important) |
| Negative rejection | `negative` clips returning `notFound` or picker | ≥ 95 % |
| CER / WER | normalized transcript vs normalized GT text | tracked, no gate |
| Latency | server `timing_ms.total` p50 / p95 (10 s clip, 2 vCPU) | p95 ≤ 1.5 s |

Report per subset + per ayah-length bucket. Any matcher/normalizer PR must not reduce top-1 by > 0.5 pp or increase
false-auto-navigate at all (CI compares against `docs/eval/baseline.json`).

## 4. Prayer-time validation

- Fixtures: Kemenag monthly schedules (via equran.id) for 10 cities across WIB/WITA/WIT (Banda Aceh, Medan, Jakarta,
  Bandung, Surabaya, Denpasar, Makassar, Balikpapan, Ambon, Jayapura) × 3 months (incl. Ramadan).
- Assert: BFF `source=kemenag:*` exact match; `source=calc` within ±2 min.
- Timezone correctness: WIT city schedules in `Asia/Jayapura`, DST-free.

## 5. Manual device matrix (beta)

| Device class | Example | Focus |
|---|---|---|
| Low-end Android 10 | 3 GB RAM | Cold start, reader scroll, adzan in Doze |
| Mid Android 14 | Samsung A-series | OEM battery killers (adzan), exact alarms |
| Pixel (latest) | | Baseline, Material You |
| iPhone SE / latest | | Notifications cap (64), mic permission, share extension |

Scenarios: airplane mode (offline reader, calc prayer), permission denials, location change across timezones,
recording with TV/fan noise, Bluetooth headset mic, interruptions (phone call during recording).

## 6. Madinah 1405H Mushaf redesign — planned validation

This section defines release checks for the [redesign plan](11-MUSHAF-1405H-REDESIGN.md) and
[ADR-006](adr/ADR-006-madinah-1405h-mushaf.md). The read-only source audit has passed the page, ayah,
word-membership, legacy-page comparison and page-font glyph coverage checks in §6.1 on the local QUL download.
Rights, renderer fidelity, device interaction, migration, offline and performance checks remain open. Existing
T-M04 tests establish prototype navigation behavior, not print fidelity.

### 6.1 Source and content validation

- Audit the exact QUL layout 15, script 57 and font 238 downloads together. Pin sources, versions/retrieval dates,
  license evidence and hashes; reject wrong-edition, missing or corrupted artifacts.
- Verify 604 contiguous pages and complete mapping to all 6,236 canonical ayat and 114 surahs. Compare all
  edition page assignments against existing Madani metadata; investigate mismatches instead of silently overwriting
  either source. Keep the established `2:255 → page 42` deep-link check.
- Verify each source line's order, type, alignment and word range. Every referenced word must exist and resolve
  to a canonical ayah. Validate source end-marker records explicitly; do not assume every glyph record is a spoken word.
- Preserve source-driven opening-page line counts, centered lines, surah headings and basmallah handling.
  Do not require 15 occupied rows on every page or synthesize duplicate basmallahs/end markers.
- Confirm matching page-font coverage without fallback glyphs. Canonical Tanzil text and global ayah IDs must be
  unchanged; QUL word IDs and glyph codes must never become bookmark identifiers or substitutes for canonical semantic text.

### 6.2 Print fidelity and interaction

- Approve reference comparisons and maintain separate Android/iOS golden baselines for pages **1, 2, 42, 48, 121,
  187 and 604**. Include source page/edition evidence with each baseline. Review line breaks, glyphs, spacing,
  alignment, heading/basmallah placement, ayah end markers and page proportions; a screenshot that matches the
  implementation alone does not establish source fidelity.
- Verify page structure stays fixed across phone sizes, orientation changes and text-scale settings. Scale/zoom
  the page without automatic paragraph wrapping or moving words between source lines; accessible larger text is
  available through list mode and ayah details.
- Tap and long-press visible words and end markers near the center and both edges of each target. The selected
  canonical ayah must agree with the source mapping, including neighboring ayat on one line and ayat spanning lines.
  Header, margin and inter-ayah blank-space taps must not accidentally select a nearby ayah.
- Exercise inverse scale, translation and zoom transforms for hit testing after resize and pan. Use the rendered
  word geometry for both hit targets and highlight regions; no separate guessed rectangles.
- Test multi-line and multi-ayah range highlighting, adjacent-page ranges, four-second pulse and retained marker,
  interruption/replacement by a new selection, and reduced-motion behavior. Highlight only the targeted ayah
  fragments while preserving glyph readability.
- Cover canonical ayah deep links, page links, last read, Voice Ayah Finder results and later audio follow-along.
  Resolve canonical ayah ranges through the selected edition and verify the same ayah is targeted by every entry path.

### 6.3 Installation, offline use and performance

- Exercise the planned content schema v1 → v2 replacement with coordinated `PRAGMA user_version`, `meta.db_version`,
  Drift definitions and mobile loader checks. Reject unsupported versions, mismatched checksums, missing page fonts
  and partial bundles. A failed v2-pack update keeps a compatible verified v2 pack usable. A failed first v1 → v2
  transition preserves v1 data on disk and shows a recoverable content error when no valid v2 pack exists; it must
  not try to render v1 as the new print.
- Seed `user.sqlite` with bookmarks, notes, last read, khatam progress and settings before replacing content. Verify preservation of user
  data, stable global ayah references and correct recomputation of any derived page values. Never reset user data
  as a content-update mechanism. Preserve the original edition of page-based progress; do not silently relabel
  completed pages when edition boundaries differ.
- Start a fresh install in airplane mode and visit all 604 pages with no previously warmed font/image cache.
  Validate licensed full-bundle availability, fast page jumps and complete ayah interactions offline.
- Measure release download size, installed content/font size, startup time, peak memory and page-swipe frame timing
  on representative Android and iOS devices, including repeated page traversal and engine-held fonts. Compare
  the complete bundle against the PRD size/performance budgets;
  a debug APK or a dependency estimate is not release-size evidence. If the bundle cannot meet the budget, document
  the measured tradeoff before changing delivery or offline requirements.
