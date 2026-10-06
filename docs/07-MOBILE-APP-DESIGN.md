# 07 — Mobile App Design (Flutter)

**Current target:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) governs the QUL content and live Voice Finder contract. The app opens on the Surah list; the Mushaf alone has a visible live Voice Finder FAB.

## 1. Information architecture

Bottom navigation (4 tabs):

| Tab | Route | Content |
|---|---|---|
| Al-Qur'an | `/quran` | Surah list and Juz starts, local search, two-action Surah chooser |
| Sholat | `/prayer` | Today's times, month view, adzan settings, location |
| Belajar | `/learning` | Hafalan preview |
| Lainnya (More) | `/more` | Kiblat, Doa, Asmaul Husna, Tasbih, Hijri calendar, Settings, About & Attribution |

`/` redirects to `/quran`. The `/qibla` deep link remains available from Lainnya.

### Al-Qur'an library and chooser

- The Surah list uses the local QUL database for all 114 names, Arabic names, ayah counts, revelation places, and first pages. Search matches number, Latin name, or Arabic name. The subtitle shows ayah count and Makkiyah/Madaniyah; Surah meanings remain hidden.
- The Juz control lists 1–30 and resolves each start page through the local QUL Juz-to-ayah mapping. It opens that page directly. Riwayat is deferred until persistent reading history exists; no inactive control is displayed.
- Tapping a Surah opens a centered photo chooser. The user-supplied Makkah and Madinah photos follow its revelation place. Only `Baca Mushaf` (the existing first-page route) and `Terjemahan` (the existing list-reader route) are offered. Murattal remains deferred.
- The dark design follows the approved Figma screenshot. Light and sepia adapt the same layout to their existing theme preferences; the app's default theme remains light. The chooser and library do not change printed Mushaf styling or its mic.

## 2. Routes & deep links (go_router)

| Route | Screen | Notes |
|---|---|---|
| `/quran/surah/:n?ayah=:a` | List reader | Scrolls to ayah |
| `/quran/page/:p?ayah=:s::a[-:b]&hl=1` | Mushaf reader | Planned 1405H edition page; canonical ayah target takes precedence over stale page metadata; `hl=1` pulses it |
| `/quran/ayah/:key` | Resolves to page route via local edition mapping (`key` = `2:255`) | Used by share links; 1405H resolution planned in T-M04-R5 |
| `/voice` | Voice Ayah Finder (full-screen modal) | |
| `/voice/result` | Candidate picker (bottom sheet route) | |
| `/prayer/month` , `/prayer/settings` , `/prayer/location` | | |
| `/doa` , `/doa/:id` , `/hadith` , `/hadith/:book` , `/hadith/:book/:n` , `/asmaul-husna` , `/tasbih` , `/hijri` , `/settings` , `/about` | | |

External deep links use the registered `hafidz` scheme, for example `hafidz://quran/ayah/2:255`. App Links / Universal Links use `https://example.com/q/2:255` as a placeholder until an owned app domain is configured.
Android intent filter for `ACTION_SEND` `audio/*` → `/voice?shared=1` (US-01.2).

The route shapes remain stable through the [1405H redesign](11-MUSHAF-1405H-REDESIGN.md).
The current prototype resolves through legacy DB page metadata. Its replacement will resolve canonical ayah
targets through the local 1405H edition mapping; page-only links refer to that selected print. Server `page`
values remain legacy metadata and must not override the edition's local ayah lookup.

## 3. Voice Ayah Finder — current live flow

The Mushaf's sole floating mic button starts a WebSocket session after
microphone permission and a server `ready` event. A compact status control
outside the print area shows connecting, listening, searching, paused follow,
or a recoverable error. There is no recording overlay or audio file for the
live path. The existing `/voice` and `/voice/result` routes remain for the
later shared-file task T-M06.

The app streams 16 kHz mono PCM16LE in half-second frames. It follows only
new stable `ayah` revisions with increasing sequence numbers; `candidate`
and `ambiguous` keep the current highlight. It validates the canonical ayah
range, resolves the end ayah's page from the installed QUL edition, and
highlights the full range. Pause follow leaves the mic active and remembers
the latest stable ayah; resume catches up immediately. Stop, screen disposal,
server error, or connection loss stops capture. Errors offer Retry, while
permission denial explains how to grant microphone access. See [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md)
and [docs/05 §2.1a](05-BACKEND-API-SPEC.md) for transport and event fields.

### Live recognition strip

The Mushaf mic opens a compact bottom strip beside the Stop mic, outside the print canvas. Show connecting/listening/error states, the latest nonempty Arabic recognition text before the first stable match (RTL, Me Quran font at 14 logical pixels, regular weight, muted gray-green, at most three display lines), and a localized “may change” label. Pause/Resume follow and Retry remain visible where applicable. Keep page information at the bottom. Clear and hide the recognition text and its label on the first stable ayah event, even when follow is paused; later preview events keep it hidden until a new session starts. Listening, Stop, and Pause/Resume remain available. Preview updates never turn pages; only stable validated ayah revisions do. Stop is available during connection as well as listening. Backgrounding, leaving the reader, Stop, or a failed session closes capture and clears the preview. The print renderer and source lines are unchanged.

## 4. Qur'an reader

### 4.1 Mushaf status and target

The current local v3 renderer uses QUL KFGQPC V1 fixed lines, word glyphs, and matching page fonts. The user has accepted the visual direction; the deferred offline/performance checks remain on the roadmap. The [redesign plan](11-MUSHAF-1405H-REDESIGN.md) and [ADR-006](adr/ADR-006-madinah-1405h-mushaf.md) define print fidelity.

- **Print source:** use QUL layout 15 (KFGQPC V1, Madinah 1405H) with matching word glyphs 57 and page fonts 238.
  Use the source's ordered line membership, alignment, headings and basmallah rows. Ordinary pages have the
  15-line layout; opening pages and other special rows follow the source instead of a fixed row-count assumption.
  Preserve the numbered Al-Fatihah basmala, separate unnumbered basmallahs and source end markers without duplication.
- **Fixed page:** render glyphs in a fixed page coordinate system, retaining the print's word positions, page
  proportions and prescribed lines. Fit the complete page by default. Pinch zoom and pan enlarge the same page;
  text scaling must not wrap words onto new lines. Missing page fonts produce an asset error, not a generic font fallback.
- **Current local proof on tall phones:** use the available page height as extra leading between the 15 prescribed
  lines, keeping their order, glyph aspect ratio and horizontal shaping intact. Keep the eight-line opening pages
  compact until their decorative frame and final reference geometry are approved. Size the QPC word glyphs to
  use the line width with natural inter-word spacing; do not insert large equal gaps between undersized words.
- **Paging and jumps:** retain a reversed RTL `PageView` for 604 pages; swipe right to advance at default zoom.
  When zoomed, panning takes precedence over paging; resetting zoom returns to page fit. Page/juz/surah/ayah jumps
  use the bundled edition mapping. Tapping the top Surah or Juz pill opens a selectable list of all 114 Surahs or
  30 Juz; the bottom page control opens the full jump sheet and holds the circular Voice Finder mic outside the
  printed page. Voice, search, bookmarks and ayah deep links resolve
  canonical ayat locally.
- **Offline package:** plan to ship the complete licensed layout, glyph data and matching page fonts for reading
  after installation with no network. Actual bundle size and font coverage remain pending source audit; the 60 MB
  goal must be measured before the delivery decision. Do not replace full offline coverage with unannounced downloads.
  Keep only a bounded set of loaded fonts and measured pages in memory.

### 4.2 Ayah selection and highlights (planned replacement)

- Shape each prescribed line with the correct page font and keep token-to-text-span mappings, including source
  end markers and ligatures. Measure token boxes from those same shaped glyphs, then group boxes by canonical
  `surah:ayah`. QUL's published layout describes lines and word ranges; no upstream pixel rectangles or complete
  edition-matched image pack has been verified.
- Tap any word or its numbered end marker to select the ayah and open a sheet with prominent Translation and
  Bookmark options. Expanding Translation shows the canonical Arabic, Indonesian translation, copy and share.
  Long press exposes the same actions. Playback joins these actions in T-D05. Dragging, pinching
  or swiping must not trigger an ayah selection; frames, headers, unnumbered basmallahs and gaps select no ayah.
- Draw highlights using the same measured geometry, keeping separate regions for different lines. The drawing,
  overlays and hit tests share page-fit/zoom/pan/inset transforms; touches use the inverse transform. Do not use
  a single enclosing rectangle that also covers neighboring ayat.
- **Highlight API:** retain `ReaderController.highlight(AyahRange range, {Duration pulse = 4s})` for voice, search
  and audio follow-along. An ayah target opens its locally resolved first page, pulses its visible segments for
  four seconds, then leaves a subtle marker. Cross-page ranges retain selection as the user pages through them.
  `hafidz://quran/ayah/2:255` must resolve to page 42 and highlight only 2:255.
- Copy/share, translation/tafsir lookups and TalkBack/VoiceOver actions use canonical ayah identity and semantic
  text. Encoded glyph strings never become copied or spoken text. Semantics follow Quran reading order; users
  who need larger reflowing text can open list mode or ayah details.
- Auto-save the canonical last-read ayah on page change (debounced one second). Preserve `user.sqlite` during the
  planned content-v2 rebuild and recompute derived pages through the active edition.

### 4.3 Surah and translation reader

- `/quran/surah/:n?ayah=:a` positions the requested ayah. A horizontally scrollable top strip shows all 114 QUL Surah names in right-to-left order, centers the selected Surah, and marks it with a gold underline. Tapping a tab or swiping the reading area changes Surah and starts at ayah 1. The route changes with the selection; a direct ayah link still opens its requested position.
- `ScrollablePositionedList.builder` loads only the selected Surah's ayat and builds visible rows. Rows use flat, spacious styling with the supplied QUL QPC V1 ayah-by-ayah glyph strings and their matching page fonts, followed by QUL Indonesian translation when `show_translation` is enabled. Canonical QUL Uthmani stays separate for copy/share/search and accessibility. Do not display Latin transliteration, tafsir, or Surah meanings.
- Bookmark, copy, and share remain visible actions; long press exposes the same actions. No unavailable playback button or unidentified screenshot controls appear. Existing reading-position and translation-setting persistence remain.
- Light and sepia use warm paper, dark ink, and muted gold; dark mode adapts the same layout for contrast. The 1405H printed Mushaf and its microphone remain separate and unchanged.
- The tab strip stays mounted during Surah loading and only recenters when selection or name data changes. Ayah footers show regular digits (1, 2, 3) at bottom left with the working actions at right.
- There is no metadata row between the tabs and Bismillah. The toolbar translation toggle persists `show_translation`. Each regular ayah string already includes its Arabic numbered ornament; do not append a second marker. Only built rows request their matching page fonts. If glyph assets fail, show a localized warning with readable canonical QUL text. Al-Fatihah's opening has no ornament.
- Show the opening Bismillah above the ayat using QUL 1:1 glyphs, omitting only their terminal number ornament visually; its accessibility label remains canonical QUL text. At-Tawbah has no added opening. Al-Fatihah presents its canonical 1:1 as a centered opening with translation/actions but no number badge or duplicate text; subsequent ayat retain source numbers 2–7. Other Surah openings have no artificial ayah identity. Direct links, copy/share, bookmarks, and reading position retain canonical IDs.

## 5. Murottal player

- `just_audio` + `audio_service` for background & lock-screen controls.
- Playlist = per-ayah URLs from reciter template (docs/05 §2.2) → exact ayah highlighting via `currentIndexStream`.
- Modes: single ayah, range, surah, repeat-N (hafalan), continuous to next surah.
- Offline: download surah files into `audio_download`; player prefers local file.

## 6. Prayer times & adzan

- Location: `geolocator` → `/v1/prayer/locations/reverse` (or offline nearest from `prayer_location` table using haversine).
- Fetch 2 months → `prayer_cache`. If network fails → `adhan` Dart package with KEMENAG params
  (Fajr 20°, Isha 18°, Shafi'i Asr, + ihtiyat) → `source = calc`.
- Scheduling: `flutter_local_notifications.zonedSchedule` with `AndroidScheduleMode.exactAllowWhileIdle`; request
  `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` rationale; reschedule on boot (`RECEIVE_BOOT_COMPLETED`), on location change,
  and daily at 00:05 via `workmanager`. iOS: max 64 pending notifications → schedule the next 7 days only.
- Custom adzan sounds bundled (`res/raw` Android, `.caf` iOS, ≤ 30 s for iOS).

## 7. Qibla

- Bearing computed locally: `θ = atan2(sin Δλ · cos φk, cos φ · sin φk − sin φ · cos φk · cos Δλ)` with Kaaba
  (21.4225, 39.8262). Compass heading from `flutter_compass`; show accuracy warning + figure-8 calibration animation.
- Correct for magnetic declination (`geomag` model or `flutter_compass` true-heading where available).

## 8. Design system

| Token | Value |
|---|---|
| Library teal | `#0F766E`; dark-mode active text `#2DD4BF` |
| Library gold | `#B08D57` |
| Dark library | Background `#0B1416`, card `#122326`, border `#243638`, text `#F5F6EF`, muted `#A0B2B2` |
| Other themes | Existing warm cream `#F7F3E8`, forest green `#174C3F`, and sepia preference remain |
| Arabic font — list/details | QUL QPC V1 matching page fonts in Surah reader; Me Quran for semantic fallback/details |
| Mushaf font — planned | Exact QPC V1 font for each 1405H page, matched to its glyph data; source line layout and whole-page scaling |
| Latin font | Inter / Plus Jakarta Sans |
| Radius | 16 cards, 28 sheets |
| Motion | 200 ms standard, 4 s highlight pulse |

Arabic content uses RTL direction. The planned Mushaf uses each source line's centered/justified alignment in
fixed page coordinates; generic paragraph wrapping and the list-mode font-size preference do not apply to it.

## 9. i18n

`flutter_localizations` + ARB files `app_id.arb` (default), `app_en.arb`. Never hardcode UI strings. Surah names and revelation metadata come from the local QUL database; Indonesian Surah meanings are deferred.

## 10. Permissions

| Permission | Why | When requested |
|---|---|---|
| Microphone | Voice Ayah Finder | First mic tap, after rationale screen |
| Location (when in use) | Prayer times, qibla | Onboarding step 2 (skippable → manual city) |
| Notifications (Android 13+ / iOS) | Adzan | Onboarding step 3 |
| Exact alarms (Android 12+) | On-time adzan | When enabling adzan |

## 11. Onboarding (3 steps)

1. Language (Bahasa Indonesia / English).
2. Location (GPS or pick city) → shows today's schedule preview.
3. Notifications & adzan preference → Al-Qur'an Surah list.
