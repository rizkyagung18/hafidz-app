# ADR-002 — Server-side ASR with faster-whisper (CTranslate2 int8)

- Status: Accepted · Date: 2026-09-28

## Context
Required model: `tarteel-ai/whisper-base-ar-quran` (Apache-2.0, WER 5.75 % reported). MVP must work on low-end
phones and ship fast. The checkpoint ships only `pytorch_model.bin` + slow-tokenizer files.

## Decision
Convert once to CTranslate2 int8 (building `tokenizer.json` first) and serve with faster-whisper on CPU inside the
FastAPI BFF. Load once per process, run in a thread pool.

## Consequences
+ ~3–4× faster than PyTorch CPU, small RAM, no GPU needed, same Python runtime as matcher.
− Requires network for voice search in v1; server cost scales with usage (mitigated by rate limits).
Revisit in Phase 2: on-device (whisper.cpp / sherpa-onnx) with server fallback.
