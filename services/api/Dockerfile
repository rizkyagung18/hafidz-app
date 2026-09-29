FROM ghcr.io/astral-sh/uv:0.12.19 AS uv

FROM python:3.14-slim AS model-conversion
COPY --from=uv /uv /bin/uv
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_COMPILE_BYTECODE=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY services/api/pyproject.toml services/api/uv.lock ./
COPY services/api/app ./app
RUN uv sync --locked --no-dev --no-editable --extra model-conversion
COPY tools/convert_model ./tools/convert_model
RUN uv run --no-sync python tools/convert_model/convert.py

FROM python:3.14-slim AS runtime-dependencies
COPY --from=uv /uv /bin/uv
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_COMPILE_BYTECODE=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY services/api/pyproject.toml services/api/uv.lock ./
COPY services/api/app ./app
RUN uv sync --locked --no-dev --no-editable

FROM python:3.14-slim AS runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:${PATH}" \
    ASR_MODEL_DIR=/models/whisper-base-ar-quran-ct2-int8
WORKDIR /app
COPY services/api/app ./app
COPY --from=runtime-dependencies /opt/venv /opt/venv
COPY --from=model-conversion /app/models/whisper-base-ar-quran-ct2-int8 /models/whisper-base-ar-quran-ct2-int8
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
