# Hafidz App

Hafidz App is an Indonesia-first, offline-first Muslim daily companion. Its AI feature, Voice Ayah Finder, turns a short
Qur'an recitation into a transcript, matches it against a Qur'an search index, and navigates to the likely ayah.

## Project map

- `apps/mobile/` — Flutter mobile app
- `services/api/` — FastAPI backend-for-frontend and future ASR/matcher services
- `tools/build_quran_db/` — reproducible offline Qur'an database builder
- `tools/convert_model/` — Tarteel Whisper checkpoint conversion
- `infra/` — local and deployment infrastructure
- `docs/` — product, architecture, API, data, privacy, and roadmap specifications

Read `AGENTS.md` before making project changes. Follow the supplied specifications and roadmap task IDs.

## Current implementation scope

The FastAPI service now includes the Whisper ASR service, Arabic transcript matcher, and `POST /v1/voice/detect` with
Redis rate limiting, Quran location metadata, RFC 7807 errors, and internal voice metrics. The mobile application and
other daily-needs APIs remain later roadmap work.

## Local development

The backend requires Python 3.12 or newer and is pinned to Python 3.14 for local development and Docker. Install `uv` in your CLI, then from `services/api` run `uv python pin 3.14` and `uv sync --extra dev` to create the virtual environment and install the locked dependencies. Before using Docker Compose, generate the Quran database and matching index from the repository root:

```bash
uv run --project services/api python tools/build_quran_db/build.py
uv run --project services/api python tools/build_quran_db/build_index.py
```

Compose mounts the generated Quran database and its verified search index read-only. Start the API and Redis from the repository root with `docker compose -f infra/docker-compose.yml up --build`.

The API serves `GET /healthz`, `GET /metrics` on the internal network, `POST /v1/voice/detect`, and the interactive OpenAPI page at `/docs` while running locally.
