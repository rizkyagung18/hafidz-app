# 10 — Security, Privacy & Licensing

## 1. Threat model (summary)

| Asset | Threat | Control |
|---|---|---|
| Quran Foundation client secret | Extraction from app binary | Secret only on BFF; app never calls QF directly |
| Voice recordings | Leakage / retention | In-memory processing, no disk writes, no logging of audio; TLS 1.2+ |
| BFF compute (ASR is CPU-heavy) | Abuse / DoS | Per-device + per-IP rate limits, 2 MB / 30 s caps, WAF, Play Integrity / App Attest (Phase 2) |
| Free upstream APIs | Our traffic overwhelming them → ban | Aggressive caching, single BFF egress, `User-Agent` with contact |
| Qur'an text integrity | Tampered / corrupted text shipped | Pinned SHA-256 of sources, build invariants, DB checksum verified at app start |
| Device id | Tracking | Random UUID, resettable in settings, not linked to PII |

## 2. Voice data policy

1. Default: audio is streamed to BFF over HTTPS, decoded in memory, transcribed, and discarded when the request ends.
   No object storage, no temp files (use `io.BytesIO`), no audio in logs, traces, or Sentry breadcrumbs.
2. Transcripts: not logged at INFO; DEBUG only in dev. Metrics store only confidence/latency.
3. Opt-in "Bantu tingkatkan akurasi" (Phase 2): explicit consent screen, stored consent record (timestamp, version),
   audio stored encrypted (AES-256, SSE-KMS) for max 180 days, deletable from settings. `STORE_AUDIO_OPT_IN=false` by default.
4. On-device history stores ayah key + confidence (+ transcript if user allows) — never audio.
5. Comply with Indonesia's **UU PDP (Law No. 27/2022 on Personal Data Protection)**: privacy notice in Bahasa Indonesia,
   purpose limitation, data-subject deletion requests, breach notification process. Voice can be biometric data — treat
   as sensitive; this is why default is no retention.
6. Google Play Data Safety: declare "Audio — processed ephemerally, not collected/shared" (true for default mode).

## 3. Secrets & infra

- Secrets via secret manager → env vars; `.env` never committed (gitignore + `gitleaks` in CI).
- Separate QF credentials for pre-live vs production.
- Containers run as non-root, read-only FS except `/tmp` (tmpfs), no outbound network except allow-listed providers.
- Dependency scanning: `pip-audit`, `osv-scanner` for pub, Dependabot.

## 4. Content & model licensing — attribution screen (About → Sumber Data)

| Source | License / terms (verify before release) | Obligation |
|---|---|---|
| Tanzil Qur'an text | CC BY 3.0; verbatim copies only — <https://tanzil.net/docs/text_license> | Credit "Tanzil Project", link tanzil.net, do not alter text |
| Kemenag RI data via EQuran.id | Kemenag public data; equran.id states source quran.kemenag.go.id | Credit Kemenag RI + EQuran.id |
| Quran Foundation / Quran.com API | Developer terms at api-docs.quran.foundation; production access requires approval | Follow QF terms, credit Quran.com, per-resource license for translations/tafsir |
| AlQuran.cloud | Check site terms | Credit AlQuran.cloud / Islamic Network |
| Aladhan | Open source API | Credit AlAdhan.com |
| myQuran API | Free community API | Credit api.myquran.com |
| EveryAyah audio | Check terms per reciter | Credit EveryAyah.com and reciter names |
| MP3Quran.net | Check terms | Credit MP3Quran.net |
| Hadith (gading.dev, fawazahmed0) | Open-source repos; check upstream text licenses | Credit repos and original sources |
| `tarteel-ai/whisper-base-ar-quran` | Apache-2.0 | Include license text + "Model by Tarteel AI" in About/OSS licenses |
| OpenAI Whisper (base) | MIT | Include in OSS licenses |
| Fonts (KFGQPC, Amiri) | KFGQPC terms / OFL | Include font licenses |

Action item before public release: legal review of each row (especially translations, tafsir, and audio
redistribution for offline download).

## 5. Religious-content QA

- Qur'an text is never generated or altered by AI. The AI only **locates** ayat; displayed text always comes from the
  licensed DB.
- Any AI-generated explanation features (future) must be clearly labelled, cite tafsir sources, and be reviewed by a
  qualified ustadz before launch.
- Provide an in-app "Laporkan kesalahan" (report an error) for text/translation/schedule issues.
