import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/features/quran/domain/reader_settings.dart';
import 'package:hafidz_app/features/quran/presentation/reader_settings_controller.dart';
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

class QuranSurahScreen extends ConsumerStatefulWidget {
  const QuranSurahScreen({required this.surah, this.ayah, super.key});

  final int surah;
  final int? ayah;

  @override
  ConsumerState<QuranSurahScreen> createState() => _QuranSurahScreenState();
}

class _QuranSurahScreenState extends ConsumerState<QuranSurahScreen> {
  final _positions = ItemPositionsListener.create();
  Timer? _saveTimer;
  List<AyahData> _ayahs = const [];
  int? _visibleAyah;

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
    final index = visible
        .map((position) => position.index)
        .reduce(
          (a, b) => a < b ? a : b,
        );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          result.valueOrNull?.surah?.nameLatin ??
              l10n.quranSurahTitle(widget.surah),
        ),
        actions: [
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
      body: result.when(
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
          if (surah == null) return Center(child: Text(l10n.quranNotFound));
          _ayahs = content.ayahs;
          final target = widget.ayah;
          final initialIndex = target == null
              ? 0
              : content.ayahs.indexWhere((verse) => verse.ayah == target);
          return Column(
            children: [
              _SurahHeader(surah: surah),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text(l10n.quranShowTranslation),
                      selected: settings.showTranslation,
                      onSelected: (value) => ref
                          .read(readerSettingsProvider.notifier)
                          .setTranslation(show: value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ScrollablePositionedList.builder(
                  key: Key('surah-reader-${widget.surah}-${widget.ayah ?? 1}'),
                  itemCount: content.ayahs.length,
                  initialScrollIndex: initialIndex < 0 ? 0 : initialIndex,
                  itemPositionsListener: _positions,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                  itemBuilder: (context, index) {
                    final verse = content.ayahs[index];
                    return _AyahCard(
                      verse: verse,
                      settings: settings,
                      isBookmarked: bookmarked.contains(verse.id),
                      isTarget: verse.ayah == target,
                      onPlay: () => _message(l10n.quranAudioUnavailable),
                      onBookmark: () => _bookmark(
                        verse,
                        bookmarked.contains(verse.id),
                      ),
                      onShare: () => _share(verse, surah),
                      onCopy: () => _copy(verse),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final SurahData surah;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final place = surah.revelationPlace == 'makkah'
        ? l10n.revelationMakkah
        : l10n.revelationMadinah;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(surah.nameArabic, style: AppTheme.arabic()),
          ),
          Text(
            '${surah.nameLatin} · ${l10n.quranAyahCount(surah.ayahCount)} · $place',
            textAlign: TextAlign.center,
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
    required this.isBookmarked,
    required this.isTarget,
    required this.onPlay,
    required this.onBookmark,
    required this.onShare,
    required this.onCopy,
  });

  final AyahData verse;
  final ReaderSettings settings;
  final bool isBookmarked;
  final bool isTarget;
  final VoidCallback onPlay;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      key: Key('ayah-${verse.ayah}'),
      color: isTarget ? colors.primary.withValues(alpha: 0.08) : null,
      child: InkWell(
        onLongPress: () => _showActions(context, l10n),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.quranAyahNumber(verse.ayah),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  verse.textUthmani,
                  textAlign: TextAlign.right,
                  style: AppTheme.arabic(),
                ),
              ),
              if (settings.showTranslation) ...[
                const SizedBox(height: 12),
                Text(verse.translationId),
              ],
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                children: [
                  IconButton(
                    tooltip: l10n.quranPlayAyah,
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_arrow_outlined),
                  ),
                  IconButton(
                    tooltip: isBookmarked
                        ? l10n.quranRemoveBookmark
                        : l10n.quranBookmark,
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.quranShare,
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.quranCopy,
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined),
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
              leading: const Icon(Icons.play_arrow_outlined),
              title: Text(l10n.quranPlayAyah),
              onTap: () => choose(onPlay),
            ),
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
