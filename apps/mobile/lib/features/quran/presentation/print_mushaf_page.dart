import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/features/quran/data/mushaf_print_data.dart';
import 'package:hafidz_app/features/quran/domain/ayah_range.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/features/quran/presentation/reader_controller.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

final AutoDisposeFutureProviderFamily<PrintPage, int> printPageProvider =
    FutureProvider.autoDispose.family<PrintPage, int>(
      (ref, page) {
        final databases = ref.watch(localDatabasesProvider);
        return loadPrintPage(
          databases.quran,
          page,
          packDirectory: databases.printAssets,
        );
      },
    );

/// Local device proof for the pinned QPC V1 line and word exports.
class PrintMushafPage extends ConsumerWidget {
  const PrintMushafPage({required this.page, super.key});

  final int page;

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    AyahRef ayah,
  ) async {
    ref
        .read(readerControllerProvider.notifier)
        .highlight(
          AyahRange(start: ayah, end: ayah),
        );
    final verse = await ref.read(quranRepositoryProvider).ayahByKey(ayah);
    if (!context.mounted || verse == null) return;
    final l10n = AppLocalizations.of(context);
    var showTranslation = false;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.quranAyahTitle(ayah.key),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    key: const Key('mushaf-translation-option'),
                    leading: const Icon(Icons.translate),
                    title: Text(l10n.quranShowTranslation),
                    trailing: Icon(
                      showTranslation
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () => setSheetState(
                      () => showTranslation = !showTranslation,
                    ),
                  ),
                  ListTile(
                    key: const Key('mushaf-bookmark-option'),
                    leading: const Icon(Icons.bookmark_add_outlined),
                    title: Text(l10n.quranBookmark),
                    onTap: () async {
                      await ref.read(bookmarkRepositoryProvider).save(ayah);
                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.quranBookmarkSaved)),
                        );
                      }
                    },
                  ),
                  if (showTranslation) ...[
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        verse.textUthmani,
                        style: const TextStyle(
                          fontFamily: 'Me Quran',
                          fontSize: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(verse.translationId),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        IconButton(
                          tooltip: l10n.quranCopy,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: verse.textUthmani),
                            );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          icon: const Icon(Icons.copy_outlined),
                        ),
                        IconButton(
                          tooltip: l10n.quranShare,
                          onPressed: () async {
                            final box =
                                sheetContext.findRenderObject()! as RenderBox;
                            await SharePlus.instance.share(
                              ShareParams(
                                text:
                                    '${ayah.key}\n${verse.textUthmani}\n${verse.translationId}',
                                sharePositionOrigin:
                                    box.localToGlobal(Offset.zero) & box.size,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printPageProvider(page));
    final highlight = ref.watch(readerControllerProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(printPageProvider(page)),
          child: Text(AppLocalizations.of(context).quranPrintPackUnavailable),
        ),
      ),
      data: (source) => LayoutBuilder(
        builder: (context, constraints) {
          const printWidth = 660.0;
          const printHeight = 840.0;
          final scale = (constraints.maxWidth / printWidth).clamp(
            0.0,
            constraints.maxHeight / printHeight,
          );
          if (scale == 0) return const SizedBox.shrink();
          // Keep every QPC glyph at its source aspect ratio. On tall phones,
          // use the extra height as line leading instead of shrinking the page
          // into the top portion of the viewport.
          final fittedHeight = constraints.maxHeight / scale;
          final lineHeight = source.lines.length == 15
              ? fittedHeight / source.lines.length
              : 64.0;
          return InteractiveViewer(
            maxScale: 3,
            constrained: false,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: printWidth * scale,
              height: fittedHeight * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: printWidth,
                  height: fittedHeight,
                  child: ColoredBox(
                    color: const Color(0xFFFCFAF2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          for (final line in source.lines)
                            SizedBox(
                              key: Key('mushaf-line-$page-${line.number}'),
                              height: lineHeight,
                              child: _PrintLineView(
                                page: page,
                                line: line,
                                selected: (ayah) =>
                                    highlight?.range.contains(ayah) ?? false,
                                onTap: (ayah) => _select(context, ref, ayah),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PrintLineView extends StatelessWidget {
  const _PrintLineView({
    required this.page,
    required this.line,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final PrintLine line;
  final bool Function(AyahRef) selected;
  final ValueChanged<AyahRef> onTap;

  @override
  Widget build(BuildContext context) {
    if (line.kind == 'surah_name') {
      return OverflowBox(
        minWidth: 660,
        maxWidth: 660,
        child: SizedBox(
          width: 660,
          height: 55,
          child: Image.memory(line.headingPng!, fit: BoxFit.fill),
        ),
      );
    }
    if (line.kind == 'basmallah') {
      return const Center(
        child: Text(
          '﷽',
          style: TextStyle(fontFamily: 'QPCCommon', fontSize: 36),
        ),
      );
    }
    final wordStyle = TextStyle(
      fontFamily: 'QPCPage$page',
      fontSize: 42,
      height: 1,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          if (line.words.any((word) => selected(word.ref)))
            Positioned.fill(
              child: CustomPaint(
                key: Key('mushaf-ayah-highlight-$page-${line.number}'),
                painter: _AyahLineHighlight(
                  words: line.words,
                  selected: selected,
                  centered: line.centered,
                  style: wordStyle,
                ),
              ),
            ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: line.centered
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                for (final word in line.words)
                  Semantics(
                    button: true,
                    label: 'Ayah ${word.ref.key}',
                    child: GestureDetector(
                      key: Key('mushaf-word-$page-${word.id}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(word.ref),
                      onLongPress: () => onTap(word.ref),
                      child: Text(
                        word.glyph,
                        textDirection: TextDirection.rtl,
                        style: wordStyle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahLineHighlight extends CustomPainter {
  const _AyahLineHighlight({
    required this.words,
    required this.selected,
    required this.centered,
    required this.style,
  });

  final List<PrintWord> words;
  final bool Function(AyahRef) selected;
  final bool centered;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    if (words.isEmpty || !words.any((word) => selected(word.ref))) return;
    final widths = <double>[];
    var textHeight = 0.0;
    for (final word in words) {
      final text = TextPainter(
        text: TextSpan(text: word.glyph, style: style),
        textDirection: TextDirection.rtl,
      )..layout();
      widths.add(text.width);
      textHeight = text.height > textHeight ? text.height : textHeight;
      text.dispose();
    }
    final total = widths.fold<double>(0, (sum, width) => sum + width);
    final gap = centered || words.length == 1
        ? 0.0
        : (size.width - total) / (words.length - 1);
    var right = centered ? (size.width + total) / 2 : size.width;
    double? runRight;
    double? runLeft;
    final paint = Paint()..color = const Color(0x55B3945B);
    void drawRun() {
      if (runLeft == null || runRight == null) return;
      final top = (size.height - textHeight) / 2;
      canvas.drawRect(
        Rect.fromLTRB(runLeft!, top, runRight!, top + textHeight),
        paint,
      );
      runRight = null;
      runLeft = null;
    }

    for (var index = 0; index < words.length; index++) {
      final left = right - widths[index];
      if (selected(words[index].ref)) {
        runRight ??= right;
        runLeft = left;
      } else {
        drawRun();
      }
      right = left - gap;
    }
    drawRun();
  }

  @override
  bool shouldRepaint(covariant _AyahLineHighlight oldDelegate) => true;
}
