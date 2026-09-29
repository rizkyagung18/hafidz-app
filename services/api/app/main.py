"""FastAPI application entry point."""

import hashlib
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import anyio
from fastapi import FastAPI
from redis.asyncio import Redis

from app.asr.model import QuranAsr
from app.matching.index import load_index
from app.matching.matcher import MatchThresholds, QuranMatcher
from app.matching.metadata import QuranMetadata
from app.routers.health import router as health_router
from app.routers.voice import (
    VoiceMetrics,
    install_voice_error_handlers,
    metrics_router,
)
from app.routers.voice import (
    router as voice_router,
)
from app.settings import AsrSettings, VoiceSettings


def _load_asr(settings: AsrSettings) -> QuranAsr:
    """Construct the model in a worker thread during application startup."""
    return QuranAsr(
        settings.model_dir,
        cpu_threads=settings.cpu_threads,
        num_workers=settings.num_workers,
        beam_size=settings.beam_size,
    )


def _load_voice_data(settings: VoiceSettings) -> tuple[dict[str, object], QuranMetadata]:
    """Verify the search index and load read-only display metadata before serving requests."""
    index = load_index(settings.index_path)
    database_hash = hashlib.sha256(settings.database_path.read_bytes()).hexdigest()
    if index.get("database_sha256") != database_hash:
        raise ValueError("Quran search index was built from a different Quran database.")
    return index, QuranMetadata.load(settings.database_path)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Load and warm the model exactly once for this API process."""
    asr_settings = AsrSettings()
    voice_settings = VoiceSettings()
    search_index, metadata = await anyio.to_thread.run_sync(_load_voice_data, voice_settings)
    matcher = QuranMatcher(
        search_index,
        MatchThresholds(
            auto=voice_settings.match_auto_threshold,
            min=voice_settings.match_min_threshold,
            margin=voice_settings.match_min_margin,
        ),
    )
    asr = await anyio.to_thread.run_sync(_load_asr, asr_settings)
    await anyio.to_thread.run_sync(asr.warmup)
    redis = Redis.from_url(voice_settings.redis_url, decode_responses=True)
    app.state.asr = asr
    app.state.voice_settings = voice_settings
    app.state.search_index = search_index
    app.state.quran_matcher = matcher
    app.state.quran_metadata = metadata
    app.state.redis = redis
    app.state.voice_metrics = VoiceMetrics()
    try:
        yield
    finally:
        await redis.aclose()
        app.state.asr = None
        app.state.search_index = None
        app.state.quran_matcher = None
        app.state.quran_metadata = None
        app.state.redis = None


app = FastAPI(
    title="Hafidz App API",
    description="Backend-for-Frontend for the Hafidz App Muslim daily companion.",
    version="0.1.0",
    lifespan=lifespan,
)
app.include_router(health_router)
app.include_router(voice_router)
app.include_router(metrics_router)
install_voice_error_handlers(app)
