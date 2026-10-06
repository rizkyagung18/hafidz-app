# ADR-004 — Bundled offline Qur'an database

- Status: Accepted · Date: 2026-09-28

## Context
Reader must work offline; voice results must map to Madani page numbers instantly; free APIs have no SLA.

## Decision
Ship `quran.sqlite` built reproducibly from pinned QUL Uthmani, Imlaei Simple, Indonesian translation, and metadata. All Qur'an content, fonts, and future recitations use QUL resources. This source decision supersedes the original 2026-09-28 provider selection; see docs/12 for the current v3 package.
Updates delivered via `/v1/quran/db/manifest`.

## Consequences
+ Instant, offline, deterministic. − ~20 MB app size; DB updates need a manifest/download flow.

## Amendment — 2026-09-30

[ADR-006](ADR-006-madinah-1405h-mushaf.md) adds a planned mobile schema-v2 presentation layer for the Madinah
1405H print: QUL line layout, word glyphs, and matching page fonts. Canonical Qur'an text and IDs remain stable;
`user.sqlite` is preserved. New Mushaf routes use this edition's mapping, while legacy page metadata remains
available to existing consumers.

The original ~20 MB estimate covers the semantic DB, not the complete 1405H font/layout package. Measure the
new bundle before accepting its size. Upgrade the mobile loader and matching content package together; do not
serve a v2-only package through the existing v1 manifest without a separately specified compatible rollout.
This amendment records planned work; the current builder and loader remain on schema v1.

## Amendment — 2026-10-05

The Surah reader uses the owner-supplied QUL QPC V1 ayah-by-ayah SQLite as a separate presentation asset and the existing page fonts. Canonical QUL text stays in `quran.sqlite`; user data and the ASR index are unchanged. The sidecar is ignored until redistribution rights are established; source hashes and staging are documented in docs/06.
