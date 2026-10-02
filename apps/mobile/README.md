# Hafidz App (Flutter)

Muslim daily companion — Qur'an reader, prayer times, Voice Ayah Finder.

## Setup

Build the ignored Qur'an asset from the repository root first:

```bash
uv run --project services/api python tools/build_quran_db/stage_mushaf_local.py
uv run --project services/api python tools/build_quran_db/build.py
uv run --project services/api python tools/build_quran_db/verify.py
uv run --project services/api python tools/build_quran_db/build_index.py
```

Then, from `apps/mobile`:

```bash
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Checks

```bash
flutter analyze
flutter test
```

## App shell (T-M01)

- Theme tokens (light / dark / sepia) — Settings
- go_router routes + bottom navigation (docs/07)
- i18n ARB (`id` default, `en`)
- Riverpod + dio client with `X-Device-Id`
- `AppError` mapping from RFC 7807 problem+json

## Local database (T-M02)

The bundled v3 `quran.sqlite` and matching 1405H print fonts/headers are verified
and installed into the app support directory on launch. Drift opens the content
as read only. The previous verified v3 package stays available if an update
fails. `user.sqlite` independently retains bookmarks, notes and reading state.

## Qur'an list reader (T-M03)

The Qur'an tab lists 114 surahs from the bundled database. The list reader opens
`/quran/surah/{number}` and supports `?ayah={number}` for a direct jump. It shows
verbatim QUL Uthmani text in the QUL Me Quran font and the supplied Indonesian
ayah translation, with bookmarks, copy and share. Latin transliteration, tafsir
and Surah meanings are hidden until sourced; audio playback is T-D05.

## Mushaf page reader (T-M04 in progress)

The local reader loads 604 fixed QPC V1 pages from database v3 and the matching
page fonts. It preserves QUL source line and word order, shows the colored Surah
header, keeps the printed page full width, and supports zoom without reflow.
Tapping a word or numbered ayah marker highlights the whole ayah and opens
Translation and Bookmark actions; the translation panel also offers canonical
copy and share. Top Surah/Juz lists and the bottom page control jump within the
edition. `hafidz://quran/ayah/2:255` resolves to page 42. The mic stays outside
the printed page. Live Voice Finder captures ephemeral 16 kHz mono PCM,
sends half-second frames, and follows only stable ayah events. Pause follow
keeps listening; resume jumps to the latest stable ayah. A lost connection
stops the mic and offers Retry. Physical iPhone recitation proof remains open.

The user approved the denser page-4 Arabic layout. Final Android/iOS visual
comparison at that size, all-page device traversal, memory/frame profiling and
resource-specific redistribution rights remain open. See [docs/08](../../docs/08-ROADMAP-TASKS.md).

To run on an iOS Simulator, boot it in Xcode or Simulator, then run
`flutter run -d <simulator-id>` from `apps/mobile`.

## Local live Voice Finder on an iPhone

Start Redis with `docker compose -f infra/docker-compose.yml up -d redis` from
the repository root. Start the local API from `services/api` with
`uv run uvicorn app.main:app --host 0.0.0.0 --port 8000`; `GET /healthz` must
return 200, and `docker compose -f infra/docker-compose.yml exec redis redis-cli ping`
must return `PONG`. The converted model and matching QUL database/index must
already be installed locally. Keep the iPhone and Mac on the same trusted Wi-Fi.

Connect and trust the unlocked iPhone, enable Developer Mode, and select it in
`flutter devices`. Use the Mac's current Wi-Fi IPv4 address in
`flutter run -d <iphone-id> --dart-define=API_BASE_URL=http://<mac-ip>:8000`.
The iOS app declares local networking for this development connection.
Production Voice Finder requires a TLS `https://` API / `wss://` WebSocket.
Do not distribute builds containing local QUL assets until their
resource-specific redistribution rights are established.
