# ADR-006 — Madinah 1405H fixed-page Mushaf

- Status: Product target accepted; source package and renderer validation planned
- Date: 2026-09-30
- Amends: [ADR-004](ADR-004-bundled-offline-quran-db.md)
- Plan: [Mushaf redesign](../11-MUSHAF-1405H-REDESIGN.md)

## Context

The T-M04 prototype groups verbatim ayat by page and draws Unicode paragraphs. It preserves semantic text
and supports navigation, but changes line breaks and visual positions. The user requires the Madinah 1405H
printed appearance and pressable ayat. Page numbers alone cannot provide that result.

## Decision

Use QUL's [1405H layout resource 15](https://qul.tarteel.ai/resources/mushaf-layout/15) with its explicitly related
[V1 word glyphs 57](https://qul.tarteel.ai/resources/quran-script/57) and [V1 fonts 238](https://qul.tarteel.ai/resources/font/238)
as the proposed source set. Preserve prescribed lines and use page fonts within a fixed page coordinate system.
Validate representative output against approved 1405H references before full implementation.

Measure token bounds from the actual shaped glyph lines and map them to canonical ayat for presses and highlight
overlays. Keep multiple segments per ayah and use one shared transform for painting, zoom, and hit testing.
No edition-matched image/coordinate package has been verified, so the design does not depend on one.

Extend the immutable mobile content database to schema v2 with separate edition/layout/glyph metadata. Preserve
canonical text, IDs, search data, and `user.sqlite`. The list reader continues to display canonical text; Mushaf
glyph codes are presentation data and must not be used for search, ASR, accessibility speech, or copy/share.

The initial active print is 1405H. Resolve ayah routes from its local mapping. Existing HTTP fields and server
database distribution remain compatible until any separate API rollout is explicitly specified in both API docs.

Package the complete edition for offline use after install, subject to a measured asset-size review. The current
60 MB goal cannot be asserted before this measurement. Resource-specific redistribution rights, actual export
schemas, complete font coverage, and auxiliary artwork sources must be recorded before packaging.

## Alternatives considered

- **Reflowed Unicode paragraphs:** suitable for list mode; rejected for the requested print layout.
- **QUL V2/1421H or another Madani edition:** does not satisfy the chosen 1405H source identity.
- **Full-page images plus coordinates:** can preserve print appearance, but a matching licensed source set and
  geometry have not been verified. Requires a revised decision if pursued.
- **Rebuild semantic text from glyph strings:** rejected; glyph encodings cannot replace canonical ayah text.

## Consequences

- Print fidelity and press accuracy become release criteria alongside navigation and content integrity.
- The builder, verifier, loader, and Drift schema need a coordinated content-version upgrade.
- Fonts, glyph data, and line layout must be pinned together; missing fonts must produce an asset error.
- Page rendering, hit testing, zoom, and highlighting share measured geometry and need platform visual QA.
- T-M04 is reopened under T-M04-R1–R5. T-M05 and T-D05 depend on the replacement's acceptance.

This ADR changes the design contract only; no renderer or database rebuild has occurred.
