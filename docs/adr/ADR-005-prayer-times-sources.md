# ADR-005 — Prayer time sources: Kemenag first, calculation fallback

- Status: Accepted · Date: 2026-09-28

## Context
Indonesian users expect times identical to Kemenag schedules (which include ihtiyat). Aladhan method 20 (KEMENAG)
differed by ~3 min from myQuran/Kemenag for Jakarta in a spot check.

## Decision
Indonesia: equran.id `/api/v2/shalat` → myQuran v2 → on-device `adhan` calc (KEMENAG angles + configurable ihtiyat).
Outside Indonesia: Aladhan with country-appropriate method → on-device calc. Cache ≥ 2 months on device.

## Consequences
+ Official-matching times, offline resilience. − Must maintain kab/kota ↔ coordinates ↔ myQuran-id mapping table.
