import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/features/quran/data/mushaf_print_data.dart';
import 'package:hafidz_app/features/quran/data/qpc_ayah_glyphs.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/features/quran/domain/reader_settings.dart';
import 'package:hafidz_app/features/quran/presentation/quran_library_palette.dart';
import 'package:hafidz_app/features/quran/presentation/reader_settings_controller.dart';
import 'package:hafidz_app/features/quran/presentation/surah_list_screen.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

typedef SurahContent = ({SurahData? surah, List<AyahData> ayahs});

final FutureProviderFamily<SurahContent, int> surahContentProvider =
    FutureProvider.family<SurahContent, int>((
      ref,
      number,
    ) async {
      final repository = ref.read(quranRepositoryProvider);
      final surah = await repository.surahByNumber(number);
      if (surah == null) return (surah: null, ayahs: <AyahData>[]);
      return (surah: surah, ayahs: await repository.ayahsInSurah(number));
    });

final FutureProvider<Set<int>> bookmarkedAyahIdsProvider =
    FutureProvider<Set<int>>((ref) async {
      final bookmarks = await ref.read(bookmarkRepositoryProvider).all();
      return bookmarks.map((bookmark) => bookmark.ayahId).toSet();
    });

final AutoDisposeFutureProviderFamily<AyahEndMarker, AyahRef>
ayahEndMarkerProvider = FutureProvider.autoDispose
    .family<AyahEndMarker, AyahRef>((ref, ayah) {
      final databases = ref.watch(localDatabasesProvider);
      return loadAyahEndMarker(
        databases.quran,
        ayah,
        packDirectory: databases.printAssets,
      );
    });

final FutureProvider<Map<String, QpcAyahGlyph>> qpcAyahGlyphsProvider =
    FutureProvider<Map<String, QpcAyahGlyph>>(
      (ref) => readQpcAyahGlyphs(),
    );

final FutureProviderFamily<QpcAyahGlyph, AyahRef> surahAyahGlyphProvider =
    FutureProvider.family<QpcAyahGlyph, AyahRef>((
      ref,
      ayah,
    ) async {
      final glyphs = await ref.watch(qpcAyahGlyphsProvider.future);
      final glyph = glyphs[ayah.key];
      if (glyph == null) {
        throw FormatException('Missing QUL glyphs for ${ayah.key}');
      }
      final databases = ref.watch(localDatabasesProvider);
      await loadQpcPageFont(
        databases.quran,
        glyph.page,
        packDirectory: databases.printAssets,
      );
      return glyph;
    });

class QuranSurahScreen extends ConsumerStatefulWidget {
  const QuranSurahScreen({required this.surah, this.ayah, super.key});

  final int surah;
  final int? ayah;

  @override
  ConsumerState<QuranSurahScreen> createState() => _QuranSurahScreenState();
}

class _QuranSurahScreenState extends ConsumerState<QuranSurahScreen> {
  final _positions = ItemPositionsListener.create();
  double _horizontalDrag = 0;
  Timer? _saveTimer;
  List<AyahData> _ayahs = const [];
  int? _visibleAyah;
  bool _hasOpeningHeader = false;

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void didUpdateWidget(covariant QuranSurahScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surah != widget.surah) {
      _saveTimer?.cancel();
      _ayahs = const [];
      _visibleAyah = null;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _positions.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    if (_ayahs.isEmpty) return;
    final visible = _positions.itemPositions.value.where(
      (position) =>
          position.itemTrailingEdge > 0 && position.itemLeadingEdge < 1,
    );
    if (visible.isEmpty) return;
    final itemIndex = visible
        .map((position) => position.index)
        .reduce(
          (a, b) => a < b ? a : b,
        );
    final index = _hasOpeningHeader && itemIndex > 0
        ? itemIndex - 1
        : itemIndex;
    if (index < 0 || index >= _ayahs.length) return;
    final verse = _ayahs[index];
    if (verse.ayah == _visibleAyah) return;
    _visibleAyah = verse.ayah;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () async {
      if (!mounted) return;
      try {
        await ref
            .read(readingRepositoryProvider)
            .save(
              AyahRef(surah: verse.surah, ayah: verse.ayah),
              mode: ReadingMode.list,
            );
      } on Exception catch (_) {
        if (mounted) _message(AppLocalizations.of(context).errorUnknown);
      }
    });
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _openSurah(int number) {
    if (number < 1 || number > 114 || number == widget.surah) return;
    context.replace('/quran/surah/$number');
  }

  void _finishHorizontalDrag(DragEndDetails details) {
    final speed = details.primaryVelocity ?? 0;
    final direction = _horizontalDrag.abs() >= 56
        ? _horizontalDrag
        : speed.abs() >= 300
        ? speed
        : 0.0;
    _horizontalDrag = 0;
    if (direction == 0) return;
    _openSurah(widget.surah + (direction < 0 ? 1 : -1));
  }

  Future<void> _bookmark(AyahData verse, bool isBookmarked) async {
    final l10n = AppLocalizations.of(context);
    final refKey = AyahRef(surah: verse.surah, ayah: verse.ayah);
    try {
      final repository = ref.read(bookmarkRepositoryProvider);
      if (isBookmarked) {
        await repository.remove(refKey);
      } else {
        await repository.save(refKey);
      }
      ref.invalidate(bookmarkedAyahIdsProvider);
      if (mounted) {
        _message(
          isBookmarked ? l10n.quranBookmarkRemoved : l10n.quranBookmarkSaved,
        );
      }
    } on Exception catch (_) {
      if (mounted) _message(l10n.errorUnknown);
    }
  }

  Future<void> _copy(AyahData verse) async {
    await Clipboard.setData(ClipboardData(text: verse.textUthmani));
    if (mounted) _message(AppLocalizations.of(context).quranCopied);
  }

  Future<void> _share(AyahData verse, SurahData surah) async {
    final l10n = AppLocalizations.of(context);
    final reference = l10n.quranShareReference(
      surah.nameLatin,
      surah.number,
      verse.ayah,
    );
    final box = context.findRenderObject()! as RenderBox;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '$reference\n${verse.textUthmani}\n${verse.translationId}',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } on Exception catch (_) {
      if (mounted) _message(l10n.errorUnknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = ref.watch(surahContentProvider(widget.surah));
    final settings =
        ref.watch(readerSettingsProvider).valueOrNull ?? const ReaderSettings();
    final bookmarked =
        ref.watch(bookmarkedAyahIdsProvider).valueOrNull ?? const <int>{};
    final palette = QuranLibraryPalette.from(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        title: Text(l10n.quranTranslationChoice),
        actions: [
          Semantics(
            toggled: settings.showTranslation,
            child: IconButton(
              key: const Key('reader-translation-toggle'),
              tooltip: l10n.quranShowTranslation,
              color: settings.showTranslation ? palette.gold : palette.muted,
              onPressed: () => ref
                  .read(readerSettingsProvider.notifier)
                  .setTranslation(show: !settings.showTranslation),
              icon: const Icon(Icons.translate),
            ),
          ),
          IconButton(
            tooltip: l10n.quranMushafMode,
            onPressed: result.valueOrNull?.ayahs.isEmpty ?? true
                ? null
                : () {
                    final ayahs = result.valueOrNull!.ayahs;
                    final target = widget.ayah;
                    final verse = target == null
                        ? ayahs.first
                        : ayahs.firstWhere(
                            (ayah) => ayah.ayah == target,
                            orElse: () => ayahs.first,
                          );
                    context.push(
                      Uri(
                        path: '/quran/page/${verse.page}',
                        queryParameters: {
                          'ayah': '${verse.surah}:${verse.ayah}',
                        },
                      ).toString(),
                    );
                  },
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          _SurahTabs(
            selected: widget.surah,
            onSelected: _openSurah,
            palette: palette,
          ),
          Expanded(
            child: result.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.quranLoadError),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(surahContentProvider(widget.surah)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (content) {
                final surah = content.surah;
                if (surah == null) {
                  return Center(child: Text(l10n.quranNotFound));
                }
                _ayahs = content.ayahs;
                _hasOpeningHeader = surah.bismillahPre == 1;
                final target = widget.ayah;
                final initialIndex = target == null
                    ? 0
                    : content.ayahs.indexWhere((verse) => verse.ayah == target);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (_) => _horizontalDrag = 0,
                  onHorizontalDragUpdate: (details) =>
                      _horizontalDrag += details.primaryDelta ?? 0,
                  onHorizontalDragEnd: _finishHorizontalDrag,
                  child: ScrollablePositionedList.builder(
                    key: Key(
                      'surah-reader-${widget.surah}-${widget.ayah ?? 1}',
                    ),
                    itemCount:
                        content.ayahs.length + (_hasOpeningHeader ? 1 : 0),
                    initialScrollIndex: initialIndex <= 0
                        ? 0
                        : initialIndex + (_hasOpeningHeader ? 1 : 0),
                    itemPositionsListener: _positions,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
                    itemBuilder: (context, index) {
                      if (_hasOpeningHeader && index == 0) {
                        return _BismillahHeader(palette: palette);
                      }
                      final verse =
                          content.ayahs[index - (_hasOpeningHeader ? 1 : 0)];
                      return _AyahCard(
                        verse: verse,
                        settings: settings,
                        palette: palette,
                        isBookmarked: bookmarked.contains(verse.id),
                        isTarget: verse.ayah == target,
                        isOpening: verse.surah == 1 && verse.ayah == 1,
                        onBookmark: () =>
                            _bookmark(verse, bookmarked.contains(verse.id)),
                        onShare: () => _share(verse, surah),
                        onCopy: () => _copy(verse),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahTabs extends ConsumerStatefulWidget {
  const _SurahTabs({
    required this.selected,
    required this.onSelected,
    required this.palette,
  });

  final int selected;
  final ValueChanged<int> onSelected;
  final QuranLibraryPalette palette;

  @override
  ConsumerState<_SurahTabs> createState() => _SurahTabsState();
}

class _SurahTabsState extends ConsumerState<_SurahTabs> {
  final GlobalKey _activeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _centerSelected();
  }

  @override
  void didUpdateWidget(covariant _SurahTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _centerSelected();
  }

  void _centerSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _activeKey.currentContext == null) return;
      Scrollable.ensureVisible(
        _activeKey.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 180),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(surahListProvider, (previous, next) {
      if (previous?.hasValue != true && next.hasValue) _centerSelected();
    });
    final surahs =
        ref.watch(surahListProvider).valueOrNull ?? const <SurahData>[];
    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: widget.palette.border)),
      ),
      child: SingleChildScrollView(
        key: const Key('surah-tabs'),
        scrollDirection: Axis.horizontal,
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            for (final surah in surahs)
              InkWell(
                key: Key('surah-tab-${surah.number}'),
                onTap: () => widget.onSelected(surah.number),
                child: Container(
                  key: surah.number == widget.selected ? _activeKey : null,
                  constraints: const BoxConstraints(minWidth: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: surah.number == widget.selected
                            ? widget.palette.gold
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.number}. ${surah.nameLatin}',
                    style: TextStyle(
                      color: surah.number == widget.selected
                          ? widget.palette.gold
                          : widget.palette.muted,
                      fontSize: 15,
                      fontWeight: surah.number == widget.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BismillahHeader extends ConsumerWidget {
  const _BismillahHeader({required this.palette});
  final QuranLibraryPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    key: const Key('surah-bismillah'),
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: ref
        .watch(surahContentProvider(1))
        .when(
          data: (content) => content.ayahs.isEmpty
              ? Text(AppLocalizations.of(context).quranLoadError)
              : _AyahGlyphText(
                  verse: content.ayahs.first,
                  palette: palette,
                  isOpening: true,
                ),
          error: (_, _) => Text(AppLocalizations.of(context).quranLoadError),
          loading: () => const SizedBox(height: 56),
        ),
  );
}

class _AyahGlyphText extends ConsumerWidget {
  const _AyahGlyphText({
    required this.verse,
    required this.palette,
    this.isOpening = false,
  });

  final AyahData verse;
  final QuranLibraryPalette palette;
  final bool isOpening;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glyph = ref.watch(
      surahAyahGlyphProvider(AyahRef(surah: verse.surah, ayah: verse.ayah)),
    );
    final data = glyph.valueOrNull;
    return Semantics(
      header: isOpening,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            data == null
                ? verse.textUthmani
                : isOpening
                ? data.openingText
                : data.text,
            key: isOpening
                ? const Key('bismillah-text')
                : Key('ayah-arabic-${verse.ayah}'),
            semanticsLabel: verse.textUthmani,
            textDirection: TextDirection.rtl,
            textAlign: isOpening ? TextAlign.center : TextAlign.right,
            style: data == null
                ? AppTheme.arabic(
                    fontSize: 34,
                    color: palette.text,
                  ).copyWith(height: 1.75)
                : TextStyle(
                    fontFamily: data.fontFamily,
                    fontSize: 34,
                    height: 1.75,
                    color: palette.text,
                  ),
          ),
          if (glyph.hasError)
            Text(
              AppLocalizations.of(context).quranGlyphUnavailable,
              style: TextStyle(color: palette.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.verse,
    required this.settings,
    required this.palette,
    required this.isBookmarked,
    required this.isTarget,
    required this.isOpening,
    required this.onBookmark,
    required this.onShare,
    required this.onCopy,
  });

  final AyahData verse;
  final ReaderSettings settings;
  final QuranLibraryPalette palette;
  final bool isBookmarked;
  final bool isTarget;
  final bool isOpening;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: Key('ayah-${verse.ayah}'),
      decoration: BoxDecoration(
        color: isTarget ? palette.gold.withValues(alpha: 0.1) : null,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: InkWell(
        onLongPress: () => _showActions(context, l10n),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AyahGlyphText(
                verse: verse,
                palette: palette,
                isOpening: isOpening,
              ),
              if (settings.showTranslation) ...[
                const SizedBox(height: 22),
                Text(
                  verse.translationId,
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 16,
                    height: 1.65,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  if (!isOpening)
                    Semantics(
                      label: l10n.quranAyahNumber(verse.ayah),
                      child: Container(
                        key: Key('ayah-number-${verse.ayah}'),
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: palette.gold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: ExcludeSemantics(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              verse.ayah.toString(),
                              style: TextStyle(
                                color: palette.gold,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: isBookmarked
                        ? l10n.quranRemoveBookmark
                        : l10n.quranBookmark,
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: palette.gold,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.quranShare,
                    onPressed: onShare,
                    icon: Icon(Icons.share_outlined, color: palette.muted),
                  ),
                  IconButton(
                    tooltip: l10n.quranCopy,
                    onPressed: onCopy,
                    icon: Icon(Icons.copy_outlined, color: palette.muted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    AppLocalizations l10n,
  ) => showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      void choose(VoidCallback action) {
        Navigator.of(sheetContext).pop();
        action();
      }

      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              ),
              title: Text(
                isBookmarked ? l10n.quranRemoveBookmark : l10n.quranBookmark,
              ),
              onTap: () => choose(onBookmark),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.quranShare),
              onTap: () => choose(onShare),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(l10n.quranCopy),
              onTap: () => choose(onCopy),
            ),
          ],
        ),
      );
    },
  );
}
