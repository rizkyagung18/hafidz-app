import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/features/quran/data/reader_settings_repository.dart';
import 'package:hafidz_app/features/quran/domain/reader_settings.dart';

final readerSettingsRepositoryProvider = Provider<ReaderSettingsRepository>(
  (ref) => ReaderSettingsRepository(ref.watch(localDatabasesProvider).user),
);

final readerSettingsProvider =
    AsyncNotifierProvider<ReaderSettingsController, ReaderSettings>(
      ReaderSettingsController.new,
    );

class ReaderSettingsController extends AsyncNotifier<ReaderSettings> {
  @override
  Future<ReaderSettings> build() =>
      ref.read(readerSettingsRepositoryProvider).load();

  Future<void> setLatin({required bool show}) => _update(
    (current) => current.copyWith(showLatin: show),
  );

  Future<void> setTranslation({required bool show}) => _update(
    (current) => current.copyWith(showTranslation: show),
  );

  Future<void> _update(ReaderSettings Function(ReaderSettings) change) async {
    final previous = state.valueOrNull ?? await future;
    final next = change(previous);
    state = AsyncData(next);
    try {
      await ref.read(readerSettingsRepositoryProvider).save(next);
    } on Exception catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
