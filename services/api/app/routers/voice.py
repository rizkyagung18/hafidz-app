"""Voice Ayah Finder detection endpoint."""

from __future__ import annotations

import logging
import time
import uuid
from collections import Counter
from collections.abc import Awaitable, Callable
from threading import Lock
from typing import Annotated, Literal
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, Header, Request, UploadFile
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, PlainTextResponse, Response
from pydantic import BaseModel, Field
from redis.exceptions import RedisError

from app.asr.audio import AudioProblem, decode_to_pcm16k
from app.asr.model import AsrResult, QuranAsr
from app.matching.matcher import MatchCandidate, MatchResult, QuranMatcher
from app.matching.metadata import QuranMetadata
from app.matching.normalize import normalize_ar
from app.settings import VoiceSettings

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/v1/voice", tags=["voice"])
metrics_router = APIRouter(tags=["ops"])


class ProblemResponse(BaseModel):
    type: str = "about:blank"
    title: str
    status: int
    detail: str | None = None
    code: str
    request_id: str | None = None


class MatchSpanResponse(BaseModel):
    ayah: int
    word_start: int
    word_end: int


class AyahMatchResponse(BaseModel):
    key: str
    surah: int
    ayah_start: int
    ayah_end: int
    page: int
    juz: int
    surah_name_arabic: str
    surah_name_latin: str
    surah_name_translation: str | None
    score: float = Field(ge=0, le=1)
    match_span: MatchSpanResponse | None = None


class ThresholdResponse(BaseModel):
    auto: float
    min: float
    margin: float


class TimingResponse(BaseModel):
    decode: int
    asr: int
    match: int
    total: int


class VoiceDetectResponse(BaseModel):
    request_id: str
    transcript: str
    confidence: float = Field(ge=0, le=1)
    margin: float
    ambiguous: bool
    reason: Literal["too_short", "basmala_only", "identical_ayat", "low_confidence"] | None
    best: AyahMatchResponse | None
    candidates: list[AyahMatchResponse] = Field(max_length=5)
    thresholds: ThresholdResponse
    timing_ms: TimingResponse


class VoiceApiProblem(Exception):
    def __init__(
        self,
        status: int,
        code: str,
        title: str,
        detail: str,
        retry_after: int | None = None,
    ) -> None:
        self.status = status
        self.code = code
        self.title = title
        self.detail = detail
        self.retry_after = retry_after


class VoiceMetrics:
    """Small per-process request and latency counters for the internal metrics endpoint."""

    def __init__(self) -> None:
        self._lock = Lock()
        self._requests: Counter[str] = Counter()
        self._provider_errors: Counter[str] = Counter()
        self._duration_seconds: dict[str, float] = {}
        self._asr_latency_seconds = 0.0
        self._asr_count = 0
        self._match_confidence_sum = 0.0
        self._match_count = 0

    def observe(self, status: str, duration_seconds: float) -> None:
        with self._lock:
            self._requests[status] = self._requests.get(status, 0) + 1
            self._duration_seconds[status] = (
                self._duration_seconds.get(status, 0.0) + duration_seconds
            )

    def observe_asr(self, duration_seconds: float) -> None:
        with self._lock:
            self._asr_latency_seconds += duration_seconds
            self._asr_count += 1

    def observe_match(self, confidence: float) -> None:
        with self._lock:
            self._match_confidence_sum += confidence
            self._match_count += 1

    def observe_provider_error(self, provider: str) -> None:
        with self._lock:
            self._provider_errors[provider] += 1

    def render(self) -> str:
        with self._lock:
            requests = dict(self._requests)
            provider_errors = dict(self._provider_errors)
            durations = {status: total for status, total in self._duration_seconds.items()}
            asr_latency_seconds = self._asr_latency_seconds
            asr_count = self._asr_count
            match_confidence_sum = self._match_confidence_sum
            match_count = self._match_count
        lines = [
            "# HELP hafidz_voice_detect_requests_total Voice detection requests by HTTP status.",
            "# TYPE hafidz_voice_detect_requests_total counter",
        ]
        for status, count in sorted(requests.items()):
            lines.append(f'hafidz_voice_detect_requests_total{{status="{status}"}} {count}')
        lines.extend(
            [
                "# HELP hafidz_voice_detect_duration_seconds_sum Total voice detection duration.",
                "# TYPE hafidz_voice_detect_duration_seconds_sum counter",
            ]
        )
        for status, total in sorted(durations.items()):
            lines.append(
                f'hafidz_voice_detect_duration_seconds_sum{{status="{status}"}} {total:.6f}'
            )
        lines.extend(
            [
                "# TYPE asr_latency_seconds summary",
                f"asr_latency_seconds_count {asr_count}",
                f"asr_latency_seconds_sum {asr_latency_seconds:.6f}",
                "# TYPE match_confidence summary",
                f"match_confidence_count {match_count}",
                f"match_confidence_sum {match_confidence_sum:.6f}",
                "# TYPE provider_errors_total counter",
            ]
        )
        for provider, count in sorted(provider_errors.items()):
            lines.append(f'provider_errors_total{{provider="{provider}"}} {count}')
        return "\n".join(lines) + "\n"


_RATE_LIMIT_SCRIPT = """
local minute = redis.call('INCR', KEYS[1])
if minute == 1 then redis.call('EXPIRE', KEYS[1], 60) end
local day = redis.call('INCR', KEYS[2])
if day == 1 then redis.call('EXPIRE', KEYS[2], 86400) end
if minute > tonumber(ARGV[1]) then return {0, redis.call('TTL', KEYS[1])} end
if day > tonumber(ARGV[2]) then return {0, redis.call('TTL', KEYS[2])} end
return {1, 0}
"""


async def voice_rate_limit(
    request: Request,
    device_id: Annotated[UUID, Header(alias="X-Device-Id")],
) -> str:
    """Enforce the documented per-device minute and daily limits atomically in Redis."""
    settings: VoiceSettings = request.app.state.voice_settings
    redis = request.app.state.redis
    minute_key = f"rate:voice:{device_id}:minute"
    day_key = f"rate:voice:{device_id}:day"
    try:
        allowed, retry_after = await redis.eval(
            _RATE_LIMIT_SCRIPT,
            2,
            minute_key,
            day_key,
            settings.rate_limit_per_minute,
            settings.rate_limit_per_day,
        )
    except RedisError as exc:
        metrics: VoiceMetrics | None = getattr(request.app.state, "voice_metrics", None)
        if metrics is not None:
            metrics.observe_provider_error("redis")
        raise VoiceApiProblem(
            503,
            "UPSTREAM_UNAVAILABLE",
            "Voice detection unavailable",
            "Rate limiting is temporarily unavailable.",
        ) from exc
    if int(allowed) != 1:
        wait_seconds = max(1, int(retry_after))
        raise VoiceApiProblem(
            429,
            "RATE_LIMITED",
            "Too many voice requests",
            "Voice detection limit reached for this device.",
            retry_after=wait_seconds,
        )
    return str(device_id)


def _problem_json(
    request: Request,
    *,
    status: int,
    code: str,
    title: str,
    detail: str,
    retry_after: int | None = None,
) -> JSONResponse:
    request_id = str(getattr(request.state, "request_id", uuid.uuid4()))
    headers = {"X-Request-Id": request_id}
    if retry_after is not None:
        headers["Retry-After"] = str(retry_after)
    body = ProblemResponse(
        title=title, status=status, detail=detail, code=code, request_id=request_id
    )
    return JSONResponse(
        status_code=status,
        content=body.model_dump(mode="json"),
        media_type="application/problem+json",
        headers=headers,
    )


def install_voice_error_handlers(app: object) -> None:
    """Register RFC 7807 handlers for audio, limiter, and form validation errors."""
    from fastapi import FastAPI

    if not isinstance(app, FastAPI):
        raise TypeError("Voice error handlers require a FastAPI application.")

    @app.middleware("http")
    async def voice_metrics_middleware(
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        if request.url.path != "/v1/voice/detect":
            return await call_next(request)
        started = time.perf_counter()
        response = await call_next(request)
        metrics: VoiceMetrics | None = getattr(request.app.state, "voice_metrics", None)
        if metrics is not None:
            metrics.observe(str(response.status_code), time.perf_counter() - started)
        return response

    @app.exception_handler(AudioProblem)
    async def audio_problem_handler(request: Request, exc: AudioProblem) -> JSONResponse:
        return _problem_json(
            request, status=exc.status, code=exc.code, title=exc.title, detail=exc.detail
        )

    @app.exception_handler(VoiceApiProblem)
    async def voice_problem_handler(request: Request, exc: VoiceApiProblem) -> JSONResponse:
        return _problem_json(
            request,
            status=exc.status,
            code=exc.code,
            title=exc.title,
            detail=exc.detail,
            retry_after=exc.retry_after,
        )

    @app.exception_handler(RequestValidationError)
    async def voice_validation_handler(
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        detail = "; ".join(str(error.get("msg", "Invalid request")) for error in exc.errors())
        return _problem_json(
            request,
            status=400,
            code="VALIDATION_ERROR",
            title="Invalid request",
            detail=detail,
        )


def _ayah_response(
    candidate: MatchCandidate, metadata: QuranMetadata, locale: str
) -> AyahMatchResponse:
    surah_metadata = metadata.surah(candidate.surah)
    start_metadata = metadata.ayah(candidate.surah, candidate.ayah_start)
    return AyahMatchResponse(
        key=candidate.key,
        surah=candidate.surah,
        ayah_start=candidate.ayah_start,
        ayah_end=candidate.ayah_end,
        page=start_metadata["page"],
        juz=start_metadata["juz"],
        surah_name_arabic=surah_metadata["arabic"],
        surah_name_latin=surah_metadata["latin"],
        surah_name_translation=(
            surah_metadata["translation_en"] if locale == "en" else surah_metadata["translation_id"]
        ),
        score=candidate.score,
    )


def _build_response(
    *,
    request_id: str,
    transcript: str,
    result: MatchResult,
    metadata: QuranMetadata,
    locale: str,
    timings: TimingResponse,
) -> VoiceDetectResponse:
    def convert(item: MatchCandidate) -> AyahMatchResponse:
        return _ayah_response(item, metadata, locale)

    return VoiceDetectResponse(
        request_id=request_id,
        transcript=transcript,
        confidence=result.confidence,
        margin=result.margin,
        ambiguous=result.ambiguous,
        reason=result.reason,
        best=convert(result.best) if result.best is not None else None,
        candidates=[convert(candidate) for candidate in result.candidates],
        thresholds=ThresholdResponse(
            auto=result.thresholds.auto,
            min=result.thresholds.min,
            margin=result.thresholds.margin,
        ),
        timing_ms=timings,
    )


@router.post("/detect", response_model=VoiceDetectResponse)
async def detect_voice_ayah(
    request: Request,
    response: Response,
    audio: Annotated[UploadFile, File(...)],
    hint_surah: Annotated[int | None, Form(ge=1, le=114)] = None,
    locale: Annotated[Literal["id", "en"], Form()] = "id",
    max_candidates: Annotated[int, Form(ge=1, le=5)] = 5,
    device_id: str = Depends(voice_rate_limit),
) -> VoiceDetectResponse:
    """Decode, transcribe, and match an ephemeral upload without persisting audio."""
    del device_id
    started = time.perf_counter()
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    response.headers["X-Request-Id"] = request_id
    settings: VoiceSettings = request.app.state.voice_settings
    try:
        raw = await audio.read(settings.max_bytes + 1)
        await audio.close()
        if len(raw) > settings.max_bytes:
            raise AudioProblem(
                413,
                "AUDIO_TOO_LONG",
                "Audio too large",
                f"Audio exceeds the {settings.max_bytes}-byte limit.",
            )

        decode_started = time.perf_counter()
        pcm = decode_to_pcm16k(
            raw,
            max_bytes=settings.max_bytes,
            max_duration_seconds=settings.max_seconds,
        )
        decode_ms = round((time.perf_counter() - decode_started) * 1000)
        del raw

        asr_started = time.perf_counter()
        asr: QuranAsr = request.app.state.asr
        metrics: VoiceMetrics = request.app.state.voice_metrics
        try:
            asr_result: AsrResult = await asr.transcribe_async(pcm)
            metrics.observe_asr(time.perf_counter() - asr_started)
        except Exception:
            metrics.observe_provider_error("asr")
            raise
        finally:
            pcm.fill(0)
            del pcm
        asr_ms = round((time.perf_counter() - asr_started) * 1000)

        match_started = time.perf_counter()
        transcript = normalize_ar(asr_result.text)
        quality = QuranAsr.quality(asr_result)
        matcher: QuranMatcher = request.app.state.quran_matcher
        result = matcher.match(
            transcript,
            hint_surah=hint_surah,
            asr_quality=quality,
            max_candidates=max_candidates,
        )
        metrics.observe_match(result.confidence)
        match_ms = round((time.perf_counter() - match_started) * 1000)
        total_ms = round((time.perf_counter() - started) * 1000)
        output = _build_response(
            request_id=request_id,
            transcript=transcript,
            result=result,
            metadata=request.app.state.quran_metadata,
            locale=locale,
            timings=TimingResponse(decode=decode_ms, asr=asr_ms, match=match_ms, total=total_ms),
        )
        logger.info(
            "voice_detect_complete",
            extra={"request_id": request_id, "duration_ms": total_ms, "reason": result.reason},
        )
        return output
    except AudioProblem:
        raise
    except (ValueError, KeyError, IndexError) as exc:
        logger.exception("voice_detect_configuration_error", extra={"request_id": request_id})
        raise VoiceApiProblem(
            503,
            "UPSTREAM_UNAVAILABLE",
            "Voice detection unavailable",
            "Quran matching data is temporarily unavailable.",
        ) from exc
    except Exception as exc:
        logger.exception("voice_detect_inference_error", extra={"request_id": request_id})
        raise VoiceApiProblem(
            503,
            "UPSTREAM_UNAVAILABLE",
            "Voice detection unavailable",
            "Transcription is temporarily unavailable.",
        ) from exc


@metrics_router.get("/metrics", include_in_schema=False)
async def voice_metrics(request: Request) -> PlainTextResponse:
    """Expose process-local voice endpoint counters for internal scraping."""
    return PlainTextResponse(
        request.app.state.voice_metrics.render(), media_type="text/plain; version=0.0.4"
    )
