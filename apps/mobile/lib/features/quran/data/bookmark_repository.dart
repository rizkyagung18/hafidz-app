import 'package:drift/drift.dart';
import 'package:hafidz_app/core/database/user_database.dart';
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

/// User bookmarks keyed by ayah and folder.
class BookmarkRepository {
  const BookmarkRepository(this._userDb, this._quran);

  final UserDatabase _userDb;
  final QuranRepository _quran;

  Future<List<BookmarkData>> all({String? folder}) =>
      (_userDb.select(_userDb.bookmark)
            ..where(
              (row) => folder == null
                  ? const Constant(true)
                  : row.folder.equals(folder),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
          .get();

  Future<BookmarkData> save(
    AyahRef ref, {
    String folder = 'default',
    String? note,
    String? color,
  }) async {
    if (folder.trim().isEmpty) throw ArgumentError.value(folder, 'folder');
    final ayah = await _quran.ayahByKey(ref);
    if (ayah == null) throw ArgumentError.value(ref.key, 'ref');
    final now = DateTime.now().toUtc().toIso8601String();
    await _userDb.customStatement(
      'INSERT INTO bookmark '
      '(ayah_id, folder, note, color, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(ayah_id, folder) DO UPDATE SET '
      'note=excluded.note, color=excluded.color, updated_at=excluded.updated_at',
      [ayah.id, folder, note, color, now, now],
    );
    return (_userDb.select(_userDb.bookmark)..where(
          (row) => row.ayahId.equals(ayah.id) & row.folder.equals(folder),
        ))
        .getSingle();
  }

  Future<void> remove(AyahRef ref, {String folder = 'default'}) async {
    final ayah = await _quran.ayahByKey(ref);
    if (ayah == null) return;
    await (_userDb.delete(_userDb.bookmark)..where(
          (row) => row.ayahId.equals(ayah.id) & row.folder.equals(folder),
        ))
        .go();
  }
}
