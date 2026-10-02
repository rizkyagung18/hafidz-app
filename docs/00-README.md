# Hafidz App — Muslim Daily Companion · Technical Documentation

Documentation set for building a Muslim daily-needs app (Qur'an, murottal, prayer times, qibla, Hijri, du'a,
hadith) with an AI **Voice Ayah Finder** powered by `tarteel-ai/whisper-base-ar-quran`.

Designed to be embedded in the source repository so coding agents (Codex, etc.) can implement it task by task.
Start with [`/AGENTS.md`](../AGENTS.md).

**Current design revision (2026-09-30):** the T-M04 flowing-text prototype does not meet the required Mushaf
appearance. The target is **Madinah 1405H / KFGQPC V1 with pressable ayat**. Read the
[redesign plan](11-MUSHAF-1405H-REDESIGN.md) and [ADR-006](adr/ADR-006-madinah-1405h-mushaf.md) before continuing
Mushaf work. Source audit and visual proof precede the database rebuild. Local audit/proof tools exist; the app
reader still uses the earlier flowing-text prototype.

## How to use with Codex

1. Copy `AGENTS.md` to the repository root and `docs/` to `/docs`.
2. Commit, then give the agent one task at a time, e.g.:
   > Read AGENTS.md and docs/08-ROADMAP-TASKS.md. Implement task **T-F02** (Qur'an DB builder). Follow the schema in
   > docs/06-DATA-MODEL.md §1 and all invariants. Add tests. Update docs if you change any contract.
3. Follow the milestone order M0 → M5. AI core (M1) and app shell (M2) can run in parallel after M0.
4. Whenever an API contract changes, the agent updates both `docs/05-BACKEND-API-SPEC.md` and `docs/api/openapi.yaml`.

## Index

| # | Document |
|---|---|
| 01 | [PRD](01-PRD.md) |
| 02 | [Architecture](02-ARCHITECTURE.md) |
| 03 | [AI Ayah Detection](03-AI-AYAH-DETECTION.md) |
| 04 | [External API Catalog](04-EXTERNAL-API-CATALOG.md) |
| 05 | [Backend API Spec](05-BACKEND-API-SPEC.md) · [OpenAPI](api/openapi.yaml) |
| 06 | [Data Model](06-DATA-MODEL.md) |
| 07 | [Mobile App Design](07-MOBILE-APP-DESIGN.md) |
| 08 | [Roadmap & Tasks](08-ROADMAP-TASKS.md) |
| 09 | [Testing & QA](09-TESTING-QA.md) |
| 10 | [Security, Privacy & Licensing](10-SECURITY-PRIVACY-LICENSING.md) |
| 11 | [Madinah 1405H Mushaf Redesign](11-MUSHAF-1405H-REDESIGN.md) |
| ADR | [001 Flutter](adr/ADR-001-flutter-mobile.md) · [002 faster-whisper](adr/ADR-002-faster-whisper-server-asr.md) · [003 Matcher](adr/ADR-003-deterministic-ayah-matcher.md) · [004 Offline DB](adr/ADR-004-bundled-offline-quran-db.md) · [005 Prayer sources](adr/ADR-005-prayer-times-sources.md) · [006 Madinah 1405H Mushaf](adr/ADR-006-madinah-1405h-mushaf.md) |

## Glossary

| Term | Meaning |
|---|---|
| Ayah key | `surah:ayah`, e.g. `2:255` (Ayat Kursi) |
| Madani page | Edition-specific page number; the target reader uses the 604-page Madinah 1405H / KFGQPC V1 print. Legacy API/DB metadata is retained separately. |
| Juz / Hizb | 30 equal parts / 60 halves-of-juz (240 quarters) |
| Murottal | Recited Qur'an audio |
| Muqatta'at | Disjointed letters opening some surahs (الم, حم, …) |
| Ihtiyat | Safety margin minutes added to calculated prayer times (Kemenag practice) |
| BFF | Backend-for-Frontend — our FastAPI server |
| Unit | Search-index entry: 1 ayah or a window of 2–3 consecutive ayat |
