import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';

final FutureProviderFamily<AyahData?, String> ayahLinkProvider =
    FutureProvider.family<AyahData?, String>((
      ref,
      key,
    ) async {
      try {
        return await ref
            .read(quranRepositoryProvider)
            .ayahByKey(
              AyahRef.parse(key),
            );
      } on FormatException {
        return null;
      }
    });

/// Resolves canonical ayah links through the offline page metadata.
class QuranAyahScreen extends ConsumerWidget {
  const QuranAyahScreen({required this.keyRef, super.key});

  final String keyRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ayah = ref.watch(ayahLinkProvider(keyRef));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quranAyahTitle(keyRef))),
      body: ayah.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.quranLoadError)),
        data: (value) {
          if (value == null) {
            return Center(child: Text(l10n.quranAyahNotFound));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.go(
              Uri(
                path: '/quran/page/${value.page}',
                queryParameters: {'ayah': keyRef, 'hl': '1'},
              ).toString(),
            );
          });
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
