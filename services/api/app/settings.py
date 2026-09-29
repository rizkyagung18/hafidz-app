"""Runtime settings for the ASR service."""

from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from app.asr.model import DEFAULT_MODEL_PATH


class AsrSettings(BaseSettings):
    """Environment-backed configuration for the loaded speech model."""

    model_config = SettingsConfigDict(extra="ignore")

    model_dir: Path = Field(default=DEFAULT_MODEL_PATH, validation_alias="ASR_MODEL_DIR")
    cpu_threads: int = Field(default=2, ge=1, validation_alias="ASR_CPU_THREADS")
    num_workers: int = Field(default=2, ge=1, validation_alias="ASR_NUM_WORKERS")
    beam_size: int = Field(default=5, ge=1, validation_alias="ASR_BEAM_SIZE")


class VoiceSettings(BaseSettings):
    """Configuration for voice detection, Quran data, and Redis rate limits."""

    model_config = SettingsConfigDict(extra="ignore")

    root_dir: Path = Path(__file__).resolve().parents[3]
    redis_url: str = Field(default="redis://localhost:6379/0", validation_alias="REDIS_URL")
    index_path: Path = Field(
        default=Path(__file__).resolve().parents[1] / "data" / "quran_index.pkl",
        validation_alias="QURAN_INDEX_PATH",
    )
    database_path: Path = Field(
        default=Path(__file__).resolve().parents[3]
        / "apps"
        / "mobile"
        / "assets"
        / "db"
        / "quran.sqlite",
        validation_alias="QURAN_DB_PATH",
    )
    max_bytes: int = Field(default=2_097_152, ge=1, validation_alias="VOICE_MAX_BYTES")
    max_seconds: float = Field(default=30.5, gt=1, validation_alias="VOICE_MAX_SECONDS")
    rate_limit_per_minute: int = Field(
        default=10, ge=1, validation_alias="RATE_LIMIT_VOICE_PER_MIN"
    )
    rate_limit_per_day: int = Field(default=200, ge=1, validation_alias="RATE_LIMIT_VOICE_PER_DAY")
    match_auto_threshold: float = Field(
        default=0.80, ge=0, le=1, validation_alias="MATCH_AUTO_THRESHOLD"
    )
    match_min_threshold: float = Field(
        default=0.55, ge=0, le=1, validation_alias="MATCH_MIN_THRESHOLD"
    )
    match_min_margin: float = Field(default=0.10, ge=0, le=1, validation_alias="MATCH_MIN_MARGIN")
