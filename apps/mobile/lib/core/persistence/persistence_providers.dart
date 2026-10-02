import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafidz_app/core/database/local_databases.dart';
import 'package:hafidz_app/features/quran/data/bookmark_repository.dart';
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central provider for [SharedPreferences].
/// Must be overridden in the [ProviderScope] at app startup.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Opened once before app startup; tests override it with in-memory databases.
final localDatabasesProvider = Provider<LocalDatabases>((ref) {
  throw UnimplementedError('localDatabasesProvider must be overridden');
});

final quranRepositoryProvider = Provider<QuranRepository>(
  (ref) => QuranRepository(ref.watch(localDatabasesProvider).quran),
);

final bookmarkRepositoryProvider = Provider<BookmarkRepository>(
  (ref) => BookmarkRepository(
    ref.watch(localDatabasesProvider).user,
    ref.watch(quranRepositoryProvider),
  ),
);

final readingRepositoryProvider = Provider<ReadingRepository>(
  (ref) => ReadingRepository(
    ref.watch(localDatabasesProvider).user,
    ref.watch(quranRepositoryProvider),
  ),
);
