# 03 — AI Voice Ayah Detection (ASR + Ayah Matching)

This is the core AI feature. It has two stages:

1. **ASR** — speech → Arabic text using `tarteel-ai/whisper-base-ar-quran`.
2. **Ayah matching** — Arabic text → `(surah, ayah_start, ayah_end, page)` using a deterministic, fuzzy search
   over a bundled Qur'an index.

Whisper alone only produces text; the matcher is what turns noisy text into a precise, navigable Mushaf location.

---

## 1. Model facts

| Property | Value |
|---|---|
| Model | [`tarteel-ai/whisper-base-ar-quran`](https://huggingface.co/tarteel-ai/whisper-base-ar-quran) |
| Base | `openai/whisper-base` (~74 M params, encoder-decoder) |
| Task | Automatic Speech Recognition, Arabic Qur'anic recitation |
| Reported WER | 5.75 % (eval loss 0.0839) on the author's eval split |
| License | Apache-2.0 (commercial use allowed; keep NOTICE/attribution) |
| Files on Hub | `pytorch_model.bin`, `config.json`, `vocab.json`, `merges.txt`, `added_tokens.json`, `normalizer.json`, `preprocessor_config.json`, `tokenizer_config.json`, `special_tokens_map.json` — **no `tokenizer.json`, no safetensors** |
| Input | 16 kHz mono float32 PCM, ≤ 30 s per window (Whisper constraint) |
| Output | Arabic text (may or may not include diacritics — always normalize) |

Notes / caveats:
- The WER was measured on clean recitation; expect higher WER on noisy phone recordings, children, or amateur reciters.
  Our matcher is designed to tolerate ~20–30 % WER.
- The model card gives no training-data details; build our own golden set (docs/09) before trusting numbers.
- Always pass `language="ar"`, `task="transcribe"` explicitly — fine-tuned checkpoints may have stale forced-decoder ids.

## 2. Serving options

| Option | Use | Pros | Cons |
|---|---|---|---|
| **A. faster-whisper (CTranslate2 int8, CPU)** — *default* | Production BFF | 3–4× faster than PyTorch on CPU, low RAM (~300–500 MB) | One-time conversion step |
| B. HF Transformers pipeline (PyTorch) | Local dev, debugging, reference outputs | Zero conversion | Slower, heavier image |
| C. whisper.cpp (GGML) on device | Phase 2 offline | No server cost, offline | Needs FFI plugin, accuracy check after quantization |
| D. sherpa-onnx (ONNX int8) on device | Phase 2 alternative | Mature Android/iOS bindings | Export pipeline per model |

### 2.1 Conversion script (`tools/convert_model/convert.py`)

```python
"""Convert tarteel-ai/whisper-base-ar-quran to CTranslate2 int8 for faster-whisper."""
from pathlib import Path
import subprocess
from huggingface_hub import snapshot_download
from transformers import WhisperTokenizerFast

HF_ID = "tarteel-ai/whisper-base-ar-quran"
SRC = Path("models/hf-whisper-base-ar-quran")
DST = Path("models/whisper-base-ar-quran-ct2-int8")

def main() -> None:
    snapshot_download(HF_ID, local_dir=SRC, ignore_patterns=["runs/*", "*.bin.index.json"])
    # The repo ships vocab.json + merges.txt only; build tokenizer.json for faster-whisper.
    WhisperTokenizerFast.from_pretrained(SRC).save_pretrained(SRC)
    subprocess.run([
        "ct2-transformers-converter",
        "--model", str(SRC),
        "--output_dir", str(DST),
        "--quantization", "int8",
        "--copy_files", "tokenizer.json", "preprocessor_config.json",
        "--force",
    ], check=True)

if __name__ == "__main__":
    main()
```

Requirements: `ctranslate2`, `transformers`, `torch` (CPU wheel is fine, only needed at conversion time), `huggingface_hub`.

### 2.2 Inference wrapper (`services/api/app/asr/model.py`)

```python
from dataclasses import dataclass
import math
import numpy as np
from faster_whisper import WhisperModel

@dataclass(frozen=True)
class AsrResult:
    text: str
    avg_logprob: float      # mean over segments
    no_speech_prob: float
    duration_s: float

class QuranAsr:
    def __init__(self, model_dir: str, cpu_threads: int = 2, num_workers: int = 2) -> None:
        self._model = WhisperModel(model_dir, device="cpu", compute_type="int8",
                                   cpu_threads=cpu_threads, num_workers=num_workers)

    def transcribe(self, pcm16k: np.ndarray) -> AsrResult:
        segments, info = self._model.transcribe(
            pcm16k,
            language="ar",
            task="transcribe",
            beam_size=5,
            temperature=0.0,
            condition_on_previous_text=False,
            without_timestamps=True,
            vad_filter=True,
            vad_parameters={"min_silence_duration_ms": 500},
        )
        segs = list(segments)
        text = " ".join(s.text.strip() for s in segs).strip()
        lp = sum(s.avg_logprob for s in segs) / len(segs) if segs else -5.0
        nsp = max((s.no_speech_prob for s in segs), default=1.0)
        return AsrResult(text=text, avg_logprob=lp, no_speech_prob=nsp, duration_s=info.duration)

    @staticmethod
    def quality(r: AsrResult) -> float:
        """0..1 heuristic ASR quality used in confidence fusion."""
        return max(0.0, min(1.0, math.exp(r.avg_logprob))) * (1.0 - min(r.no_speech_prob, 1.0))
```

- Load the model **once** at startup (FastAPI lifespan), share across requests; run `transcribe` in a thread pool
  (`anyio.to_thread.run_sync`) so the event loop is not blocked.
- Warm-up: transcribe 1 s of silence at startup.

### 2.3 Audio pre-processing (`app/asr/audio.py`)

- Accept `audio/wav`, `audio/x-wav`, `audio/ogg` (Opus), `audio/mp4`/`m4a`, `audio/mpeg`, `audio/webm`, `audio/aac`.
- Decode with PyAV (bundled FFmpeg) → resample to **16 kHz mono float32**, peak-normalize to −1 dBFS.
- Reject: > 2 MB upload (client sends 16 kHz mono ≈ 32 KB/s → 30 s ≈ 1 MB WAV; Opus much smaller), duration < 1.0 s
  or > 30.5 s, RMS < −50 dBFS (silence).
- Longer shared files (e.g. 2-minute voice note): take the **first 30 s** for v1; Phase 2 chunk into 25 s windows with
  5 s overlap and merge matches.

---

## 3. Qur'an search index

Built offline by `tools/build_quran_db` and loaded into memory by the BFF (and later bundled into the app).

### 3.1 Sources

| Field | Source |
|---|---|
| Display Arabic (Uthmani Hafs) | Tanzil Uthmani text (CC BY 3.0, verbatim) or Quran Foundation `text_uthmani` |
| Search text variant A | Tanzil **Uthmani** → normalized (§4) |
| Search text variant B | Tanzil **Simple Clean** (imla'i spelling) → normalized (§4) — closer to what ASR emits, e.g. `العالمين` vs Uthmani `ٱلۡعَـٰلَمِينَ` |
| page (Madani 604), juz, hizb, rub, ruku, manzil, sajda | alquran.cloud `/v1/quran/quran-uthmani` (fields `page`, `juz`, `hizbQuarter`, …) or Quran Foundation verses (`page_number`, `juz_number`) — cross-check both at build time |
| Indonesian translation, tafsir, Latin | equran.id v2 (Kemenag) |

### 3.2 Units

Recitation often spans ayah boundaries or covers only part of a long ayah. The index therefore contains **units**:

- Every single ayah (6,236 units).
- Every window of **2 and 3 consecutive ayat within the same surah** (~12,200 units).
- Alias units for **huruf muqatta'at** ayat (e.g. 2:1 `الم` also indexed as `الف لام ميم`, 19:1 `كهيعص` as
  `كاف ها يا عين صاد`, 42:1–2, 50:1 `ق` as `قاف`, 68:1 `ن` as `نون`, …) because ASR may spell out the letters.

Each unit stores: `unit_id, surah, ayah_start, ayah_end, text_norm_A, text_norm_B, char_offsets[]` where
`char_offsets` maps each ayah boundary inside the unit's normalized text (for precise span → ayah mapping).

### 3.3 Retrieval structures

- Character **3-gram TF-IDF** matrix (scikit-learn `TfidfVectorizer(analyzer="char_wb", ngram_range=(3,3))`, sublinear tf)
  over `text_norm_A ∪ text_norm_B`. ~18k × ~40k sparse — a few MB.
- Word-level inverted index (normalized word → set of unit ids) and smoothed word IDF for rare-word boosting.
- Serialized to `data/quran_index.pkl` (+ SHA-256 in `data/quran_index.sha256`, verified at startup).

---

## 4. Arabic normalization (single source of truth)

The **same** function must be used at index-build time and at query time (Python) and later ported 1:1 to Dart.
Keep golden unit tests for it.

```python
import re
import unicodedata

_TASHKEEL = re.compile(r"[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF]")
_TATWEEL = "\u0640"
_NON_ARABIC = re.compile(r"[^\u0621-\u063A\u0641-\u064A\s]")
_SPACES = re.compile(r"\s+")

_CHAR_MAP = str.maketrans({
    "\u0622": "\u0627",  # آ -> ا
    "\u0623": "\u0627",  # أ -> ا
    "\u0625": "\u0627",  # إ -> ا
    "\u0671": "\u0627",  # ٱ (alef wasla) -> ا
    "\u0672": "\u0627", "\u0673": "\u0627",
    "\u0649": "\u064A",  # ى -> ي
    "\u06CC": "\u064A",  # Farsi yeh -> ي
    "\u0626": "\u064A",  # ئ -> ي
    "\u0624": "\u0648",  # ؤ -> و
    "\u0629": "\u0647",  # ة -> ه
    "\u06A9": "\u0643",  # Farsi kaf -> ك
    "\u0621": "",        # standalone hamza removed
})

def normalize_ar(text: str) -> str:
    t = unicodedata.normalize("NFKC", text)
    t = _TASHKEEL.sub("", t)          # harakat, dagger alef, Qur'anic annotation marks
    t = t.replace(_TATWEEL, "")
    t = t.translate(_CHAR_MAP)
    t = _NON_ARABIC.sub(" ", t)       # ayah numbers, punctuation, latin, ۞ ۩
    return _SPACES.sub(" ", t).strip()
```

Pre-match cleanup on the **query only** (after normalization):
- Strip leading isti'adha: `اعوذ بالله من الشيطان الرجيم` (fuzzy, ratio ≥ 85).
- Strip leading basmala `بسم الله الرحمن الرحيم` and set `had_basmala=True`; if nothing remains, return candidate `1:1`
  with `ambiguous=true` and reason `"basmala_only"`.
- Strip trailing `صدق الله العظيم`.

---

## 5. Matching algorithm

```text
match(transcript, hint) -> MatchResult
  q  = cleanup(normalize_ar(transcript))
  if words(q) < 2: return NOT_FOUND(reason="too_short")

  # Stage 1 — candidate retrieval (fast, recall-oriented)
  C1 = top 50 units by TF-IDF cosine(q, unit)                 # char 3-grams tolerate ASR spelling errors
  C1 += units containing ≥2 rare words of q (idf > p90)       # rescue for heavy ASR noise

  # Stage 2 — alignment re-rank (precision-oriented)
  for u in C1:
      for variant in (u.text_norm_A, u.text_norm_B):
          al = rapidfuzz.fuzz.partial_ratio_alignment(q, variant)   # best local alignment of the shorter string inside the longer
          # NOTE: if len(q) > len(variant) rapidfuzz swaps roles — read src_*/dest_* accordingly
          sim = al.score / 100
          span = (al.dest_start, al.dest_end)
          keep best variant
      covered_ayat = ayat whose char range overlaps span by ≥ 30 % of that ayah or ≥ 12 chars
      len_ratio    = min(len(q), len(span_text)) / max(len(q), len(span_text))
      # Symmetric ratio penalizes a query that is either much shorter or much longer than the span.
      u.align = sim * clamp(len_ratio, 0.6, 1.0) ** 0.5
      u.range = (min(covered_ayat), max(covered_ayat))

  # Stage 3 — collapse & fuse
  group units by resolved range (surah, a_start, a_end); keep max align per range
  prefer the SMALLEST range whose align ≥ best_align − 0.02  (don't over-extend to windows)
  score = 0.75*align + 0.15*tfidf_norm + 0.10*asr_quality
  if hint.surah and range.surah == hint.surah: score += 0.02   (tie-breaker only)

  # Stage 4 — ambiguity
  identical = ranges whose normalized span text equals best span text (e.g. 55:13 repeated refrain)
  margin    = score(best) − score(best distinct, non-overlapping #2)
  confidence = score if not identical else min(score, 0.79)    # force picker for true duplicates
  if words(q) < 4: confidence = min(confidence, 0.79)

  return {best, candidates[:5], confidence, margin, ambiguous: identical or margin < 0.10}
```

### 5.1 Decision thresholds (client behaviour)

| Condition | Client action |
|---|---|
| `confidence ≥ 0.80` **and** `margin ≥ 0.10` **and** `!ambiguous` | Auto-navigate + highlight |
| `0.55 ≤ confidence < 0.80` **or** `ambiguous` | Show top-3 picker (bottom sheet) |
| `confidence < 0.55` | "Ayat tidak ditemukan" + tips |

Thresholds live in server config (`MATCH_AUTO_THRESHOLD`, `MATCH_MIN_THRESHOLD`, `MATCH_MIN_MARGIN`) and are also
returned in the response (`thresholds`) so the client never hardcodes them. Tune them on the golden set (docs/09).

### 5.2 Page resolution

`page = ayah_page[(surah, ayah_start)]` from the bundled DB (Madani 604). If a range crosses a page break, navigate to
the first page; the reader auto-scrolls to show the start of the highlight.

### 5.3 Complexity & latency budget

| Step | Target (p95, 2 vCPU) |
|---|---|
| Upload 10 s Opus (~20 KB) on 4G | 300 ms |
| Decode + resample | 30 ms |
| ASR whisper-base int8, 10 s audio, beam 5 | 600–900 ms |
| TF-IDF retrieval (18k units) | 10 ms |
| Alignment re-rank (≤ 60 units × 2 variants) | 15 ms |
| Response + navigation render | 300 ms |
| **Total** | **≈ 1.5–2 s** (budget 3 s) |

---

## 6. API contract (summary)

`POST /v1/voice/detect` — multipart `audio` file + optional `hint_surah`, `locale`. Full schema in
`docs/05-BACKEND-API-SPEC.md` and `docs/api/openapi.yaml`.

```json
{
  "request_id": "b0c1…",
  "transcript": "الله لا اله الا هو الحي القيوم لا تاخذه سنه ولا نوم",
  "confidence": 0.93,
  "margin": 0.31,
  "ambiguous": false,
  "best": {
    "surah": 2, "ayah_start": 255, "ayah_end": 255,
    "key": "2:255", "page": 42, "juz": 3,
    "surah_name_latin": "Al-Baqarah", "score": 0.93,
    "match_span": {"ayah": 255, "word_start": 0, "word_end": 9}
  },
  "candidates": [ { "...": "top-5, same shape as best" } ],
  "thresholds": {"auto": 0.80, "min": 0.55, "margin": 0.10},
  "timing_ms": {"decode": 21, "asr": 742, "match": 18, "total": 790}
}
```

---

## 7. Mobile capture requirements

- Package `record`: `AudioEncoder.wav` (PCM 16-bit) **16 000 Hz, mono**; or `AudioEncoder.opus` 16 kHz 24 kbps to save data.
- Client-side VAD: energy-based (RMS over 30 ms frames) — auto-stop after 2.0 s silence once ≥ 2 s of speech captured.
- Enforce 2–30 s; show live amplitude waveform.
- Upload with `dio` multipart, timeout 15 s, cancellable (`CancelToken`).
- Never store the recording after upload completes (delete temp file in `finally`).

## 8. Evaluation plan (summary — full detail in docs/09)

- Golden set ≥ 2,000 clips: EveryAyah per-ayah recordings (multiple reciters), sliced fragments (partial ayah, 2–3 ayah
  spans), noisy augmentations (café noise at SNR 10/5 dB, phone-speaker re-recording), and ≥ 300 real user recordings
  (consented) from Indonesian reciters.
- Metrics: ASR WER/CER (normalized), top-1 / top-3 ayah accuracy, range exact-match & IoU, false-auto-navigate rate
  (auto-navigated to wrong ayah — must be ≤ 1 %), latency p50/p95.

## 9. Roadmap for the AI feature

| Phase | Change |
|---|---|
| v1 | Server faster-whisper base + n-gram/fuzzy matcher (this doc) |
| v1.1 | Chunked long audio (> 30 s), history of detections, share-to-app |
| v2 | On-device inference (whisper.cpp / sherpa-onnx) + Dart port of matcher for offline detection |
| v2 | A/B test `tarteel-ai/whisper-tiny-ar-quran` (the only other public Tarteel checkpoint) for on-device speed; for server accuracy, evaluate fine-tuning `whisper-small`/`large-v3` on public Qur'an recitation data if base accuracy is insufficient |
| v3 | Streaming "follow-along" mode: 1–2 s chunks, word-level alignment to highlight the current word while reciting; optional audio-embedding retrieval (HuBERT/WavLM + FAISS) as a pre-filter |
| v3 | Recitation mistake hints (skipped/wrong words) — diff aligned transcript vs. ayah words |
