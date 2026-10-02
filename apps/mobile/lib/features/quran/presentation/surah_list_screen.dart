import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

final surahListProvider = FutureProvider<List<SurahData>>(
  (ref) => ref.read(quranRepositoryProvider).surahs(),
);

class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  void _showSurahChoices(BuildContext context, SurahData surah) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${l10n.quranChooseReader}: ${surah.nameLatin}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(l10n.quranMushafMode),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/quran/page/${surah.firstPage}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: Text(l10n.quranTranslationReader),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/quran/surah/${surah.number}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.headphones_outlined),
                title: Text(l10n.quranMurattal),
                subtitle: Text(l10n.comingSoon),
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quranTitle),
        actions: [
          IconButton(
            tooltip: l10n.quranMushafMode,
            onPressed: () => context.push('/quran/page/1'),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: surahs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.quranLoadError),
              TextButton(
                onPressed: () => ref.invalidate(surahListProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (items) => ListView.builder(
          key: const Key('surah-list'),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final surah = items[index];
            final place = surah.revelationPlace == 'makkah'
                ? l10n.revelationMakkah
                : l10n.revelationMadinah;
            return Card(
              key: Key('surah-${surah.number}'),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text('${surah.number}'),
                ),
                title: Text(surah.nameLatin),
                subtitle: Text('${l10n.quranAyahCount(surah.ayahCount)} · $place'),
                trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      surah.nameArabic,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.arabic(fontSize: 24),
                    ),
                  ),
                ),
                onTap: () => _showSurahChoices(context, surah),
              ),
            );
          },
        ),
      ),
    );
  }
}
