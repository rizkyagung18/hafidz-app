"""Audio decoder contract tests using generated, license-free audio fixtures."""

from __future__ import annotations

import wave
from io import BytesIO

import av
import numpy as np
import pytest
from app.asr.audio import TARGET_PEAK, TARGET_SAMPLE_RATE, AudioProblem, decode_to_pcm16k


def _tone(sample_rate: int = 16_000, duration: float = 2.0) -> np.ndarray:
    time = np.arange(int(sample_rate * duration), dtype=np.float32) / sample_rate
    return (0.2 * np.sin(2 * np.pi * 440 * time)).astype(np.float32)


def _wav(samples: np.ndarray, sample_rate: int = 16_000) -> bytes:
    pcm16 = np.clip(samples * 32767, -32768, 32767).astype("<i2")
    output = BytesIO()
    with wave.open(output, "wb") as file:
        file.setnchannels(1)
        file.setsampwidth(2)
        file.setframerate(sample_rate)
        file.writeframes(pcm16.tobytes())
    return output.getvalue()


def _encoded_audio(codec: str, container_format: str) -> bytes:
    sample_rate = 16_000
    pcm16 = np.clip(_tone() * 32767, -32768, 32767).astype("int16").reshape(1, -1)
    output = BytesIO()
    with av.open(output, mode="w", format=container_format) as container:
        stream = container.add_stream(codec, rate=sample_rate)
        stream.layout = "mono"
        frame = av.AudioFrame.from_ndarray(pcm16, format="s16", layout="mono")
        frame.sample_rate = sample_rate
        for packet in stream.encode(frame):
            container.mux(packet)
        for packet in stream.encode(None):
            container.mux(packet)
    return output.getvalue()


@pytest.mark.parametrize(
    ("codec", "container_format"),
    [("libopus", "ogg"), ("aac", "ipod"), ("libmp3lame", "mp3")],
    ids=["opus", "m4a-aac", "mp3"],
)
def test_decodes_compressed_audio(codec: str, container_format: str) -> None:
    decoded = decode_to_pcm16k(_encoded_audio(codec, container_format))

    assert decoded.dtype == np.float32
    assert decoded.ndim == 1
    assert decoded.size == pytest.approx(2 * TARGET_SAMPLE_RATE, abs=2_000)
    assert np.isfinite(decoded).all()
    assert float(np.max(np.abs(decoded))) == pytest.approx(TARGET_PEAK, abs=1e-5)


def test_decodes_wav_and_resamples_to_16khz_mono() -> None:
    decoded = decode_to_pcm16k(_wav(_tone(sample_rate=44_100), sample_rate=44_100))

    assert decoded.dtype == np.float32
    assert decoded.ndim == 1
    assert decoded.size == pytest.approx(2 * TARGET_SAMPLE_RATE, abs=2)
    assert float(np.max(np.abs(decoded))) == pytest.approx(TARGET_PEAK, abs=1e-5)


@pytest.mark.parametrize(
    ("raw", "expected_code", "expected_status"),
    [
        (_wav(_tone(duration=0.5)), "AUDIO_TOO_SHORT", 422),
        (_wav(np.zeros(2 * TARGET_SAMPLE_RATE, dtype=np.float32)), "AUDIO_SILENT", 422),
        (b"not an audio container", "AUDIO_UNSUPPORTED", 415),
    ],
    ids=["too-short", "silent", "unsupported"],
)
def test_rejects_invalid_audio(raw: bytes, expected_code: str, expected_status: int) -> None:
    with pytest.raises(AudioProblem) as error:
        decode_to_pcm16k(raw)

    assert error.value.code == expected_code
    assert error.value.status == expected_status


def test_rejects_upload_larger_than_byte_limit_before_decode() -> None:
    with pytest.raises(AudioProblem, match="Audio exceeds") as error:
        decode_to_pcm16k(b"x" * 10, max_bytes=9)

    assert error.value.code == "AUDIO_TOO_LONG"
    assert error.value.status == 413


def test_rejects_audio_longer_than_duration_limit() -> None:
    raw = _wav(_tone(duration=31.0))

    with pytest.raises(AudioProblem) as error:
        decode_to_pcm16k(raw)

    assert error.value.code == "AUDIO_TOO_LONG"
    assert error.value.status == 413


def test_rejects_corrupt_audio_with_stable_problem_code() -> None:
    raw = b"\x00" * 128

    with pytest.raises(AudioProblem) as error:
        decode_to_pcm16k(raw)

    assert error.value.code == "AUDIO_UNSUPPORTED"
    assert error.value.status == 415
