"""ASR inference metadata, startup lifecycle, and event-loop responsiveness tests."""

from __future__ import annotations

import asyncio
from threading import Event, Lock, get_ident
from types import SimpleNamespace

import anyio
import numpy as np
import pytest
from app.asr.model import AsrResult, QuranAsr
from app.main import lifespan
from app.routers.health import router as health_router
from fastapi import FastAPI


class FakeWhisperModel:
    def __init__(self) -> None:
        self.options: dict[str, object] = {}

    def transcribe(
        self, pcm: np.ndarray, **options: object
    ) -> tuple[list[SimpleNamespace], SimpleNamespace]:
        self.options = options
        return (
            [
                SimpleNamespace(text=" الْحَمْدُ ", avg_logprob=-0.2, no_speech_prob=0.1),
                SimpleNamespace(text=" لِلَّهِ رَبِّ الْعَالَمِينَ", avg_logprob=-0.4, no_speech_prob=0.2),
            ],
            SimpleNamespace(duration=pcm.size / 16_000),
        )


async def _asgi_get(app: FastAPI, path: str) -> list[dict[str, object]]:
    """Issue one in-process ASGI GET request without adding an HTTP client dependency."""
    messages: list[dict[str, object]] = []

    async def receive() -> dict[str, object]:
        return {"type": "http.request", "body": b"", "more_body": False}

    async def send(message: dict[str, object]) -> None:
        messages.append(message)

    raw_path = path.encode()
    scope: dict[str, object] = {
        "type": "http",
        "asgi": {"version": "3.0"},
        "http_version": "1.1",
        "method": "GET",
        "scheme": "http",
        "path": path,
        "raw_path": raw_path,
        "query_string": b"",
        "headers": [],
        "server": ("test", 80),
        "client": ("test", 1),
        "root_path": "",
    }
    await app(scope, receive, send)  # type: ignore[arg-type]
    return messages


def test_transcribe_returns_combined_text_and_segment_metadata(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    fake_model = FakeWhisperModel()
    monkeypatch.setattr("app.asr.model.WhisperModel", lambda *args, **kwargs: fake_model)
    asr = QuranAsr("converted-model")

    result = asr.transcribe(np.zeros(32_000, dtype=np.float32))

    assert result.text == "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ"
    assert result.avg_logprob == pytest.approx(-0.3)
    assert result.no_speech_prob == pytest.approx(0.2)
    assert result.duration_s == pytest.approx(2.0)
    assert fake_model.options["language"] == "ar"
    assert fake_model.options["task"] == "transcribe"
    assert fake_model.options["temperature"] == 0.0
    assert fake_model.options["condition_on_previous_text"] is False
    assert fake_model.options["without_timestamps"] is True
    assert fake_model.options["vad_filter"] is True


def test_empty_transcription_has_safe_confidence_defaults(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    class EmptyModel:
        def transcribe(self, *_args: object, **_kwargs: object) -> tuple[list[object], object]:
            return [], SimpleNamespace(duration=1.0)

    monkeypatch.setattr("app.asr.model.WhisperModel", lambda *args, **kwargs: EmptyModel())
    result = QuranAsr("converted-model").transcribe(np.zeros(16_000, dtype=np.float32))

    assert result.text == ""
    assert result.avg_logprob == -5.0
    assert result.no_speech_prob == 1.0
    assert result.duration_s == 1.0
    assert QuranAsr.quality(result) == 0.0


@pytest.mark.parametrize(
    ("result", "expected"),
    [
        (AsrResult("a", 0.0, 0.0, 1.0), 1.0),
        (AsrResult("a", -1.0, 0.5, 1.0), np.exp(-1.0) * 0.5),
        (AsrResult("", -5.0, 1.0, 1.0), 0.0),
    ],
)
def test_quality_is_bounded(result: AsrResult, expected: float) -> None:
    assert QuranAsr.quality(result) == pytest.approx(expected)


def test_eight_inferences_run_off_loop_while_healthz_remains_responsive() -> None:
    async def scenario() -> None:
        entered = Event()
        release = Event()
        lock = Lock()
        worker_threads: set[int] = set()
        started = 0

        class BlockingModel:
            def transcribe(
                self, pcm: np.ndarray, **_options: object
            ) -> tuple[list[object], object]:
                nonlocal started
                with lock:
                    worker_threads.add(get_ident())
                    started += 1
                    if started == 8:
                        entered.set()
                release.wait(timeout=3)
                return [], SimpleNamespace(duration=pcm.size / 16_000)

        asr = QuranAsr.__new__(QuranAsr)
        asr._model = BlockingModel()  # type: ignore[assignment]
        asr._beam_size = 5
        pcm = np.zeros(16_000, dtype=np.float32)
        app = FastAPI()
        app.state.asr = asr
        app.include_router(health_router)

        @app.get("/test-inference")
        async def test_inference() -> dict[str, float]:
            result = await app.state.asr.transcribe_async(pcm)
            return {"duration_s": result.duration_s}

        tasks = [asyncio.create_task(_asgi_get(app, "/test-inference")) for _ in range(8)]

        try:
            await anyio.to_thread.run_sync(entered.wait, 3)
            health = await asyncio.wait_for(_asgi_get(app, "/healthz"), timeout=0.25)
            assert health[0]["status"] == 200
            assert all(not task.done() for task in tasks)
        finally:
            release.set()

        results = await asyncio.gather(*tasks)
        assert len(results) == 8
        assert len(worker_threads) > 1

    asyncio.run(scenario())


def test_lifespan_loads_and_warms_asr_once(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[str] = []

    class StubAsr:
        model_id = "tarteel-ai/whisper-base-ar-quran"

        def warmup(self) -> None:
            calls.append("warmup")

    expected_asr = StubAsr()
    expected_metadata = object()
    expected_matcher = object()
    expected_redis = SimpleNamespace(aclose=lambda: asyncio.sleep(0))
    monkeypatch.setattr("app.main._load_asr", lambda _settings: expected_asr)
    monkeypatch.setattr("app.main._load_voice_data", lambda _settings: ({}, expected_metadata))
    monkeypatch.setattr("app.main.QuranMatcher", lambda *_args, **_kwargs: expected_matcher)
    monkeypatch.setattr("app.main.Redis.from_url", lambda *_args, **_kwargs: expected_redis)
    app = FastAPI()

    async def scenario() -> None:
        async with lifespan(app):
            assert app.state.asr is expected_asr
            assert app.state.quran_matcher is expected_matcher
            assert app.state.quran_metadata is expected_metadata
            assert app.state.redis is expected_redis
            assert calls == ["warmup"]

    asyncio.run(scenario())
    assert app.state.asr is None
    assert app.state.quran_matcher is None
    assert app.state.quran_metadata is None
