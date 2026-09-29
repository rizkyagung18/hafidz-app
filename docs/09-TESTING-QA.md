# 09 — Testing & QA Strategy

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
