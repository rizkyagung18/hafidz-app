"""Bounded live Voice Finder WebSocket for continuous, ephemeral recitation."""

from __future__ import annotations

import asyncio
import json
import time
from collections import deque
from collections.abc import MutableMapping
from dataclasses import dataclass
from typing import Any
from uuid import UUID, uuid4

import numpy as np
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from redis.exceptions import RedisError

from app.asr.model import QuranAsr
from app.matching.matcher import MatchResult, QuranMatcher
from app.matching.normalize import normalize_ar
from app.routers.voice import _RATE_LIMIT_SCRIPT
from app.settings import VoiceSettings

router = APIRouter(prefix="/v1/voice", tags=["voice"])

SAMPLE_RATE = 16_000
BYTES_PER_SECOND = SAMPLE_RATE * 2
MAX_FRAME_BYTES = BYTES_PER_SECOND
ROLLING_BYTES = BYTES_PER_SECOND * 4
MIN_WINDOW_BYTES = BYTES_PER_SECOND * 3 // 2
WINDOW_STEP_BYTES = BYTES_PER_SECOND
MAX_SESSION_SECONDS = 180
INFERENCE_SLOT_WAIT_SECONDS = 2
_RELEASE_SESSION_SCRIPT = """
if redis.call('GET', KEYS[1]) == ARGV[1] then
  return redis.call('DEL', KEYS[1])
end
return 0
"""


@dataclass(frozen=True, slots=True)
class LiveDecision:
    kind: str
    surah: int | None = None
    ayah_start: int | None = None
    ayah_end: int | None = None
    confidence: float = 0.0
    reason: str | None = None
    revision: int = 0


class LiveInferenceBusy(Exception):
    """The local ASR worker capacity is exhausted."""


class LiveStabilizer:
    """Require repeated, plausible detections before changing the followed ayah."""

    def __init__(self) -> None:
        self._pending: tuple[int, int, int] | None = None
        self._streak = 0
        self._stable: tuple[int, int, int] | None = None
        self._revision = 0

    @property
    def stable_surah(self) -> int | None:
        return self._stable[0] if self._stable else None

    def update(self, result: MatchResult) -> LiveDecision:
        best = result.best
        if best is None or result.ambiguous or result.confidence < result.thresholds.min:
            self._pending = None
            self._streak = 0
            return LiveDecision(
                kind="ambiguous", confidence=result.confidence, reason=result.reason
            )
        target = (best.surah, best.ayah_start, best.ayah_end)
        if self._stable == target:
            return LiveDecision(
                kind="candidate",
                surah=best.surah,
                ayah_start=best.ayah_start,
                ayah_end=best.ayah_end,
                confidence=result.confidence,
                revision=self._revision,
            )
        if target == self._pending:
            self._streak += 1
        else:
            self._pending = target
            self._streak = 1
        adjacent = (
            self._stable is not None
            and best.surah == self._stable[0]
            and 0 <= best.ayah_end - self._stable[2] <= 3
        )
        required = 2 if self._stable is None or adjacent else 3
        if self._streak < required:
            return LiveDecision(
                kind="candidate",
                surah=best.surah,
                ayah_start=best.ayah_start,
                ayah_end=best.ayah_end,
                confidence=result.confidence,
                revision=self._revision,
            )
        self._stable = target
        self._revision += 1
        return LiveDecision(
            kind="ayah",
            surah=best.surah,
            ayah_start=best.ayah_start,
            ayah_end=best.ayah_end,
            confidence=result.confidence,
            revision=self._revision,
        )


async def _infer(
    pcm_bytes: bytes,
    asr: QuranAsr,
    matcher: QuranMatcher,
    hint_surah: int | None,
    slots: asyncio.Semaphore,
) -> MatchResult:
    try:
        await asyncio.wait_for(slots.acquire(), timeout=INFERENCE_SLOT_WAIT_SECONDS)
    except TimeoutError as exc:
        raise LiveInferenceBusy from exc
    try:
        pcm = np.frombuffer(pcm_bytes, dtype="<i2").astype(np.float32) / 32768.0
        try:
            transcript = await asr.transcribe_async(pcm)
            return matcher.match(
                normalize_ar(transcript.text),
                hint_surah=hint_surah,
                asr_quality=QuranAsr.quality(transcript),
                max_candidates=3,
            )
        finally:
            pcm.fill(0)
    finally:
        slots.release()


async def _rate_connection(websocket: WebSocket, device: UUID) -> bool:
    settings: VoiceSettings = websocket.app.state.voice_settings
    redis = websocket.app.state.redis
    try:
        allowed, _ = await redis.eval(
            _RATE_LIMIT_SCRIPT,
            2,
            f"rate:voice:live:{device}:minute",
            f"rate:voice:live:{device}:day",
            settings.rate_limit_per_minute,
            settings.rate_limit_per_day,
        )
    except RedisError:
        return False
    return int(allowed) == 1


@router.websocket("/live")
async def live_voice_ayah(websocket: WebSocket) -> None:
    """Receive ordered PCM16 chunks and emit stable canonical ayah events."""
    try:
        device = UUID(websocket.headers.get("x-device-id", ""))
    except ValueError:
        await websocket.close(code=4400, reason="X-Device-Id is required")
        return
    if not await _rate_connection(websocket, device):
        await websocket.close(code=4429, reason="Voice connection limit reached")
        return
    try:
        hint = int(websocket.query_params.get("hint_surah", "0"))
    except ValueError:
        await websocket.close(code=4400, reason="Invalid hint_surah")
        return
    if hint not in range(0, 115):
        await websocket.close(code=4400, reason="Invalid hint_surah")
        return

    redis = websocket.app.state.redis
    session_key = f"voice:live:active:{device}"
    session_token = str(uuid4())
    try:
        acquired = await redis.set(
            session_key,
            session_token,
            ex=MAX_SESSION_SECONDS + 5,
            nx=True,
        )
    except RedisError:
        acquired = False
    if not acquired:
        await websocket.close(code=4429, reason="Voice connection limit reached")
        return

    sequence = 0
    accepted = False
    rolling: deque[bytes] = deque()
    rolling_size = 0
    bytes_since_inference = 0
    total_bytes = 0
    started = time.monotonic()
    stabilizer = LiveStabilizer()
    current: asyncio.Task[MatchResult] | None = None
    receiver: asyncio.Task[MutableMapping[str, Any]] | None = None
    asr: QuranAsr = websocket.app.state.asr
    matcher: QuranMatcher = websocket.app.state.quran_matcher
    metadata = websocket.app.state.quran_metadata
    slots: asyncio.Semaphore = websocket.app.state.live_inference_slots

    async def send_result(result: MatchResult) -> None:
        nonlocal sequence
        decision = stabilizer.update(result)
        sequence += 1
        payload: dict[str, object] = {
            "type": decision.kind,
            "sequence": sequence,
            "confidence": decision.confidence,
            "revision": decision.revision,
        }
        if decision.surah is not None and decision.ayah_end is not None:
            payload.update(
                {
                    "surah": decision.surah,
                    "ayah_start": decision.ayah_start,
                    "ayah_end": decision.ayah_end,
                    "page": metadata.ayah(decision.surah, decision.ayah_end)["page"],
                }
            )
        if decision.reason is not None:
            payload["reason"] = decision.reason
        await websocket.send_json(payload)

    try:
        await websocket.accept()
        accepted = True
        await websocket.send_json(
            {
                "type": "ready",
                "sequence": sequence,
                "sample_rate": SAMPLE_RATE,
                "format": "pcm_s16le_mono",
            }
        )
        receiver = asyncio.create_task(websocket.receive())
        while True:
            remaining = MAX_SESSION_SECONDS - (time.monotonic() - started)
            if remaining <= 0:
                sequence += 1
                await websocket.send_json(
                    {"type": "error", "sequence": sequence, "code": "SESSION_EXPIRED"}
                )
                break
            pending: set[asyncio.Task[Any]] = {receiver}
            if current is not None:
                pending.add(current)
            done, _ = await asyncio.wait(
                pending,
                timeout=remaining,
                return_when=asyncio.FIRST_COMPLETED,
            )
            if not done:
                sequence += 1
                await websocket.send_json(
                    {"type": "error", "sequence": sequence, "code": "SESSION_EXPIRED"}
                )
                break
            if current is not None and current in done:
                try:
                    await send_result(current.result())
                except LiveInferenceBusy:
                    sequence += 1
                    await websocket.send_json(
                        {"type": "error", "sequence": sequence, "code": "BACKPRESSURE"}
                    )
                    break
                except Exception:
                    sequence += 1
                    await websocket.send_json(
                        {"type": "error", "sequence": sequence, "code": "INFERENCE_FAILED"}
                    )
                    break
                current = None
            if receiver not in done:
                continue
            try:
                message = receiver.result()
            except WebSocketDisconnect:
                break
            if message["type"] == "websocket.disconnect":
                break
            receiver = asyncio.create_task(websocket.receive())
            if message.get("text") is not None:
                try:
                    command = json.loads(message["text"])
                except json.JSONDecodeError:
                    command = {}
                if not isinstance(command, dict):
                    command = {}
                if command.get("type") == "stop":
                    if current is not None:
                        try:
                            await send_result(await current)
                        except LiveInferenceBusy:
                            sequence += 1
                            await websocket.send_json(
                                {"type": "error", "sequence": sequence, "code": "BACKPRESSURE"}
                            )
                            break
                        except Exception:
                            sequence += 1
                            await websocket.send_json(
                                {"type": "error", "sequence": sequence, "code": "INFERENCE_FAILED"}
                            )
                            break
                        current = None
                    sequence += 1
                    await websocket.send_json({"type": "stopped", "sequence": sequence})
                    break
                sequence += 1
                await websocket.send_json(
                    {"type": "error", "sequence": sequence, "code": "INVALID_COMMAND"}
                )
                break
            chunk = message.get("bytes") or b""
            if not chunk or len(chunk) > MAX_FRAME_BYTES or len(chunk) % 2:
                sequence += 1
                await websocket.send_json(
                    {"type": "error", "sequence": sequence, "code": "INVALID_PCM_FRAME"}
                )
                break
            total_bytes += len(chunk)
            if total_bytes > MAX_SESSION_SECONDS * BYTES_PER_SECOND:
                sequence += 1
                await websocket.send_json(
                    {"type": "error", "sequence": sequence, "code": "SESSION_EXPIRED"}
                )
                break
            rolling.append(chunk)
            rolling_size += len(chunk)
            bytes_since_inference += len(chunk)
            while rolling_size > ROLLING_BYTES:
                old = rolling.popleft()
                rolling_size -= len(old)
            if rolling_size >= MIN_WINDOW_BYTES and bytes_since_inference >= WINDOW_STEP_BYTES:
                if current is None:
                    snapshot = b"".join(rolling)
                    current = asyncio.create_task(
                        _infer(
                            snapshot,
                            asr,
                            matcher,
                            stabilizer.stable_surah or hint or None,
                            slots,
                        )
                    )
                    bytes_since_inference = 0
                elif bytes_since_inference > ROLLING_BYTES:
                    sequence += 1
                    await websocket.send_json(
                        {"type": "error", "sequence": sequence, "code": "BACKPRESSURE"}
                    )
                    break
    except WebSocketDisconnect, RuntimeError:
        pass
    finally:
        if receiver is not None and not receiver.done():
            receiver.cancel()
            try:
                await receiver
            except asyncio.CancelledError:
                pass
        if current is not None and not current.done():
            current.cancel()
            try:
                await current
            except asyncio.CancelledError:
                pass
        rolling.clear()
        if accepted:
            try:
                await websocket.close()
            except Exception:
                pass
        try:
            await redis.eval(_RELEASE_SESSION_SCRIPT, 1, session_key, session_token)
        except RedisError:
            pass
