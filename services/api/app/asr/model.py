"""Arabic Qur'an transcription using the converted faster-whisper model."""

from __future__ import annotations

import math
from dataclasses import dataclass
from pathlib import Path

import anyio
import numpy as np
from app.asr.audio import TARGET_SAMPLE_RATE
from faster_whisper import WhisperModel  # type: ignore[import-untyped]
from numpy.typing import NDArray

MODEL_ID = "tarteel-ai/whisper-base-ar-quran"
DEFAULT_MODEL_PATH = (
    Path(__file__).resolve().parents[4] / "models" / "whisper-base-ar-quran-ct2-int8"
)


@dataclass(frozen=True, slots=True)
class AsrResult:
    """Text and decoding confidence metadata for a single audio sample."""

    text: str
    avg_logprob: float
    no_speech_prob: float
    duration_s: float


class QuranAsr:
    """Loaded, CPU-int8 Whisper model with sync and event-loop-safe inference APIs."""

    model_id = MODEL_ID

    def __init__(
        self,
        model_dir: str | Path,
        cpu_threads: int = 2,
        num_workers: int = 2,
        beam_size: int = 5,
    ) -> None:
        if cpu_threads < 1 or num_workers < 1 or beam_size < 1:
            raise ValueError("cpu_threads, num_workers, and beam_size must be positive.")
        self._beam_size = beam_size
        self._model = WhisperModel(
            str(model_dir),
            device="cpu",
            compute_type="int8",
            cpu_threads=cpu_threads,
            num_workers=num_workers,
        )

    def transcribe(self, pcm16k: NDArray[np.float32]) -> AsrResult:
        """Run inference synchronously; use ``transcribe_async`` in async routes."""
        return self._transcribe(pcm16k, vad_filter=True)

    async def transcribe_async(self, pcm16k: NDArray[np.float32]) -> AsrResult:
        """Offload CPU-bound CTranslate2 work so it cannot block the ASGI event loop."""
        return await anyio.to_thread.run_sync(self.transcribe, pcm16k)

    def warmup(self) -> None:
        """Run one second of silence through inference once after model loading."""
        silence = np.zeros(TARGET_SAMPLE_RATE, dtype=np.float32)
        # Disable VAD for warm-up so the sample reaches the model instead of being skipped.
        self._transcribe(silence, vad_filter=False)

    def _transcribe(self, pcm16k: NDArray[np.float32], *, vad_filter: bool) -> AsrResult:
        segments, info = self._model.transcribe(
            pcm16k,
            language="ar",
            task="transcribe",
            beam_size=self._beam_size,
            temperature=0.0,
            condition_on_previous_text=False,
            without_timestamps=True,
            vad_filter=vad_filter,
            vad_parameters={"min_silence_duration_ms": 500} if vad_filter else None,
        )
        # faster-whisper evaluates generation lazily; consume the generator inside
        # this worker thread so model inference also remains off the event loop.
        decoded_segments = list(segments)
        text = " ".join(segment.text.strip() for segment in decoded_segments).strip()
        avg_logprob = (
            sum(segment.avg_logprob for segment in decoded_segments) / len(decoded_segments)
            if decoded_segments
            else -5.0
        )
        no_speech_prob = max((segment.no_speech_prob for segment in decoded_segments), default=1.0)
        return AsrResult(
            text=text,
            avg_logprob=float(avg_logprob),
            no_speech_prob=float(no_speech_prob),
            duration_s=float(info.duration),
        )

    @staticmethod
    def quality(result: AsrResult) -> float:
        """Return a bounded 0..1 heuristic from model log probability and silence score."""
        logprob_score = max(0.0, min(1.0, math.exp(result.avg_logprob)))
        speech_score = 1.0 - max(0.0, min(1.0, result.no_speech_prob))
        return logprob_score * speech_score
