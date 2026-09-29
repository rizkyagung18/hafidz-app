# ADR-003 — Deterministic n-gram + fuzzy alignment ayah matcher

- Status: Accepted · Date: 2026-09-28

## Context
ASR output is noisy and may cover partial or multiple ayat. Need exact `(surah, ayah)` + page, explainable
confidence, low latency, and offline portability.

## Decision
Normalize Arabic (docs/03 §4), retrieve candidates with char 3-gram TF-IDF over single-ayah and 2–3-ayah window units,
re-rank with rapidfuzz partial alignment on two text variants (Uthmani & Simple Clean), fuse scores with ASR quality,
and gate UI behavior by server-provided thresholds.

## Consequences
+ No extra ML model, deterministic, testable, tiny index (portable to Dart).
− Very short or repeated phrases remain ambiguous → handled by candidate picker, not by guessing.
Alternatives: embedding retrieval (HuBERT/WavLM + FAISS) — deferred to Phase 3 as a pre-filter; LLM-based matching —
rejected (latency, cost, hallucination risk with sacred text).
