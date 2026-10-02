import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafidz_app/core/database/local_databases.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/database/user_database.dart';
import 'package:hafidz_app/features/quran/data/bookmark_repository.dart';
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

class _BrokenUpdateBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => rootBundle.load(key);

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (key == 'assets/db/quran.sqlite.sha256') {
      return Future.value('${List.filled(64, '0').join()}  quran.sqlite\n');
    }
    return rootBundle.loadString(key, cache: cache);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Tests deliberately create several independent in-memory connections.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late QuranDatabase quranDb;
  late UserDatabase userDb;
  late QuranRepository quran;

  setUp(() async {
    quranDb = QuranDatabase(NativeDatabase.memory());
    userDb = UserDatabase(NativeDatabase.memory());
    quran = QuranRepository(quranDb);
    await quranDb.customStatement(
      '''
      INSERT INTO surah (number, name_arabic, name_latin, translation_id,
      translation_en, ayah_count, revelation_place, first_page)
      VALUES (2, 'البقرة', 'Al-Baqarah', 'Sapi Betina', 'The Cow', 2, 'madinah', 2)''',
    );
    await quranDb.customStatement(
      '''
      INSERT INTO ayah (id, surah, ayah, page, juz, hizb, hizb_quarter,
      text_uthmani, text_simple, text_norm, translation_id) VALUES
      (1, 2, 255, 42, 3, 5, 17, 'ٱللَّهُ لَآ إِلَٰهَ', 'الله لا إله', 'الله لا اله', 'Allah'),
      (2, 2, 256, 42, 3, 5, 17, 'لَآ إِكْرَاهَ', 'لا إكراه', 'لا اكراه', 'Tidak ada paksaan')''',
    );
    await quranDb.customStatement(
      "INSERT INTO ayah_fts(ayah_fts) VALUES ('rebuild')",
    );
  });

  tearDown(() async {
    await quranDb.close();
    await userDb.close();
  });

  test('AyahRef parses canonical keys', () {
    expect(AyahRef.parse('2:255').key, '2:255');
    expect(() => AyahRef.parse('2:0'), throwsFormatException);
    expect(() => AyahRef.parse('2:255:1'), throwsFormatException);
  });

  test('Quran repository reads surahs, ayah, page, juz and FTS', () async {
    const ref = AyahRef(surah: 2, ayah: 255);
    expect((await quran.surahs()).single.nameLatin, 'Al-Baqarah');
    expect(await quran.pageOf(ref), 42);
    expect((await quran.ayahByKey(ref))?.textUthmani, 'ٱللَّهُ لَآ إِلَٰهَ');
    expect((await quran.page(42)).map((a) => a.ayah), [255, 256]);
    expect((await quran.juz(3)).length, 2);
    expect((await quran.search('إِلَٰهَ')).single.ayah, 255);
    expect((await quran.search('paksaan')).single.ayah, 256);
    expect(await quran.search('" OR *'), isEmpty);
    expect(await quran.pageOf(const AyahRef(surah: 2, ayah: 999)), isNull);
  });

  test('bookmarks upsert per folder, keep created time and delete', () async {
    const ref = AyahRef(surah: 2, ayah: 255);
    final bookmarks = BookmarkRepository(userDb, quran);
    final first = await bookmarks.save(ref, note: 'Memorize');
    final updated = await bookmarks.save(ref, note: 'Review');
    expect(updated.id, first.id);
    expect(updated.createdAt, first.createdAt);
    expect(updated.note, 'Review');
    await bookmarks.save(ref, folder: 'favorites');
    expect((await bookmarks.all()).length, 2);
    expect(
      (await bookmarks.all(folder: 'favorites')).single.folder,
      'favorites',
    );
    await bookmarks.remove(ref);
    expect((await bookmarks.all()).single.folder, 'favorites');
    expect(
      () => bookmarks.save(const AyahRef(surah: 2, ayah: 999)),
      throwsArgumentError,
    );
  });

  test('reading position stays single-row and derives correct page', () async {
    final reading = ReadingRepository(userDb, quran);
    expect(await reading.current(), isNull);
    final first = await reading.save(
      const AyahRef(surah: 2, ayah: 255),
      mode: ReadingMode.mushaf,
    );
    expect(first.page, 42);
    expect(first.mode, 'mushaf');
    final latest = await reading.save(
      const AyahRef(surah: 2, ayah: 256),
      mode: ReadingMode.list,
    );
    expect(latest.id, 1);
    expect(latest.ayahId, 2);
    expect(latest.mode, 'list');
    expect((await userDb.select(userDb.readingPosition).get()).length, 1);
  });

  test(
    'bundled database installs, reopens and enforces read-only queries',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'hafidz-db-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final first = await openLocalDatabases(
        assets: rootBundle,
        supportDirectory: directory,
      );
      expect(
        await QuranRepository(first.quran).pageOf(
          const AyahRef(surah: 2, ayah: 255),
        ),
        42,
      );
      expect((await first.quran.select(first.quran.surah).get()).length, 114);
      await BookmarkRepository(first.user, QuranRepository(first.quran)).save(
        const AyahRef(surah: 2, ayah: 255),
        note: 'Keep after content update',
      );
      await ReadingRepository(
        first.user,
        QuranRepository(first.quran),
      ).save(const AyahRef(surah: 2, ayah: 255), mode: ReadingMode.mushaf);
      await first.user.customStatement(
        'INSERT INTO khatam_plan(started_at,target_days,pages_read_json) '
        "VALUES ('2026-10-01',30,'[1,42]')",
      );
      await first.user.customStatement(
        "INSERT INTO kv_setting(key,value) VALUES ('reader_theme','sepia')",
      );
      expect(
        () => first.quran.customStatement(
          "UPDATE ayah SET text_uthmani = 'changed' WHERE id = 1",
        ),
        throwsA(isA<Exception>()),
      );
      await first.close();

      // Simulate a v1 content install. The v3 asset must replace it while the
      // separate user.sqlite keeps the canonical bookmark.
      final outdated = QuranDatabase(
        NativeDatabase(
          File('${directory.path}/quran.sqlite'),
          enableMigrations: false,
        ),
      );
      await outdated.customStatement('PRAGMA user_version = 1');
      await outdated.customStatement(
        "UPDATE meta SET value = '1' WHERE key = 'db_version'",
      );
      await outdated.close();

      final second = await openLocalDatabases(
        assets: rootBundle,
        supportDirectory: directory,
      );
      expect(
        await QuranRepository(second.quran).pageOf(
          const AyahRef(surah: 2, ayah: 255),
        ),
        42,
      );
      expect(
        (await BookmarkRepository(
          second.user,
          QuranRepository(second.quran),
        ).all()).single.note,
        'Keep after content update',
      );
      expect(
        (await ReadingRepository(
          second.user,
          QuranRepository(second.quran),
        ).current())?.ayahId,
        262,
      );
      expect(
        (await second.user
                .customSelect(
                  'SELECT pages_read_json FROM khatam_plan',
                )
                .getSingle())
            .read<String>('pages_read_json'),
        '[1,42]',
      );
      expect(
        (await second.user
                .customSelect(
                  "SELECT value FROM kv_setting WHERE key='reader_theme'",
                )
                .getSingle())
            .read<String>('value'),
        'sepia',
      );
      await second.close();

      // A damaged copy is also replaced without touching user.sqlite.
      await File('${directory.path}/quran.sqlite').writeAsString('damaged');
      final third = await openLocalDatabases(
        assets: rootBundle,
        supportDirectory: directory,
      );
      expect(
        (await BookmarkRepository(
          third.user,
          QuranRepository(third.quran),
        ).all()).single.note,
        'Keep after content update',
      );
      await third.close();
    },
  );

  test('failed v3 update reuses the verified local print package', () async {
    final directory = await Directory.systemTemp.createTemp(
      'hafidz-db-fallback-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final first = await openLocalDatabases(
      assets: rootBundle,
      supportDirectory: directory,
    );
    await BookmarkRepository(first.user, QuranRepository(first.quran)).save(
      const AyahRef(surah: 2, ayah: 255),
      note: 'Keep through failure',
    );
    await first.close();

    final fallback = await openLocalDatabases(
      assets: _BrokenUpdateBundle(),
      supportDirectory: directory,
    );
    expect(fallback.printAssets, isNotNull);
    expect(
      (await BookmarkRepository(
        fallback.user,
        QuranRepository(fallback.quran),
      ).all()).single.note,
      'Keep through failure',
    );
    await fallback.close();
  });

  test('failed first v2 to v3 update preserves legacy files', () async {
    final directory = await Directory.systemTemp.createTemp(
      'hafidz-db-legacy-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final legacy = File('${directory.path}/quran.sqlite');
    final bundled = await rootBundle.load('assets/db/quran.sqlite');
    await legacy.writeAsBytes(
      bundled.buffer.asUint8List(bundled.offsetInBytes, bundled.lengthInBytes),
    );
    final oldDb = QuranDatabase(
      NativeDatabase(legacy, enableMigrations: false),
    );
    await oldDb.customStatement('PRAGMA user_version = 2');
    await oldDb.customStatement(
      "UPDATE meta SET value = '2' WHERE key='db_version'",
    );
    await oldDb.close();
    final oldHash = await legacy.length();
    final user = UserDatabase(
      NativeDatabase(File('${directory.path}/user.sqlite')),
    );
    await user.customStatement(
      'INSERT INTO bookmark(ayah_id,folder,created_at,updated_at) '
      "VALUES (262,'default','2026-10-01','2026-10-01')",
    );
    await user.close();

    await expectLater(
      openLocalDatabases(
        assets: _BrokenUpdateBundle(),
        supportDirectory: directory,
      ),
      throwsFormatException,
    );
    expect(await legacy.length(), oldHash);
    final retained = UserDatabase(
      NativeDatabase(File('${directory.path}/user.sqlite')),
    );
    expect((await retained.select(retained.bookmark).get()).single.ayahId, 262);
    await retained.close();
  });
}
