# 10 — Security, Privacy & Licensing

**Current content boundary:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md). Tanzil, EQuran, AlQuran.cloud, and Quran Foundation are legacy or deferred Qur'an sources and are not inputs to the new QUL-only build. Source-specific QUL redistribution evidence is still missing, so generated QUL archives, DBs, and fonts stay local and untracked. The separate Tarteel ASR model and non-Qur'an daily-needs providers remain.

## 1. Threat model (summary)

| Asset | Threat | Control |
|---|---|---|
| Quran Foundation client secret | Extraction from app binary | Secret only on BFF; app never calls QF directly |
| Voice recordings | Leakage / retention | In-memory processing, no disk writes, no logging of audio; TLS 1.2+ |
| BFF compute (ASR is CPU-heavy) | Abuse / DoS | Per-device + per-IP rate limits, 2 MB / 30 s caps, WAF, Play Integrity / App Attest (Phase 2) |
| Free upstream APIs | Our traffic overwhelming them → ban | Aggressive caching, single BFF egress, `User-Agent` with contact |
| Qur'an text integrity | Tampered / corrupted text shipped | Pinned SHA-256 of sources, build invariants, DB checksum verified at app start |
| Planned 1405H Mushaf presentation | Wrong-edition fonts/layout or incorrect ayah selection | Pin the matching QUL resource set, verify hashes and canonical word mappings, compare rendered pages with approved references |
| Device id | Tracking | Random UUID, resettable in settings, not linked to PII |

## 2. Voice data policy

1. Default: audio is streamed to BFF over HTTPS, decoded in memory, transcribed, and discarded when the request ends.
   No object storage, no temp files (use `io.BytesIO`), no audio in logs, traces, or Sentry breadcrumbs.
2. Live transcripts are never logged, including DEBUG; they remain in memory for matching only. Metrics store
   only confidence/latency. One-shot transcript debug logging remains disabled by default.
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
| Amiri Quran font (bundled) | SIL Open Font License | Include OFL text in OSS licenses |
| QUL layout 15, V1 word glyphs 57, QPC V1 fonts 238 (planned) | Resource-specific terms unresolved; QUL availability is not a license grant | Pin rights/attribution evidence for each resource before redistribution; see §4.1 |

Amiri Quran 1.003 is bundled at `apps/mobile/assets/fonts/AmiriQuran.ttf` with
its SIL Open Font License at `apps/mobile/assets/fonts/OFL.txt`. The license is
registered with Flutter's license page. The About screen links to the font
project and to the currently bundled Qur'an content sources.

Action item before public release: legal review of each row (especially translations, tafsir, and audio
redistribution for offline download).

### 4.1 Planned Madinah 1405H resource audit

The [redesign plan](11-MUSHAF-1405H-REDESIGN.md) and
[ADR-006](adr/ADR-006-madinah-1405h-mushaf.md) select the following compatible resources for audit:
[KFGQPC V1 layout 15](https://qul.tarteel.ai/resources/mushaf-layout/15),
[QPC V1 word glyphs 57](https://qul.tarteel.ai/resources/quran-script/57), and
[QPC V1 fonts 238](https://qul.tarteel.ai/resources/font/238).
Their public descriptions were checked on 2026-09-30. Local downloads were audited on 2026-10-01 and pinned in
[`qul_1405h_source_manifest.json`](../tools/build_quran_db/qul_1405h_source_manifest.json). None of the three
archives includes a license file. Resource-specific redistribution permission remains unverified; the files are
kept in an ignored local cache and are not bundled in the app.

The [QUL FAQ](https://qul.tarteel.ai/faq) says licenses and attribution obligations vary by resource, including
for commercial use. QUL's [MIT-licensed CMS code](https://github.com/TarteelAI/quranic-universal-library) does not
establish the license for separately downloaded Quran content or fonts. Tarteel's
[QUL announcement](https://tarteel.ai/blog/qul-launch/) credits the King Fahd Complex for many original fonts/images;
that attribution alone does not establish permission to redistribute the selected files.

Before redistribution, preserve each resource's author/rightsholder, exact source URL, version/retrieval date,
SHA-256, applicable license or written permission, redistribution/embedding conditions and required credit text.
If the download does not include clear terms, obtain clarification from the rightsholder before shipping it.
About and the OSS license view must carry the verified credits and license texts when the assets are integrated.
Do not describe QPC V1 as OFL, MIT or public domain without resource-specific evidence.

The planned renderer preserves QUL's glyph sequences, page/line membership and matching page fonts. Ayah selection
geometry will be measured from rendered words; no upstream pixel rectangles or complete 1405H image pack have been
verified. Any later image-based alternative requires its own matching-source, geometry and rights audit.

## 5. Religious-content QA

- Qur'an text is never generated or altered by AI. The AI only **locates** ayat; semantic text comes from licensed,
  verbatim sources. The planned Mushaf uses separately verified, licensed QUL V1 presentation glyphs/fonts while
  list mode, copy/share and accessibility text retain canonical Tanzil text.
- Planned print QA must preserve source line structure, special opening pages, headings, basmallahs and end markers.
  A tap/highlight must resolve to the correct canonical ayah without reflowing or substituting generic glyphs.
  Reference comparisons and release checks are specified in docs/09 §6 and remain incomplete.
- Any AI-generated explanation features (future) must be clearly labelled, cite tafsir sources, and be reviewed by a
  qualified ustadz before launch.
- Provide an in-app "Laporkan kesalahan" (report an error) for text/translation/schedule issues.
