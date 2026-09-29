"""Decode untrusted voice recordings into Whisper's 16 kHz mono PCM input."""

from __future__ import annotations

import math
from dataclasses import dataclass
from io import BytesIO

import av
import numpy as np
from numpy.typing import NDArray

TARGET_SAMPLE_RATE = 16_000
TARGET_PEAK = 10 ** (-1 / 20)  # -1 dBFS
DEFAULT_MAX_BYTES = 2 * 1024 * 1024
DEFAULT_MIN_DURATION_SECONDS = 1.0
DEFAULT_MAX_DURATION_SECONDS = 30.5
DEFAULT_SILENCE_DBFS = -50.0


@dataclass(frozen=True, slots=True)
class AudioProblem(Exception):
    """A stable, API-mappable error raised while validating uploaded audio."""

    status: int
    code: str
    title: str
    detail: str

    def __str__(self) -> str:
        return self.detail


def _problem(code: str, status: int, title: str, detail: str) -> AudioProblem:
    return AudioProblem(status=status, code=code, title=title, detail=detail)


def decode_to_pcm16k(
    raw: bytes,
    *,
    max_bytes: int = DEFAULT_MAX_BYTES,
    min_duration_seconds: float = DEFAULT_MIN_DURATION_SECONDS,
    max_duration_seconds: float = DEFAULT_MAX_DURATION_SECONDS,
    silence_dbfs: float = DEFAULT_SILENCE_DBFS,
) -> NDArray[np.float32]:
    """Decode supported audio bytes into peak-normalized mono float32 at 16 kHz.

    The decoder detects format from the media container, not the client filename or
    MIME type. It stops decoding once the configured maximum duration is exceeded,
    limiting work on oversized or maliciously long compressed streams.
    """
    if len(raw) > max_bytes:
        raise _problem(
            "AUDIO_TOO_LONG", 413, "Audio too large", f"Audio exceeds the {max_bytes}-byte limit."
        )
    if not raw:
        raise _problem(
            "AUDIO_UNSUPPORTED",
            415,
            "Unsupported audio",
            "The uploaded audio is empty or unreadable.",
        )
    if min_duration_seconds <= 0 or max_duration_seconds <= min_duration_seconds:
        raise ValueError("Audio duration limits must be positive and max must exceed min.")

    chunks: list[NDArray[np.float32]] = []
    sample_count = 0
    resampler = av.AudioResampler(format="fltp", layout="mono", rate=TARGET_SAMPLE_RATE)
    saw_audio_stream = False
    max_samples = math.ceil(max_duration_seconds * TARGET_SAMPLE_RATE)

    try:
        with av.open(BytesIO(raw), mode="r") as container:
            audio_streams = container.streams.audio
            if not audio_streams:
                raise _problem(
                    "AUDIO_UNSUPPORTED",
                    415,
                    "Unsupported audio",
                    "The uploaded file has no audio stream.",
                )
            stream = audio_streams[0]
            for frame in container.decode(stream):
                saw_audio_stream = True
                for output_frame in resampler.resample(frame):
                    samples = output_frame.to_ndarray().reshape(-1).astype(np.float32, copy=False)
                    if not np.isfinite(samples).all():
                        raise _problem(
                            "AUDIO_UNSUPPORTED",
                            415,
                            "Unsupported audio",
                            "Decoded audio contains invalid samples.",
                        )
                    remaining = max_samples - sample_count
                    if samples.size > remaining:
                        raise _problem(
                            "AUDIO_TOO_LONG",
                            413,
                            "Audio too long",
                            "Audio exceeds the 30.5-second limit.",
                        )
                    if samples.size:
                        chunks.append(np.ascontiguousarray(samples, dtype=np.float32))
                        sample_count += samples.size
            # Flush filter delay so resampling retains samples held for its final output frame.
            for output_frame in resampler.resample(None):
                samples = output_frame.to_ndarray().reshape(-1).astype(np.float32, copy=False)
                remaining = max_samples - sample_count
                if samples.size > remaining:
                    raise _problem(
                        "AUDIO_TOO_LONG",
                        413,
                        "Audio too long",
                        "Audio exceeds the 30.5-second limit.",
                    )
                if samples.size:
                    chunks.append(np.ascontiguousarray(samples, dtype=np.float32))
                    sample_count += samples.size
    except AudioProblem:
        raise
    except (av.error.FFmpegError, OSError, ValueError) as exc:
        raise _problem(
            "AUDIO_UNSUPPORTED",
            415,
            "Unsupported audio",
            "The uploaded audio could not be decoded.",
        ) from exc

    if not saw_audio_stream or not chunks:
        raise _problem(
            "AUDIO_UNSUPPORTED", 415, "Unsupported audio", "No decodable audio samples were found."
        )

    pcm = np.concatenate(chunks).astype(np.float32, copy=False)
    duration_seconds = pcm.size / TARGET_SAMPLE_RATE
    if duration_seconds < min_duration_seconds:
        raise _problem(
            "AUDIO_TOO_SHORT",
            422,
            "Audio too short",
            "Audio must contain at least 1 second of samples.",
        )
    if duration_seconds > max_duration_seconds:
        raise _problem(
            "AUDIO_TOO_LONG", 413, "Audio too long", "Audio exceeds the 30.5-second limit."
        )

    rms = float(np.sqrt(np.mean(np.square(pcm, dtype=np.float64))))
    rms_dbfs = 20 * math.log10(rms) if rms > 0 else -math.inf
    if rms_dbfs < silence_dbfs:
        raise _problem(
            "AUDIO_SILENT",
            422,
            "Audio is silent",
            "Audio level is below the configured silence threshold.",
        )

    peak = float(np.max(np.abs(pcm)))
    if peak == 0:
        raise _problem("AUDIO_SILENT", 422, "Audio is silent", "Audio contains no audible samples.")
    pcm = np.multiply(pcm, TARGET_PEAK / peak, dtype=np.float32)
    return np.ascontiguousarray(pcm, dtype=np.float32)
