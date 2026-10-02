# 11 — Madinah 1405H Mushaf redesign

**Version update:** [docs/12](12-QUL-CORE-AND-LIVE-VOICE.md) makes the semantic QUL migration database v2 and the complete print layout/font package v3. Latin, tafsir, and Surah meanings are deferred; related actions are hidden. The earlier v2 print-layer wording below records the prior plan only.

Status: target edition accepted; T-M04-R1 technical audit passed, source rights pending; T-M04-R2 local proof in progress · 2026-10-01. This document replaces the
flowing-text approach used in the T-M04 prototype. A provisional local Flutter renderer now uses the QUL print
pack, while the bundled content database remains version 2 and visual acceptance remains open.
See [ADR-006](adr/ADR-006-madinah-1405h-mushaf.md).

## 1. Required result

Mushaf mode must reproduce the **Madinah 1405H / KFGQPC V1** print: its page boundaries, prescribed lines,
glyph shapes, verse ornaments, surah headings, basmala placement, and page proportions. Ordinary pages use the
15-line layout; opening pages and other special rows follow the actual source. The whole page fits the viewport
at its default zoom. Increasing text size must not move words onto different lines or pages.

Every numbered ayah is pressable. Selecting any of its words or its end marker identifies the same canonical
`surah:ayah`, highlights its visible segments, and opens ayah actions. The existing list reader remains the
place for adjustable Arabic text and inline translation.

The old T-M04 checks proved text preservation and routing. They did not prove resemblance to the print and are
insufficient for the replacement's acceptance.

## 2. Verified source and remaining research

Official QUL resource pages checked on 2026-09-30:

- [Layout resource 15: KFGQPC V1 layout (1405H print)](https://qul.tarteel.ai/resources/mushaf-layout/15).
- [Font resource 238: QPC V1 Font](https://qul.tarteel.ai/resources/font/238), with page fonts and TTF downloads.
- [Script resource 57: QPC V1 Glyphs — Word by Word](https://qul.tarteel.ai/resources/quran-script/57).
- [QUL layout tool 2](https://qul.tarteel.ai/mushaf_layouts/2) lists the 1405H pages; page 42 contains 2:253–2:256.
  Tool ID 2 and download resource ID 15 are different identifiers.

The published layout describes ordered lines and their word ranges. It does not document pixel rectangles.
The three resources above form the proposed input set for a fixed-line glyph renderer. Pressable geometry will
be measured by our renderer from the same shaped glyphs it draws. This is a design decision, not a QUL API promise.

An exact 1405H page-image pack with matching coordinates has **not** been verified. Do not substitute generic
Madani images, V2/1421H fonts, or coordinates from another edition. An image approach can be reconsidered only
with a verified matching source and an updated ADR.

The local source audit records schemas, download identities, SHA-256 values, font coverage, and archive sizes.
Resource-specific license evidence and final installed-size measurements are still required before release.
QUL's public examples are illustrative; their sample font/page values must not become importer assumptions.
The local proof uses the audited title, basmala, and ornament fonts from QUL.
[QUL licensing guidance](https://qul.tarteel.ai/faq) requires checking terms for each resource.

### R1 audit snapshot (2026-10-01)

The signed-in QUL resource-15 download `qpc-v1-15-lines.db.zip` was inspected locally. Its SHA-256 is
`fb04bdfb0da38925853bc0ccdecd08b1536ac74fb1c8e9ff27a9af7ad7a452f9` (99,413 bytes). It contains
`qpc-v1-15-lines.db` (241,664 bytes; SHA-256
`54e5cf604da95f9e65db3fb9dce0c75c17d197e41543ba846ed49264f9c0442a`). The `info` row identifies
`Quran Complex V1 ( 1405 print )`, 604 pages, 15 lines, font `v1`. The `pages` table matches the documented
seven fields. There are 9,046 rows: 8,820 `ayah`, 114 `surah_name`, and 112 `basmallah`. Pages 1 and 2 have
eight rows each; all other pages have 15. Line numbers are contiguous on every page, and `ayah` word-ID ranges
run consecutively from 1 to 83,668. This ZIP contains no license file.

The matching resource-57 word-level export contains `words(id, location, surah, ayah, word, text)` and 83,668
records. The actual `id` joins the layout's word ranges; the website's sample `word_index`/`word_key` columns
are not present in this download. Its ZIP is 1,200,211 bytes and the extracted SQLite is 2,437,120 bytes.
The separate ayah-by-ayah glyph export cannot join the layout's word ranges.

The resource-238 file named `QPC-V1-Font.ttf.bz2` is actually a ZIP containing `p1.ttf` through `p604.ttf`.
It is 54,502,444 bytes compressed and the 604 TTFs total 95,020,860 bytes extracted. All 604 fonts contain
every code point used by their page's source words, checked through each TTF's cmap with `fc-query`. The full
audit joins all 83,668 words to source lines and all 6,236 canonical ayat, with **zero errors and zero page-map
differences** from the current mobile database. Thus the source's page 42 contains 2:255 and the current
canonical page metadata agrees for every ayah. The read-only audit produces the per-font SHA-256 and complete
comparison report in the ignored local cache; the pinned source summary is
[`qul_1405h_source_manifest.json`](../tools/build_quran_db/qul_1405h_source_manifest.json).

The QPC V1 surah-name and common fonts needed for headings and unnumbered basmala are also present in the local
proof. None of the three download archives includes a license file. The [QUL FAQ](https://qul.tarteel.ai/faq)
says resource rights vary and asks users to review each resource's terms. No resource-specific redistribution
permission has been established for this set, including the auxiliary fonts. Do not put the exports or fonts in
tracked mobile assets or publish them until that evidence is obtained. Visual fidelity to the print remains a
separate acceptance check.

For the revised local proof, QUL [Surah header font 458](https://qul.tarteel.ai/resources/font/458) supplies the complete ornament and Surah title in each source `surah_name` row. QUL [Surah name font v2 455](https://qul.tarteel.ai/resources/font/455) supplies the top-left Surah name outside the page. QUL [common font 459](https://qul.tarteel.ai/resources/font/459) supplies the Juz glyph at the top right, beside the Hizb number from local metadata. The source layout specifies heading rows and Surah numbers, but not a ready-made colored raster banner or screen chrome. These fonts remain local-only pending resource-specific redistribution permission.

The three QUL archives plus the two auxiliary TTFs total about 56.1 MB as downloaded; the extracted page fonts alone
are 95.0 MB, before the existing 18.8 MB mobile SQLite and app code. The provisional 60 MB base-size target is
therefore under pressure. Actual APK/IPA download and installed sizes still need measurement; do not change
the complete-offline requirement based on archive sizes alone.

### R2 local visual proof (2026-10-01)

`tools/build_quran_db/preview_qul_1405h.py` generates an ignored, local HTML proof for pages 1, 2, 42, 48,
121, 187, and 604. It reads the source line and word rows without copying them into the repository, loads the
matching V1 page TTF for each selected page, and lets a reviewer tap a word to highlight its canonical ayah.
The page-48 screenshot demonstrates that all visible segments of the long 2:282 can be selected across its 15
prescribed lines. The heading font was corrected to QPC V1 after a screenshot exposed plain Latin text.

This browser proof establishes source rendering and a selection concept, not approved print proportions or
Flutter touch geometry. A provisional Flutter renderer has since been tested locally on an iOS Simulator using
the staged print assets. Its latest local proof removes the outer border, moves the page jump control to the
bottom, uses QUL color Surah headers spanning the source line, and shades selected ayah segments by line.
It retains the exact QPC V1 word order and source line membership. On tall portrait screens, the provisional
reader spreads the 15 source lines through the available height without stretching QPC glyphs; the two eight-line
opening pages start at the top and keep their source eight-line grouping with even vertical spacing. The ayah
highlight now aligns vertically with the glyphs and has no added word padding. After the page-4 reference exposed excess gaps between
words, the local proof uses 42 design-unit QPC glyphs and removes per-word horizontal padding. HarfBuzz shaping
of all 8,820 ayah lines measured a maximum 635-unit advance within the 644-unit line width; visual comparison of page 4
now shows the denser line flow. The top Surah and Juz pills open selectable page-jump lists, while the bottom
control contains the page/ayah jump and floating mic, outside the printed text. Pressing a word now opens explicit
Translation and Bookmark options; translation expands to canonical Arabic and Indonesian text, with copy/share
actions. The user approved page-4 text density. Android page 128 was inspected before that change; fresh Android
and iOS comparisons at the final glyph size, font memory measurements, and full-page appearance review remain
open. Zoomed word-tap testing passes. The local v3 schema and asset package are built; release packaging still
requires device evidence and redistribution rights.

## 3. Rendering and interaction design

1. Load the edition's page, ordered line rows, glyph tokens, and exact page font from local assets.
2. Lay out a page in a fixed design coordinate system. Preserve each source line's token order and centered or
   justified alignment. Establish page margins, baselines, and title treatment against approved references.
   Never ask a paragraph widget to discover line breaks or substitute Amiri for missing V1 glyph fonts.
3. Shape each line with its matching font. Keep token-to-UTF-16-span mappings, including ligatures and end markers;
   do not assume one code point equals one word. Obtain selection boxes from the same shaped line.
4. Group token boxes by canonical ayah, preserving separate segments for different lines. These boxes drive both
   hit testing and highlights. A rectangle covering the whole height of a multi-line ayah would select adjacent
   ayat and is not acceptable.
5. Apply the same page-fit, zoom, pan, and inset transform to drawing and overlays. Map touches through its inverse
   before hit testing. Recompute derived geometry when the font, layout revision, or design metrics change.

The interaction contract is:

- Tap a word or numbered end marker: select its ayah and open an action sheet with translation, bookmark,
  copy, and share. Copy/share use canonical text; encoded glyph strings never leave the renderer. Playback joins
  these actions when T-D05 is implemented.
- Long press: expose the same ayah actions without moving the page. A drag, pinch, or page swipe must not select.
- Blank space, frames, headers, and an unnumbered basmala never invent an ayah selection. Preserve the source's
  numbered Al-Fatihah basmala and its separate unnumbered basmala rows without duplicating either.
- Pinch zoom and pan preserve the print. At default scale, swipe right advances the reversed PageView. While
  zoomed, panning takes precedence over page swiping; zoom reset returns to the full page.
- `ReaderController.highlight` retains its canonical range and four-second pulse. Paint only matching ayah
  segments, then retain a subtle marker. Ranges spanning pages remain selected as the user pages through them.
- Voice, search, bookmarks, and deep links resolve the first canonical ayah using the selected edition's mapping.
  The server's legacy `page` field is not the authority for the 1405H view.
- Provide semantic ayah labels and actions for TalkBack/VoiceOver using canonical text. Offer the accessible list
  reader when users need reflow or large text; screen-reader order must follow the Qur'an reading order.

## 4. Database rebuild and existing data

The **version 2 immutable `quran.sqlite`** now contains QUL semantic content and preserves all 6,236 canonical
ayah IDs. A later **version 3 print package** adds the edition, asset, page, line, and word contracts in
[docs/06 §1.1](06-DATA-MODEL.md#11-planned-madinah-1405h-presentation-data). This does not require retraining ASR.

QUL word IDs belong to the rendering dataset. Join them to canonical ayat using `surah:ayah`, never by assuming
that a QUL word index equals an ayah ID. Keep `ayah.page` and `page` tables for existing consumers; compare
all edition boundaries and record differences. Mushaf navigation uses the active edition mapping.

Coordinate the builder, verifier, Drift schema, mobile loader, and bundled checksum for v3. The current loader
requires v2 semantic content, so replacing the print assets alone would be insufficient. Install a verified
matching database/font pack atomically and reject mixed revisions. Keep the previous verified package if an update
fails. If the first v2 → v3 upgrade fails, show a recoverable content error and preserve `user.sqlite`.

Preserve `user.sqlite`. Bookmarks and notes retain their canonical ayah IDs. Recompute cached last-read pages from
the saved ayah under the 1405H edition; preserve that ayah even when its previous page number changes. Existing
page-based khatam progress keeps its original edition mapping until a verified conversion is available; never
silently relabel completed pages under different boundaries. Existing
server text/index assets must share the active v2 database checksum. Live listening adds the separate
`/v1/voice/live` WebSocket contract in docs/12.

## 5. Offline delivery and size decision

The target remains a complete 604-page reader available offline after installation. Prefer packaging the
matching layout, script, and page fonts with the app. QUL is a build-input source, not a runtime reader dependency.
Cache only a bounded working set of loaded fonts and page geometry; do not retain 604 rendered pages in RAM.
The visual proof must measure the platform font-loading lifecycle during repeated page traversal; evicting a
Dart cache alone must not be assumed to release fonts held by the rendering engine.

The existing 60 MB base-size goal is provisional for this edition until the complete licensed bundle is measured.
Record compressed download size, installed asset size, and peak reader memory in T-M04-R1/R2. If the complete
bundle cannot satisfy the size goal, present the measured tradeoff before changing the offline requirement or
introducing a downloadable pack. Do not quietly ship partial offline coverage.

## 6. Implementation sequence for later sessions

1. **T-M04-R1 — Source audit:** inspect the three exports and auxiliary artwork, pin provenance and rights, measure
   sizes, and report all page-map differences. Deliver a concrete source manifest and schema mapping.
2. **T-M04-R2 — Visual proof:** render only representative pages 1, 2, 42, 48, 121, 187, and 604 with the matching V1
   fonts. Compare them with approved 1405H references, demonstrate one pressable multi-line ayah, and obtain user
   review of the actual page appearance before integrating the full reader. The local browser proof, provisional
   Flutter renderer, device screenshots at the earlier glyph size, and dense page-4 widget render exist; final
   device comparison and user review remain open.
3. **T-M04-R3 — Rebuild content:** add the presentation data, pin assets, verify complete mapping, and coordinate
   the v2 to v3 content migration with a fixture containing bookmarks, notes, and last-read state.
4. **T-M04-R4 — Reader and interaction:** replace the flowing Mushaf view with fixed-page rendering, zoom, geometry
   hit testing, ayah action sheets, and the range highlight API. Retain the independent list reader.
5. **T-M04-R5 — Navigation and acceptance:** connect jumps, canonical deep links, last read, and voice/audio entry
   points; run full data, visual, interaction, offline, and device-performance checks in docs/09.

T-M05 and T-D05 consume the replacement only after T-M04-R5 passes. The existing prototype is retained until the
replacement is verified; its earlier passing tests do not mark this redesign complete.

## 7. Acceptance evidence

- All 604 pages preserve approved 1405H line membership, glyphs, headings, basmala rules, and page boundaries.
  Representative visual comparisons must include both opening pages, 2:255, the long 2:282, the 1405H page-121
  boundary, the At-Tawbah opening, and the final multi-surah page.
- Every canonical ayah has complete rendering membership. Taps on words and end markers select the correct ayah
  at default scale and after zoom, resize, and rotation. No taps on decorations select unrelated text.
- `hafidz://quran/ayah/2:255` resolves locally to page 42 and pulses only the segments of 2:255 for four seconds.
  Page/juz/surah/ayah jumps, multi-line and cross-page range highlighting, and canonical copy/share all pass.
- A fresh installation reads every page in airplane mode; missing, corrupt, or mixed-revision assets fail visibly
  without rendering wrong glyphs. User data survives the content rebuild.
- iOS and Android visual references are reviewed. Profile builds meet the 60 fps page-turn target on the chosen
  mid-range device; a successful debug build alone is not performance evidence.

R1 audit is complete, with redistribution rights unresolved. R2 currently runs a provisional Flutter renderer
from ignored local QUL print assets. The v3 content schema, release packaging, device performance profile, and
final visual acceptance are still pending.
