"""Live Voice Finder protocol and stabilization checks."""

from __future__ import annotations

import asyncio
import json
from types import SimpleNamespace
from uuid import uuid4

import pytest
from app.matching.matcher import MatchCandidate, MatchResult
from app.routers.live_voice import (
    MIN_WINDOW_BYTES,
    ROLLING_BYTES,
    WINDOW_STEP_BYTES,
    LiveInferenceBusy,
    LiveStabilizer,
    _infer,
    router,
)
from app.settings import VoiceSettings
from fastapi import FastAPI


class FakeRedis:
    def __init__(self, *, allow_rate: bool = True, allow_acquire: bool = True) -> None:
        self.acquired = 0
        self.released = 0
        self.allow_rate = allow_rate
        self.allow_acquire = allow_acquire

    async def eval(self, script: str, *_args: object) -> list[int] | int:
        if "redis.call('GET'" in script:
            self.released += 1
            return 1
        return [int(self.allow_rate), 0]

    async def set(self, *_args: object, **_kwargs: object) -> bool:
        self.acquired += 1
        return self.allow_acquire


def _result(ayah: int, *, ambiguous: bool = False) -> MatchResult:
    best = MatchCandidate(2, ayah, ayah, 0.91, 0.92, 0.85)
    return MatchResult(best, (best,), 0.91, 0.4, ambiguous, "identical_ayat" if ambiguous else None)


def test_live_stabilizer_requires_repeat_and_follows_adjacent_ayah() -> None:
    stable = LiveStabilizer()
    assert stable.update(_result(255)).kind == "candidate"
    first = stable.update(_result(255))
    assert first.kind == "ayah" and first.revision == 1
    assert stable.update(_result(256)).kind == "candidate"
    second = stable.update(_result(256))
    assert second.kind == "ayah" and second.revision == 2
    assert stable.stable_surah == 2


def test_live_stabilizer_does_not_jump_on_ambiguous_or_single_far_match() -> None:
    stable = LiveStabilizer()
    stable.update(_result(255))
    stable.update(_result(255))
    assert stable.update(_result(13, ambiguous=True)).kind == "ambiguous"
    assert stable.update(_result(13)).kind == "candidate"
    assert stable.update(_result(13)).kind == "candidate"
    assert stable.update(_result(13)).kind == "ayah"


def test_live_stabilizer_deduplicates_repeated_ayah_and_tracks_ranges() -> None:
    stable = LiveStabilizer()
    stable.update(_result(255))
    assert stable.update(_result(255)).revision == 1
    assert stable.update(_result(255)).kind == "candidate"
    assert stable.update(_result(255, ambiguous=True)).kind == "ambiguous"
    assert stable.update(_result(255)).kind == "candidate"

    span = MatchCandidate(2, 254, 255, 0.91, 0.92, 0.85)
    result = MatchResult(span, (span,), 0.91, 0.4, False, None)
    assert stable.update(result).kind == "candidate"
    changed = stable.update(result)
    assert (changed.kind, changed.ayah_start, changed.ayah_end, changed.revision) == (
        "ayah",
        254,
        255,
        2,
    )


def _app() -> FastAPI:
    app = FastAPI()
    app.include_router(router)
    app.state.redis = FakeRedis()
    app.state.voice_settings = VoiceSettings()
    app.state.asr = SimpleNamespace()
    app.state.quran_matcher = SimpleNamespace()
    app.state.quran_metadata = SimpleNamespace()
    app.state.live_inference_slots = asyncio.Semaphore(2)
    return app


def _exchange(
    *frames: dict[str, object],
    app: FastAPI | None = None,
    frame_delay: float = 0,
    device_id: str | None = None,
    query: bytes = b"",
    sent_out: list[dict[str, object]] | None = None,
) -> list[dict[str, object]]:
    app = app or _app()
    events = iter([{"type": "websocket.connect"}, *frames])
    sent: list[dict[str, object]] = []

    async def receive() -> dict[str, object]:
        if frame_delay:
            await asyncio.sleep(frame_delay)
        return next(events)

    async def send(message: dict[str, object]) -> None:
        sent.append(message)

    scope: dict[str, object] = {
        "type": "websocket",
        "asgi": {"version": "3.0"},
        "scheme": "ws",
        "path": "/v1/voice/live",
        "raw_path": b"/v1/voice/live",
        "query_string": query,
        "headers": [(b"x-device-id", (device_id or str(uuid4())).encode())],
        "server": ("test", 80),
        "client": ("test", 1234),
        "root_path": "",
        "app": app,
        "subprotocols": [],
    }
    asyncio.run(app(scope, receive, send))  # type: ignore[arg-type]
    if sent_out is not None:
        sent_out.extend(sent)
    return [
        json.loads(message["text"])
        for message in sent
        if message["type"] == "websocket.send" and message.get("text")
    ]


def test_live_protocol_ready_stop_and_invalid_frame() -> None:
    messages = _exchange({"type": "websocket.receive", "text": '{"type":"stop"}'})
    assert messages == [
        {"type": "ready", "sequence": 0, "sample_rate": 16000, "format": "pcm_s16le_mono"},
        {"type": "stopped", "sequence": 1},
    ]
    messages = _exchange({"type": "websocket.receive", "bytes": b"\x00"})
    assert messages[1]["code"] == "INVALID_PCM_FRAME"


def test_live_disconnect_and_invalid_command_release_session() -> None:
    for frame, expected in [
        ({"type": "websocket.disconnect", "code": 1001}, None),
        ({"type": "websocket.receive", "text": '{"type":"unknown"}'}, "INVALID_COMMAND"),
        ({"type": "websocket.receive", "text": "[]"}, "INVALID_COMMAND"),
    ]:
        app = _app()
        messages = _exchange(frame, app=app)
        assert app.state.redis.acquired == 1
        assert app.state.redis.released == 1
        if expected is not None:
            assert messages[-1]["code"] == expected


def test_live_rejects_invalid_header_hint_and_connection_limits() -> None:
    invalid_device: list[dict[str, object]] = []
    assert _exchange(device_id="invalid", sent_out=invalid_device) == []
    assert invalid_device[-1]["code"] == 4400

    invalid_hint: list[dict[str, object]] = []
    assert _exchange(query=b"hint_surah=115", sent_out=invalid_hint) == []
    assert invalid_hint[-1]["code"] == 4400

    for redis in [
        FakeRedis(allow_rate=False),
        FakeRedis(allow_acquire=False),
    ]:
        app = _app()
        app.state.redis = redis
        events: list[dict[str, object]] = []
        assert _exchange(app=app, sent_out=events) == []
        assert events[-1]["code"] == 4429
        assert redis.released == 0


def test_live_backpressure_cancels_inference_and_releases_session(
    monkeypatch: object,
) -> None:
    from pytest import MonkeyPatch

    patch = monkeypatch
    assert isinstance(patch, MonkeyPatch)
    cancelled = False

    async def slow_infer(*_args: object) -> MatchResult:
        nonlocal cancelled
        try:
            await asyncio.sleep(30)
        except asyncio.CancelledError:
            cancelled = True
            raise
        return _result(255)

    patch.setattr("app.routers.live_voice._infer", slow_infer)
    app = _app()
    messages = _exchange(
        *([{"type": "websocket.receive", "bytes": b"\x00" * 32000}] * 11),
        app=app,
        frame_delay=0.001,
    )
    assert messages[-1]["code"] == "BACKPRESSURE"
    assert cancelled
    assert app.state.redis.released == 1


def test_live_rolling_inference_snapshot_stays_bounded(monkeypatch: object) -> None:
    from pytest import MonkeyPatch

    patch = monkeypatch
    assert isinstance(patch, MonkeyPatch)
    sizes: list[int] = []

    async def capture_infer(pcm_bytes: bytes, *_args: object) -> MatchResult:
        sizes.append(len(pcm_bytes))
        await asyncio.sleep(0)
        return _result(255)

    patch.setattr("app.routers.live_voice._infer", capture_infer)
    app = _app()
    app.state.quran_metadata = SimpleNamespace(ayah=lambda _s, _a: {"page": 42})
    messages = _exchange(
        *([{"type": "websocket.receive", "bytes": b"\x00" * 32000}] * 20),
        {"type": "websocket.receive", "text": '{"type":"stop"}'},
        app=app,
        frame_delay=0.003,
    )
    assert sizes
    assert all(MIN_WINDOW_BYTES <= size <= ROLLING_BYTES for size in sizes)
    assert messages[-1]["type"] == "stopped"


def test_live_starts_after_one_and_half_seconds_then_checks_each_second(
    monkeypatch: object,
) -> None:
    from pytest import MonkeyPatch

    patch = monkeypatch
    assert isinstance(patch, MonkeyPatch)
    assert MIN_WINDOW_BYTES == 48_000
    assert WINDOW_STEP_BYTES == 32_000
    sizes: list[int] = []

    async def capture_infer(pcm_bytes: bytes, *_args: object) -> MatchResult:
        sizes.append(len(pcm_bytes))
        return _result(255)

    patch.setattr("app.routers.live_voice._infer", capture_infer)
    app = _app()
    app.state.quran_metadata = SimpleNamespace(ayah=lambda _s, _a: {"page": 42})
    _exchange(
        *([{"type": "websocket.receive", "bytes": b"\x00" * 16_000}] * 6),
        {"type": "websocket.receive", "text": '{"type":"stop"}'},
        app=app,
        frame_delay=0.003,
    )
    assert sizes[:2] == [48_000, 80_000]


def test_live_inference_capacity_exhaustion_is_explicit(monkeypatch: object) -> None:
    from pytest import MonkeyPatch

    patch = monkeypatch
    assert isinstance(patch, MonkeyPatch)
    patch.setattr("app.routers.live_voice.INFERENCE_SLOT_WAIT_SECONDS", 0.001)

    async def attempt() -> None:
        with pytest.raises(LiveInferenceBusy):
            await _infer(
                b"\x00" * 32000, SimpleNamespace(), SimpleNamespace(), None, asyncio.Semaphore(0)
            )

    asyncio.run(attempt())


def test_live_protocol_follows_stable_successive_ayat(monkeypatch: object) -> None:
    from pytest import MonkeyPatch

    patch = monkeypatch
    assert isinstance(patch, MonkeyPatch)
    counter = 0

    async def fake_infer(*_args: object) -> MatchResult:
        nonlocal counter
        counter += 1
        return _result(255 if counter <= 2 else 256)

    patch.setattr("app.routers.live_voice._infer", fake_infer)
    app = _app()
    app.state.quran_metadata = SimpleNamespace(ayah=lambda _s, _a: {"page": 42})
    messages = _exchange(
        *([{"type": "websocket.receive", "bytes": b"\x00" * 32000}] * 8),
        {"type": "websocket.receive", "text": '{"type":"stop"}'},
        app=app,
        frame_delay=0.002,
    )
    stable = [message for message in messages if message["type"] == "ayah"]
    assert [(message["surah"], message["ayah_end"], message["revision"]) for message in stable] == [
        (2, 255, 1),
        (2, 256, 2),
    ]
    assert messages[-1]["type"] == "stopped"
    assert [message["sequence"] for message in messages] == list(range(len(messages)))
