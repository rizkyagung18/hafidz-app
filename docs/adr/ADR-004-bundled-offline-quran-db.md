# ADR-004 — Bundled offline Qur'an database

- Status: Accepted · Date: 2026-09-28

## Context
Reader must work offline; voice results must map to Madani page numbers instantly; free APIs have no SLA.

## Decision
Ship `quran.sqlite` built reproducibly from Tanzil (verbatim Uthmani + Simple Clean), alquran.cloud metadata
(page/juz/hizb), and Kemenag Indonesian translation/tafsir via equran.id, cross-checked against Quran Foundation.
Updates delivered via `/v1/quran/db/manifest`.

## Consequences
+ Instant, offline, deterministic. − ~20 MB app size; DB updates need a manifest/download flow.
