# 07 — Mobile App Design (Flutter)

**Current target:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) supersedes the old five-tab, Home microphone, Latin/tafsir, and one-shot-only UI descriptions below. The next shell has four tabs, opens on the Surah list, and places one live Voice Finder FAB outside the printed Mushaf page.

## 1. Information architecture

Bottom navigation (5 tabs):

| Tab | Route | Content |
|---|---|---|
| Beranda (Home) | `/` | Next-prayer countdown card, Hijri + Gregorian date, **Voice Ayah Finder big mic button**, last read, ayat of the day, quick tiles (Qibla, Doa, Tasbih, Hadith, Asmaul Husna) |
| Al-Qur'an | `/quran` | Surah / Juz / Bookmarks tabs; search; mic FAB |
| Sholat | `/prayer` | Today's times, month view, adzan settings, location |
| Kiblat | `/qibla` | Compass |
| Lainnya (More) | `/more` | Doa, Hadith, Asmaul Husna, Tasbih, Hijri calendar, Settings, About & Attribution |

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

## 4. Qur'an reader

### 4.1 Mushaf status and target

The existing T-M04 prototype renders verbatim ayat as flowing Amiri Quran text grouped by page. It supports
navigation and highlight, but its printed appearance is **not accepted**. The following replacement is planned
under T-M04-R1–R5; no new renderer, QUL assets or database migration is implemented by this documentation revision.
The [redesign plan](11-MUSHAF-1405H-REDESIGN.md) and
[ADR-006](adr/ADR-006-madinah-1405h-mushaf.md) replace the previous v1/v2 rendering choices.

- **Print source:** use QUL layout 15 (KFGQPC V1, Madinah 1405H) with matching word glyphs 57 and page fonts 238.
  Use the source's ordered line membership, alignment, headings and basmallah rows. Ordinary pages have the
  15-line layout; opening pages and other special rows follow the source instead of a fixed row-count assumption.
  Preserve the numbered Al-Fatihah basmala, separate unnumbered basmallahs and source end markers without duplication.
- **Fixed page:** render glyphs in a fixed page coordinate system, retaining the print's word positions, page
  proportions and prescribed lines. Fit the complete page by default. Pinch zoom and pan enlarge the same page;
  text scaling must not wrap words onto new lines. Missing page fonts produce an asset error, not Amiri fallback.
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

### 4.3 List mode (existing)

- `ScrollablePositionedList.builder` per surah loads ayat from the bundled database and builds only
  visible cards. `/quran/surah/:n?ayah=:a` positions the requested ayah. Each card shows verbatim Uthmani text in
  the bundled Amiri Quran font (RTL), plus optional Kemenag Latin text and Indonesian translation. The switches use
  `show_latin` and `show_translation` in `user.sqlite.kv_setting`. Bookmark, share, copy, and Kemenag tafsir actions
  work offline; the play button shows an availability message until T-D05 adds murottal playback.
- Long-press ayah → action sheet. The independent list reader retains adjustable text and its existing reading-position behavior.

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
| Primary | Emerald `#0F766E` (light) / `#2DD4BF` (dark) |
| Accent | Gold `#B08D57` |
| Surfaces | Light `#FAFAF7`, Sepia `#F5EEDC`, Dark `#0B1416` |
| Arabic font — list/details | Bundled Amiri Quran 1.003; default 28 sp, range 20–44 |
| Mushaf font — planned | Exact QPC V1 font for each 1405H page, matched to its glyph data; source line layout and whole-page scaling |
| Latin font | Inter / Plus Jakarta Sans |
| Radius | 16 cards, 28 sheets |
| Motion | 200 ms standard, 4 s highlight pulse |

Arabic content uses RTL direction. The planned Mushaf uses each source line's centered/justified alignment in
fixed page coordinates; generic paragraph wrapping and the list-mode font-size preference do not apply to it.

## 9. i18n

`flutter_localizations` + ARB files `app_id.arb` (default), `app_en.arb`. Never hardcode UI strings. Surah names:
Latin + Indonesian meaning from DB, not ARB.

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
3. Notifications & adzan preference → Home.
