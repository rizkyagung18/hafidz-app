# 01 — Product Requirements Document (PRD)

| Field | Value |
|---|---|
| Product | Hafidz App — Muslim Daily Companion with Voice Ayah Finder |
| Version | 1.0 (MVP) |
| Primary market | Indonesia (Bahasa Indonesia UI first, English second) |
| Platforms | Android (primary), iOS |
| Owner | Product / System Analyst |
| Status | Draft for implementation |

## 1. Problem & vision

Muslims often hear an ayah (in salat, a kajian, a video, or from their own memorization) and want to
**find it instantly in the Mushaf** — to read the translation, tafsir, or continue reciting. Typing Arabic is hard,
and existing apps split daily needs (prayer times, qibla, du'a) across many apps.

**Vision:** one lightweight, offline-first app for daily worship needs, with an AI feature that turns a short
voice recitation into the exact Mushaf page and ayah.

## 2. Goals & success metrics

| Goal | Metric | MVP target |
|---|---|---|
| Accurate ayah detection | Top-1 ayah accuracy on golden set (docs/09) | ≥ 90 % (clean recitation, 5–20 s) |
| | Top-3 accuracy | ≥ 97 % |
| Fast | P95 end-to-end latency (stop recording → page shown) on 4G | ≤ 3.0 s |
| Useful daily | D7 retention | ≥ 30 % |
| Reliable prayer times | Deviation vs Kemenag schedule | ≤ 2 min |
| Stable | Crash-free sessions | ≥ 99.5 % |

## 3. Personas

1. **Aisyah (24, office worker, Jakarta)** — hears an ayah in a kajian on YouTube, wants to know which surah it is.
2. **Pak Budi (48, imam musholla)** — needs accurate prayer times, adzan notifications, and quick Qur'an access.
3. **Fikri (16, santri / hafidz student)** — recites from memory and wants to jump to where he is in the Mushaf.

## 4. Scope

### 4.1 In scope (MVP)

| ID | Feature | Priority |
|---|---|---|
| F-01 | **Voice Ayah Finder** (record → detect → auto-navigate + highlight) | P0 |
| F-02 | Qur'an reader: Mushaf page mode (604 pages) + list (surah) mode, Arabic + Latin + Indonesian translation | P0 |
| F-03 | Murottal audio: per-ayah and full-surah playback, 6+ qari, repeat / range play, follow-along highlight | P0 |
| F-04 | Prayer times (Kemenag-accurate for Indonesia; calculation worldwide) + adzan notifications | P0 |
| F-05 | Qibla compass | P0 |
| F-06 | Bookmarks, last read, reading progress (khatam tracker) | P0 |
| F-07 | Hijri calendar + Islamic holidays | P1 |
| F-08 | Daily du'a collection | P1 |
| F-09 | Hadith browser (9 kitab, Indonesian translation) | P1 |
| F-10 | Tafsir per ayah (Kemenag) | P1 |
| F-11 | Asmaul Husna | P2 |
| F-12 | Digital tasbih counter | P2 |
| F-13 | Global search (surah name, ayah text, translation keyword) | P1 |
| F-14 | Settings: language, theme (light/dark/sepia), Arabic font size, qari, calc method, notifications | P0 |

### 4.2 Out of scope (MVP)

- Real-time streaming recitation correction / tajwid mistake detection (Phase 3, see docs/03 §9).
- User accounts & cloud sync (Phase 2; MVP stores everything locally).
- Social features, donations/zakat payments, e-commerce.

## 5. User stories & acceptance criteria

### F-01 Voice Ayah Finder

**US-01.1** As a user, I tap the mic button, recite (or play) an ayah for a few seconds, and the app opens the Mushaf page
of that ayah with the ayah highlighted.

Acceptance criteria:
- AC1: Mic button is reachable from Home and from the Qur'an reader (FAB) in ≤ 1 tap.
- AC2: Recording starts within 300 ms of tap; a live waveform + timer is shown; max length 30 s, min 2 s.
- AC3: Recording auto-stops after 2.0 s of silence (VAD) or at 30 s; user can stop manually.
- AC4: While processing, a progress state "Mencari ayat…" is shown; request can be cancelled.
- AC5: If `confidence ≥ 0.80` and the top result is unambiguous (margin ≥ 0.10 over #2), the app navigates directly to
  `/quran/page/{page}?ayah={s}:{a}` and highlights the ayah range for 4 s (then keeps a subtle marker).
- AC6: If `0.55 ≤ confidence < 0.80` or ambiguous, show a bottom sheet with top-3 candidates (surah name, ayah number,
  Arabic snippet, translation snippet); tapping navigates.
- AC7: If `confidence < 0.55`, show "Ayat tidak ditemukan" with tips (recite clearly, reduce background noise, 5–15 s).
- AC8: The detected transcript is shown (collapsible) for transparency.
- AC9: Multi-ayah recitation (e.g. 2:255–2:256) returns a range; navigation goes to the first ayah's page and highlights the range.
- AC10: Microphone permission rationale screen appears before the OS prompt; denial is handled gracefully.
- AC11: Works for recitation audio played from another device's speaker (tested in golden set "speaker-replay").
- AC12: Recent searches (last 20: ayah key + timestamp, **no audio**) are listed in history.

**US-01.2** As a user, I can share an audio file (e.g. WhatsApp voice note .opus/.m4a) to the app via the OS share sheet
and get the same detection result.

- AC1: Android intent filter + iOS share extension accept `audio/*`; file is transcoded to 16 kHz mono before upload.

### F-02 Qur'an reader
- AC1: 114 surah list with Arabic name, Latin name, meaning, ayah count, place of revelation.
- AC2: Mushaf mode renders 604 pages, swipe RTL, jump to page/juz/surah/ayah.
- AC3: List mode shows per-ayah Arabic, transliteration (toggle), Indonesian translation (toggle), audio button, bookmark,
  share, copy, tafsir.
- AC4: Fully offline after install.
- AC5: Deep link `hafidz://quran/ayah/2:255` and `hafidz://quran/page/42` work (used by Voice Ayah Finder).

### F-03 Murottal
- AC1: Choose qari; play ayah / range / surah; background playback with lock-screen controls.
- AC2: Current ayah highlighted while playing (ayah-by-ayah files make this trivial).
- AC3: Repeat ayah N times (hafalan mode); download surah for offline.

### F-04 Prayer times
- AC1: Auto-detect location (GPS) or manual city pick (Indonesian kab/kota list).
- AC2: Indonesia: use Kemenag-sourced schedules (equran.id / myQuran) with on-device calculation fallback
  (method KEMENAG = Aladhan method 20 / `adhan` library equivalent).
- AC3: Shows imsak, subuh, terbit, dhuha, dzuhur, ashar, maghrib, isya; countdown to next prayer.
- AC4: Adzan notification per prayer (toggle, sound choice, pre-reminder minutes); survives reboot; exact alarms on Android.
- AC5: Month view.

### F-05 Qibla
- AC1: Compass arrow to Kaaba bearing computed on-device (great-circle), calibrate prompt when magnetometer accuracy is low.

### F-06..F-14
See docs/07 for screen specs; acceptance: data loads, offline cache, empty/error states, i18n strings.

## 6. Non-functional requirements

| Category | Requirement |
|---|---|
| Performance | Cold start ≤ 2 s on mid-range Android (Snapdragon 6xx); Mushaf page swipe 60 fps |
| App size | ≤ 60 MB base (Qur'an DB + fonts bundled; Mushaf page images or glyph fonts downloaded on demand) |
| Offline | F-02, F-04 (calc fallback), F-05, F-06, F-11, F-12 fully offline |
| Privacy | Voice processed ephemerally; no raw audio stored without opt-in; no PII required |
| Accessibility | Dynamic font size, TalkBack/VoiceOver labels, contrast ≥ 4.5:1 |
| i18n | `id` (default), `en`; Arabic content always RTL |
| Availability (backend) | 99.5 % monthly |
| Scalability | ASR service horizontally scalable; 50 req/s sustained on 4 CPU pods (base model int8) |

## 7. Assumptions & risks

| Risk | Impact | Mitigation |
|---|---|---|
| Whisper-base accuracy drops with noise / non-professional reciters | Wrong ayah | Fuzzy multi-ayah matching, top-3 fallback UI, confidence gating; Phase 2 evaluate larger Tarteel models |
| Short/repeated phrases (e.g. "فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ" repeated 31× in Ar-Rahman) | Ambiguous | Return all equal candidates; UI explains ambiguity; use context (last-read surah) as tiebreaker |
| Free third-party APIs have no SLA | Feature outage | BFF caching + fallback providers + bundled offline data |
| Content licensing | Legal | Use sources with explicit terms; attribution screen (docs/10) |
