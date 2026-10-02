import 'package:drift/drift.dart';
import 'package:hafidz_app/core/database/user_database.dart';
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

enum ReadingMode { mushaf, list }

/// One last-read position, with page derived from the Quran database.
class ReadingRepository {
  const ReadingRepository(this._userDb, this._quran);

  final UserDatabase _userDb;
  final QuranRepository _quran;

  Future<ReadingPositionData?> current() => (_userDb.select(
    _userDb.readingPosition,
  )..where((row) => row.id.equals(1))).getSingleOrNull();

  Future<ReadingPositionData> save(
    AyahRef ref, {
    required ReadingMode mode,
  }) async {
    final ayah = await _quran.ayahByKey(ref);
    if (ayah == null) throw ArgumentError.value(ref.key, 'ref');
    final timestamp = DateTime.now().toUtc().toIso8601String();
    await _userDb
        .into(_userDb.readingPosition)
        .insertOnConflictUpdate(
          ReadingPositionCompanion.insert(
            id: const Value(1),
            ayahId: ayah.id,
            page: ayah.page,
            mode: mode.name,
            updatedAt: timestamp,
          ),
        );
    return (await current())!;
  }
}
