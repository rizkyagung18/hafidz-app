import 'package:drift/drift.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

/// Offline queries over the immutable content database.
class QuranRepository {
  const QuranRepository(this._db);

  final QuranDatabase _db;

  Future<List<SurahData>> surahs() => (_db.select(
    _db.surah,
  )..orderBy([(s) => OrderingTerm.asc(s.number)])).get();

  Future<SurahData?> surahByNumber(int number) => (_db.select(
    _db.surah,
  )..where((s) => s.number.equals(number))).getSingleOrNull();

  Future<List<AyahData>> ayahsInSurah(int number) =>
      (_db.select(_db.ayah)
            ..where((a) => a.surah.equals(number))
            ..orderBy([(a) => OrderingTerm.asc(a.ayah)]))
          .get();

  Future<AyahData?> ayahByKey(AyahRef ref) =>
      (_db.select(_db.ayah)
            ..where((a) => a.surah.equals(ref.surah) & a.ayah.equals(ref.ayah)))
          .getSingleOrNull();

  Future<int?> pageOf(AyahRef ref) async => (await ayahByKey(ref))?.page;

  Future<int?> firstPageOfJuz(int number) async {
    final juz = await (_db.select(
      _db.juz,
    )..where((row) => row.number.equals(number))).getSingleOrNull();
    if (juz == null) return null;
    final first = await (_db.select(
      _db.ayah,
    )..where((row) => row.id.equals(juz.firstAyah))).getSingleOrNull();
    return first?.page;
  }

  Future<TafsirData?> tafsir(AyahRef ref, {String source = 'kemenag'}) async {
    final ayah = await ayahByKey(ref);
    if (ayah == null) return null;
    return (_db.select(_db.tafsir)..where(
          (row) => row.ayahId.equals(ayah.id) & row.source.equals(source),
        ))
        .getSingleOrNull();
  }

  Future<List<AyahData>> page(int number) =>
      (_db.select(_db.ayah)
            ..where((a) => a.page.equals(number))
            ..orderBy([(a) => OrderingTerm.asc(a.id)]))
          .get();

  Future<List<AyahData>> juz(int number) =>
      (_db.select(_db.ayah)
            ..where((a) => a.juz.equals(number))
            ..orderBy([(a) => OrderingTerm.asc(a.id)]))
          .get();

  /// FTS only reads `text_norm`; display text always comes from `ayah`.
  Future<List<AyahData>> search(String query, {int limit = 20}) async {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    final words = _searchWords(query);
    if (words.isEmpty) return [];
    final match = words.map((word) => '"$word"').join(' AND ');
    final rows = await _db
        .customSelect(
          'SELECT a.* FROM ayah AS a '
          'JOIN ayah_fts ON ayah_fts.rowid = a.id '
          'WHERE ayah_fts MATCH ? ORDER BY bm25(ayah_fts), a.id LIMIT ?',
          variables: [Variable<String>(match), Variable<int>(limit)],
          readsFrom: {_db.ayah, _db.ayahFts},
        )
        .get();
    return rows.map((row) => _db.ayah.map(row.data)).toList();
  }

  List<String> _searchWords(String query) {
    // Match the stored Arabic search index without touching display strings.
    final normalized = query
        .replaceAll(
          RegExp(
            r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF\u0640]',
          ),
          '',
        )
        .replaceAll(RegExp('[آأإٱٲٳ]'), 'ا')
        .replaceAll(RegExp('[ىیئ]'), 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ة', 'ه')
        .replaceAll('ک', 'ك')
        .replaceAll('ء', '');
    return RegExp(
      r'[\p{L}\p{N}]+',
      unicode: true,
    ).allMatches(normalized).map((match) => match.group(0)!).toList();
  }
}
