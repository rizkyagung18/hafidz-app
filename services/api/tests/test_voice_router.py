"""Contract and lifecycle tests for the voice detection route."""

from __future__ import annotations

import asyncio
import json
import math
import wave
from io import BytesIO
from pathlib import Path
from types import SimpleNamespace
from uuid import uuid4

import numpy as np
import pytest
import schemathesis
import yaml
from app.asr.model import AsrResult
from app.matching.matcher import MatchCandidate, MatchResult
from app.matching.metadata import QuranMetadata
from app.routers.voice import (
    VoiceMetrics,
    install_voice_error_handlers,
    metrics_router,
    router,
)
from app.settings import VoiceSettings
from fastapi import FastAPI
from hypothesis import settings as hypothesis_settings
from schemathesis.python.asgi import ASGIClient
from starlette.datastructures import UploadFile as StarletteUploadFile


class FakeRedis:
    def __init__(self, result: list[int] | None = None) -> None:
        self.result = result or [1, 0]
        self.keys: list[str] = []

    async def eval(self, _script: str, _key_count: int, *args: object) -> list[int]:
        self.keys = [str(args[0]), str(args[1])]
        return self.result


class FakeAsr:
    def __init__(self) -> None:
        self.pcm: np.ndarray | None = None

    async def transcribe_async(self, pcm: np.ndarray) -> AsrResult:
        self.pcm = pcm
        return AsrResult("قلم دفتر شاهد", -0.1, 0.02, pcm.size / 16_000)


def _wav(duration: float = 1.5) -> bytes:
    samples = np.arange(round(16_000 * duration), dtype=np.float32) / 16_000
    samples = (0.2 * np.sin(2 * math.pi * 440 * samples) * 32767).astype("<i2")
    output = BytesIO()
    with wave.open(output, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(16_000)
        wav_file.writeframes(samples.tobytes())
    return output.getvalue()


def _app(redis: FakeRedis | None = None) -> tuple[FastAPI, FakeAsr]:
    asr = FakeAsr()
    candidate = MatchCandidate(2, 255, 255, 0.91, 0.92, 0.85)
    matcher = SimpleNamespace(
        match=lambda *_args, **_kwargs: MatchResult(
            best=candidate,
            candidates=(candidate,),
            confidence=0.91,
            margin=0.4,
            ambiguous=False,
            reason=None,
        )
    )
    metadata = QuranMetadata(
        {(2, 255): {"page": 42, "juz": 3}},
        {
            2: {
                "arabic": "البقرة",
                "latin": "Al-Baqarah",
                "translation_id": "Sapi Betina",
                "translation_en": "The Cow",
            }
        },
    )
    app = FastAPI()
    app.include_router(router)
    app.include_router(metrics_router)
    install_voice_error_handlers(app)
    app.state.asr = asr
    app.state.quran_matcher = matcher
    app.state.quran_metadata = metadata
    app.state.voice_settings = VoiceSettings()
    app.state.voice_metrics = VoiceMetrics()
    app.state.redis = redis or FakeRedis()
    return app, asr


def _multipart_request(
    app: FastAPI,
    *,
    audio_bytes: bytes,
    fields: dict[str, str] | None = None,
    device_id: str | None = None,
) -> list[dict[str, object]]:
    boundary = "hafidz-test-boundary"
    parts = [
        (
            f"--{boundary}\r\n"
            'Content-Disposition: form-data; name="audio"; filename="voice.wav"\r\n'
            "Content-Type: audio/wav\r\n\r\n"
        ).encode()
        + audio_bytes
        + b"\r\n"
    ]
    for key, value in (fields or {}).items():
        field_header = (
            f'--{boundary}\r\nContent-Disposition: form-data; name="{key}"\r\n\r\n{value}\r\n'
        )
        parts.append(field_header.encode())
    body = b"".join(parts) + f"--{boundary}--\r\n".encode()
    raw_path = b"/v1/voice/detect"
    headers = [
        (b"content-type", f"multipart/form-data; boundary={boundary}".encode()),
        (b"content-length", str(len(body)).encode()),
        (b"x-device-id", (device_id or str(uuid4())).encode()),
    ]
    messages: list[dict[str, object]] = []
    received = False

    async def receive() -> dict[str, object]:
        nonlocal received
        if received:
            return {"type": "http.disconnect"}
        received = True
        return {"type": "http.request", "body": body, "more_body": False}

    async def send(message: dict[str, object]) -> None:
        messages.append(message)

    scope: dict[str, object] = {
        "type": "http",
        "asgi": {"version": "3.0"},
        "http_version": "1.1",
        "method": "POST",
        "scheme": "http",
        "path": "/v1/voice/detect",
        "raw_path": raw_path,
        "query_string": b"",
        "headers": headers,
        "server": ("test", 80),
        "client": ("test", 1),
        "root_path": "",
        "app": app,
    }
    asyncio.run(app(scope, receive, send))  # type: ignore[arg-type]
    return messages


def _response(messages: list[dict[str, object]]) -> tuple[int, dict[str, str], dict[str, object]]:
    start = next(message for message in messages if message["type"] == "http.response.start")
    body = next(message for message in messages if message["type"] == "http.response.body")
    headers = {key.decode().lower(): value.decode() for key, value in start["headers"]}  # type: ignore[union-attr]
    return int(start["status"]), headers, json.loads(body["body"])  # type: ignore[arg-type]


def test_detect_returns_openapi_response_and_clears_audio_buffer() -> None:
    app, asr = _app()
    status, headers, body = _response(_multipart_request(app, audio_bytes=_wav()))

    assert status == 200
    assert headers["content-type"].startswith("application/json")
    assert headers["x-request-id"] == body["request_id"]
    assert body["transcript"] == "قلم دفتر شاهد"
    assert body["best"]["key"] == "2:255"
    assert body["best"]["page"] == 42
    assert body["best"]["juz"] == 3
    assert body["best"]["surah_name_translation"] == "Sapi Betina"
    assert body["best"]["match_span"] is None
    assert set(body["timing_ms"]) == {"decode", "asr", "match", "total"}
    assert asr.pcm is not None
    assert np.count_nonzero(asr.pcm) == 0
    metric_messages = _get(app, "/metrics")
    rendered_metrics = b"".join(
        message.get("body", b"")
        for message in metric_messages
        if message["type"] == "http.response.body"
    )
    assert b"asr_latency_seconds_count 1" in rendered_metrics
    assert b"match_confidence_count 1" in rendered_metrics


def test_invalid_audio_returns_problem_details_and_closes_upload(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    app, _ = _app()
    closed_uploads: list[bool] = []
    original_close = StarletteUploadFile.close

    async def track_close(upload: StarletteUploadFile) -> None:
        await original_close(upload)
        closed_uploads.append(upload.file.closed)

    monkeypatch.setattr(StarletteUploadFile, "close", track_close)
    status, headers, body = _response(_multipart_request(app, audio_bytes=b"not audio"))

    assert status == 415
    assert headers["content-type"].startswith("application/problem+json")
    assert body["code"] == "AUDIO_UNSUPPORTED"
    assert body["status"] == 415
    assert body["request_id"]
    assert closed_uploads and all(closed_uploads)


def test_rate_limit_returns_retry_after_problem() -> None:
    app, _ = _app(FakeRedis([0, 17]))
    status, headers, body = _response(_multipart_request(app, audio_bytes=_wav()))

    assert status == 429
    assert headers["retry-after"] == "17"
    assert body["code"] == "RATE_LIMITED"
    metrics = _get(app, "/metrics")
    rendered_metrics = b"".join(
        message.get("body", b"") for message in metrics if message["type"] == "http.response.body"
    )
    assert b'hafidz_voice_detect_requests_total{status="429"} 1' in rendered_metrics


def _get(app: FastAPI, path: str) -> list[dict[str, object]]:
    messages: list[dict[str, object]] = []
    received = False

    async def receive() -> dict[str, object]:
        nonlocal received
        if received:
            return {"type": "http.disconnect"}
        received = True
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
        "app": app,
    }
    asyncio.run(app(scope, receive, send))  # type: ignore[arg-type]
    return messages


def test_contract_matches_openapi_document() -> None:
    app, _ = _app()
    actual = app.openapi()
    contract_path = Path(__file__).resolve().parents[3] / "docs" / "api" / "openapi.yaml"
    expected = yaml.safe_load(contract_path.read_text(encoding="utf-8"))
    expected_operation = expected["paths"]["/v1/voice/detect"]["post"]
    actual_operation = actual["paths"]["/v1/voice/detect"]["post"]

    assert (
        actual_operation["requestBody"]["content"].keys()
        == expected_operation["requestBody"]["content"].keys()
    )
    expected_response = expected["components"]["schemas"]["VoiceDetectResponse"]
    actual_response = actual["components"]["schemas"]["VoiceDetectResponse"]
    assert set(expected_response["properties"]).issubset(actual_response["properties"])
    assert set(expected_response["required"]).issubset(actual_response["required"])


_contract_path = Path(__file__).resolve().parents[3] / "docs" / "api" / "openapi.yaml"
_voice_contract = schemathesis.openapi.from_path(str(_contract_path)).include(
    path="/v1/voice/detect", method="POST"
)


@hypothesis_settings(max_examples=5, deadline=None)
@_voice_contract.parametrize()
def test_schemathesis_voice_contract(case: schemathesis.Case) -> None:
    app, _ = _app()
    with ASGIClient(app) as client:
        response = case.call(base_url="http://testserver", session=client)
        case.operation.validate_response(response, case=case)
