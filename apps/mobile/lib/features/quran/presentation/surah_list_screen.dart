import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/theme/app_colors.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/features/quran/presentation/quran_library_palette.dart';
import 'package:hafidz_app/features/quran/presentation/surah_chooser_dialog.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

final surahListProvider = FutureProvider<List<SurahData>>(
  (ref) => ref.read(quranRepositoryProvider).surahs(),
);

/// Juz navigation uses the QUL database's canonical first ayah mapping.
final juzStartPagesProvider = FutureProvider<List<int?>>((ref) {
  final repository = ref.read(quranRepositoryProvider);
  return Future.wait([
    for (var number = 1; number <= 30; number++)
      repository.firstPageOfJuz(number),
  ]);
});

enum _LibraryTab { surah, juz }

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  _LibraryTab _tab = _LibraryTab.surah;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectTab(_LibraryTab tab) {
    if (_tab == tab) return;
    _searchFocus.unfocus();
    _searchController.clear();
    setState(() {
      _tab = tab;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = QuranLibraryPalette.from(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                _header(l10n, palette),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: TextField(
                    key: const Key('surah-search'),
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: (value) => setState(() => _query = value),
                    style: TextStyle(color: palette.text),
                    decoration: InputDecoration(
                      hintText: _tab == _LibraryTab.surah
                          ? l10n.quranSearchHint
                          : l10n.quranSearchJuzHint,
                      hintStyle: TextStyle(color: palette.muted),
                      prefixIcon: Icon(Icons.search, color: palette.muted),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.quranClearSearch,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: Icon(Icons.close, color: palette.muted),
                            ),
                      filled: true,
                      fillColor: palette.card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: palette.border),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _tab == _LibraryTab.surah
                      ? _surahList(l10n, palette)
                      : _juzList(l10n, palette),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, QuranLibraryPalette palette) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: l10n.quranBrand,
                children: [
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: palette.gold),
                  ),
                ],
              ),
              style: TextStyle(
                color: palette.text,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.quranHeaderBismillah,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabic(
                    fontSize: 20,
                    color: palette.gold,
                  ).copyWith(height: 1.1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: palette.teal.withValues(alpha: 0.12),
                border: Border.all(
                  color: palette.teal.withValues(alpha: 0.45),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.menu_book_outlined, color: palette.teal),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quranTitle,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.quranLibrarySubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              tooltip: l10n.quranSearchAction,
              onPressed: _searchFocus.requestFocus,
              icon: Icon(Icons.search, color: palette.text),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          key: const Key('quran-library-tabs'),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: palette.card,
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _tabButton(
                _LibraryTab.surah,
                l10n.quranSurahTab,
                Icons.menu_book_outlined,
                palette,
              ),
              _tabButton(
                _LibraryTab.juz,
                l10n.quranJuzTab,
                Icons.layers_outlined,
                palette,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _tabButton(
    _LibraryTab tab,
    String label,
    IconData icon,
    QuranLibraryPalette palette,
  ) {
    final selected = _tab == tab;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          key: Key('library-tab-${tab.name}'),
          onTap: () => _selectTab(tab),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 43,
            decoration: BoxDecoration(
              color: selected ? AppColors.libraryTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected ? Colors.white : palette.muted,
                ),
                const SizedBox(width: 7),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: selected ? Colors.white : palette.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _surahList(AppLocalizations l10n, QuranLibraryPalette palette) => ref
      .watch(surahListProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _loadError(
          l10n,
          () => ref.invalidate(surahListProvider),
        ),
        data: (items) {
          final query = _query.trim().toLowerCase();
          final filtered = items.where((surah) {
            if (query.isEmpty) return true;
            return surah.number.toString().startsWith(query) ||
                surah.nameLatin.toLowerCase().contains(query) ||
                surah.nameArabic.contains(query);
          }).toList();
          if (filtered.isEmpty) {
            return _empty(l10n.quranSearchEmpty, palette);
          }
          return ListView.separated(
            key: const Key('surah-list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              thickness: 1,
              color: palette.border,
            ),
            itemBuilder: (context, index) {
              final surah = filtered[index];
              final origin = surah.revelationPlace == 'madinah'
                  ? l10n.revelationMadinah
                  : l10n.revelationMakkah;
              return InkWell(
                key: Key('surah-${surah.number}'),
                onTap: () => showSurahChooser(context, surah),
                child: SizedBox(
                  height: 75,
                  child: Row(
                    children: [
                      _medallion(surah.number.toString(), palette),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.nameLatin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.quranAyahCount(surah.ayahCount)} · $origin',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            surah.nameArabic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.arabic(
                              fontSize: 24,
                              color: palette.gold,
                            ).copyWith(height: 1.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

  Widget _juzList(AppLocalizations l10n, QuranLibraryPalette palette) => ref
      .watch(juzStartPagesProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _loadError(
          l10n,
          () => ref.invalidate(juzStartPagesProvider),
        ),
        data: (pages) {
          final query = _query.trim().toLowerCase();
          final numbers = [
            for (var number = 1; number <= 30; number++)
              if (query.isEmpty ||
                  number.toString().startsWith(query) ||
                  l10n.quranJuzNumber(number).toLowerCase().contains(query))
                number,
          ];
          if (numbers.isEmpty) return _empty(l10n.quranJuzEmpty, palette);
          return ListView.separated(
            key: const Key('juz-list'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: numbers.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              thickness: 1,
              color: palette.border,
            ),
            itemBuilder: (context, index) {
              final number = numbers[index];
              final page = pages[number - 1];
              return InkWell(
                key: Key('juz-$number'),
                onTap: () {
                  if (page == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.quranJuzUnavailable)),
                    );
                    return;
                  }
                  context.push('/quran/page/$page');
                },
                child: SizedBox(
                  height: 75,
                  child: Row(
                    children: [
                      _medallion(number.toString(), palette),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.quranJuzNumber(number),
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              page == null
                                  ? l10n.quranJuzUnavailable
                                  : l10n.quranPageTitle(page),
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: palette.muted),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

  Widget _medallion(String number, QuranLibraryPalette palette) {
    final edge = palette.teal.withValues(alpha: 0.55);
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(border: Border.all(color: edge)),
            ),
          ),
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(border: Border.all(color: edge)),
          ),
          Container(
            width: 23,
            height: 23,
            color: palette.background,
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: palette.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String label, QuranLibraryPalette palette) => Center(
    child: Text(label, style: TextStyle(color: palette.muted)),
  );

  Widget _loadError(AppLocalizations l10n, VoidCallback retry) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.quranLoadError),
        TextButton(onPressed: retry, child: Text(l10n.retry)),
      ],
    ),
  );
}
