import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafidz_app/app.dart';
import 'package:hafidz_app/core/database/local_databases.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/database/user_database.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/router/app_router.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/core/theme/theme_preference_provider.dart';
import 'package:hafidz_app/features/quran/data/mushaf_print_data.dart';
import 'package:hafidz_app/features/quran/data/qpc_ayah_glyphs.dart';
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/features/quran/presentation/surah_list_screen.dart';
import 'package:hafidz_app/features/quran/presentation/surah_reader_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory supportDirectory;
  late LocalDatabases databases;
  late Map<String, QpcAyahGlyph> glyphs;

  setUpAll(() async {
    supportDirectory = await Directory.systemTemp.createTemp('hafidz-reader-');
    final installed = await openLocalDatabases(
      assets: rootBundle,
      supportDirectory: supportDirectory,
    );
    await installed.close();
    databases = LocalDatabases(
      quran: QuranDatabase(
        NativeDatabase(
          File('${supportDirectory.path}/quran.sqlite'),
          enableMigrations: false,
          setup: (db) => db.execute('PRAGMA query_only = ON'),
        ),
      ),
      user: UserDatabase(NativeDatabase.memory()),
    );
    glyphs = await readQpcAyahGlyphs();
    await loadQpcPageFont(databases.quran, 1);
    // Complete shared font futures outside widget tests' separate fake clocks.
    // This also verifies the real manifest, hashes and marker fonts used below.
    for (final number in [1, 10, 255, 282, 286]) {
      await loadAyahEndMarker(databases.quran, AyahRef(surah: 2, ayah: number));
    }
  });

  tearDownAll(() async {
    await databases.close();
    await supportDirectory.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await databases.user.customStatement('DELETE FROM bookmark');
    await databases.user.customStatement('DELETE FROM reading_position');
    await databases.user.customStatement('DELETE FROM kv_setting');
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    String route = '/quran',
    Future<SurahContent> Function(int)? contentLoader,
    Future<QpcAyahGlyph> Function(AyahRef)? glyphLoader,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: route);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localDatabasesProvider.overrideWithValue(databases),
          if (contentLoader != null)
            surahContentProvider.overrideWith(
              (ref, number) => contentLoader(number),
            ),
          qpcAyahGlyphsProvider.overrideWith((ref) async => glyphs),
          surahAyahGlyphProvider.overrideWith(
            (ref, ayah) async => glyphLoader == null
                ? glyphs[ayah.key]!
                : await glyphLoader(ayah),
          ),
        ],
        child: HafidzApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Surah list has all 114 entries and required metadata', (
    tester,
  ) async {
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HafidzApp)),
    );
    final surahs = await container.read(surahListProvider.future);
    expect(surahs.length, 114);
    expect(find.byKey(const Key('surah-list')), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('الفاتحة'), findsOneWidget);
    expect(find.textContaining('7 ayat'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('surah-1')),
        matching: find.textContaining('Makkiyah'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('list reader shows exact source text and persists switches', (
    tester,
  ) async {
    await pumpApp(tester, route: '/quran/surah/1');
    final verse = (await QuranRepository(databases.quran).ayahByKey(
      const AyahRef(surah: 1, ayah: 1),
    ))!;

    final opening = tester.widget<Text>(
      find.byKey(const Key('bismillah-text')),
    );
    expect(opening.semanticsLabel, verse.textUthmani);
    expect(opening.data, glyphs['1:1']!.openingText);
    expect(verse.textLatin, isNull);
    expect(find.text(verse.translationId), findsOneWidget);
    expect(opening.style?.fontFamily, 'QPCPage1');

    expect(find.text('Latin'), findsNothing);
    await tester.tap(find.byKey(const Key('reader-translation-toggle')));
    await tester.pumpAndSettle();
    expect(find.text(verse.translationId), findsNothing);

    final rows = await databases.user
        .customSelect(
          'SELECT key, value FROM kv_setting ORDER BY key',
        )
        .get();
    final values = {
      for (final row in rows)
        row.read<String>('key'): row.read<String>('value'),
    };
    expect(values['show_translation'], 'false');
  });

  testWidgets(
    'verse actions save bookmark and copy verbatim QUL text',
    (
      tester,
    ) async {
      await pumpApp(tester, route: '/quran/surah/2');
      final verse = (await QuranRepository(databases.quran).ayahByKey(
        const AyahRef(surah: 2, ayah: 1),
      ))!;
      final card = find.byKey(const Key('ayah-1'));

      await tester.tap(
        find.descendant(of: card, matching: find.byTooltip('Tandai ayat')),
      );
      await tester.pumpAndSettle();
      final bookmark = await databases.user
          .customSelect(
            'SELECT ayah_id FROM bookmark',
          )
          .getSingle();
      expect(bookmark.read<int>('ayah_id'), verse.id);

      String? copiedText;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'Clipboard.setData') {
                copiedText =
                    (call.arguments as Map<Object?, Object?>)['text']
                        as String?;
              }
              return null;
            });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.tap(
        find.descendant(of: card, matching: find.byTooltip('Salin ayat')),
      );
      await tester.pumpAndSettle();
      expect(copiedText, verse.textUthmani);

      expect(find.byTooltip('Tafsir Kemenag'), findsNothing);
      String? sharedText;
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'share') {
          sharedText =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return 'dev.fluttercommunity.plus/share/unavailable';
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await tester.tap(
        find.descendant(of: card, matching: find.byTooltip('Bagikan ayat')),
      );
      await tester.pumpAndSettle();
      expect(sharedText, contains(verse.textUthmani));
      expect(sharedText, contains(verse.translationId));

      expect(find.byTooltip('Putar ayat'), findsNothing);
    },
  );

  testWidgets('direct Al-Baqarah jump builds only nearby ayat', (tester) async {
    await pumpApp(tester, route: '/quran/surah/2?ayah=255');
    final verse = (await QuranRepository(databases.quran).ayahByKey(
      const AyahRef(surah: 2, ayah: 255),
    ))!;

    expect(find.byKey(const Key('ayah-255')), findsOneWidget);
    final arabic = tester.widget<Text>(
      find.byKey(const Key('ayah-arabic-255')),
    );
    expect(arabic.data, glyphs['2:255']!.text);
    expect(arabic.style?.fontFamily, 'QPCPage42');
    expect(arabic.semanticsLabel, verse.textUthmani);
    expect(verse.page, 42);
    final badge = find.byKey(const Key('ayah-number-255'));
    expect(
      find.descendant(of: badge, matching: find.text('255')),
      findsOneWidget,
    );
    expect(find.text('Ayat 255'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    final position = await ReadingRepository(
      databases.user,
      QuranRepository(databases.quran),
    ).current();
    expect(position?.ayahId, verse.id);
    expect(position?.mode, 'list');
  });

  testWidgets('long press opens verse actions', (tester) async {
    await pumpApp(tester, route: '/quran/surah/1');
    await tester.longPress(find.byKey(const Key('ayah-1')));
    await tester.pumpAndSettle();

    expect(find.text('Tandai ayat'), findsOneWidget);
    expect(find.text('Bagikan ayat'), findsOneWidget);
    expect(find.text('Salin ayat'), findsOneWidget);
    expect(find.text('Tafsir Kemenag'), findsNothing);

    await tester.tap(find.text('Tandai ayat'));
    await tester.pumpAndSettle();
    final bookmarks = await databases.user
        .customSelect('SELECT ayah_id FROM bookmark')
        .get();
    expect(bookmarks, hasLength(1));
  });

  testWidgets('top tabs switch Surahs and swiping advances the reader', (
    tester,
  ) async {
    await pumpApp(tester, route: '/quran/surah/1');
    expect(find.byKey(const Key('surah-tabs')), findsOneWidget);
    expect(find.byKey(const Key('surah-tab-1')), findsOneWidget);
    expect(find.byKey(const Key('surah-tab-114')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('surah-tab-2')));
    await tester.tap(find.byKey(const Key('surah-tab-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-reader-2-1')), findsOneWidget);
    expect(find.byKey(const Key('ayah-1')), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('surah-reader-2-1')),
      const Offset(-350, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-reader-3-1')), findsOneWidget);
  });

  testWidgets('last Surah stays in range when swiped forward', (tester) async {
    await pumpApp(tester, route: '/quran/surah/114');
    expect(find.byKey(const Key('surah-reader-114-1')), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('surah-reader-114-1')),
      const Offset(-350, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-reader-114-1')), findsOneWidget);
  });

  testWidgets('reader fits small and wide views in each theme', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await pumpApp(tester, route: '/quran/surah/2');
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HafidzApp)),
    );
    for (final theme in AppThemePreference.values) {
      await container
          .read(themePreferenceProvider.notifier)
          .setPreference(theme);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('surah-tabs')), findsOneWidget);
    }
    tester.view.physicalSize = const Size(900, 1000);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('surah-reader-2-1')), findsOneWidget);
  });

  testWidgets('tab strip survives loading and does not recenter on settings', (
    tester,
  ) async {
    final repository = QuranRepository(databases.quran);
    final first = (
      surah: await repository.surahByNumber(1),
      ayahs: await repository.ayahsInSurah(1),
    );
    final second = Completer<SurahContent>();
    await pumpApp(
      tester,
      route: '/quran/surah/1',
      contentLoader: (number) =>
          number == 2 ? second.future : Future.value(first),
    );
    final tabs = find.byKey(const Key('surah-tabs'));
    final element = tester.element(tabs);
    await tester.ensureVisible(find.byKey(const Key('surah-tab-2')));
    await tester.tap(find.byKey(const Key('surah-tab-2')));
    await tester.pump();
    expect(tester.element(tabs), same(element));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    second.complete((
      surah: await repository.surahByNumber(2),
      ayahs: await repository.ayahsInSurah(2),
    ));
    await tester.pumpAndSettle();
    expect(tester.element(tabs), same(element));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: tabs, matching: find.byType(Scrollable)),
    );
    scroll.position.jumpTo(scroll.position.pixels - 60);
    await tester.pump();
    final offset = scroll.position.pixels;
    await tester.tap(find.byKey(const Key('reader-translation-toggle')));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, closeTo(offset, 0.1));
  });

  testWidgets('QUL openings preserve Fatihah identity and Tawbah exception', (
    tester,
  ) async {
    await pumpApp(tester, route: '/quran/surah/1');
    final opening = (await QuranRepository(databases.quran).ayahByKey(
      const AyahRef(surah: 1, ayah: 1),
    ))!;
    expect(
      tester
          .widget<Text>(find.byKey(const Key('bismillah-text')))
          .semanticsLabel,
      opening.textUthmani,
    );
    expect(find.byKey(const Key('ayah-1')), findsOneWidget);
    expect(find.byKey(const Key('ayah-number-1')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('surah-tab-2')));
    await tester.tap(find.byKey(const Key('surah-tab-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-bismillah')), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('bismillah-text')))
          .semanticsLabel,
      opening.textUthmani,
    );
    await tester.ensureVisible(find.byKey(const Key('surah-tab-9')));
    await tester.tap(find.byKey(const Key('surah-tab-9')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-bismillah')), findsNothing);
    expect(find.text(opening.textUthmani), findsNothing);
    expect(find.byKey(const Key('ayah-1')), findsOneWidget);
  });

  testWidgets('QUL markers use the exact ending glyph and matching font', (
    tester,
  ) async {
    for (final (number, page, glyph) in [
      (1, 2, 'ﭒ'),
      (10, 3, 'ﮐ'),
      (255, 42, 'ﯾ'),
      (282, 48, 'ﰂ'),
      (286, 49, 'ﰎ'),
    ]) {
      final marker = await readAyahEndMarker(
        databases.quran,
        AyahRef(surah: 2, ayah: number),
      );
      expect(marker.glyph, glyph);
      expect(marker.page, page);
      expect(marker.fontFamily, 'QPCPage$page');
    }
    await pumpApp(tester, route: '/quran/surah/2?ayah=255');
    final arabic = tester.widget<Text>(
      find.byKey(const Key('ayah-arabic-255')),
    );
    expect(arabic.data, glyphs['2:255']!.text);
    expect(arabic.data!.endsWith('ﯾ'), isTrue);
    expect(arabic.style!.fontFamily, 'QPCPage42');
    expect(find.byKey(const Key('ayah-number-255')), findsOneWidget);
    expect(find.textContaining('Madaniyah'), findsNothing);
    expect(find.byType(FilterChip), findsNothing);
    expect(find.byKey(const Key('reader-translation-toggle')), findsOneWidget);
  });

  test(
    'marker lookup uses the final segment when an ayah spans pages',
    () async {
      // Current QUL data has no cross-page ayah: use a writable temporary copy
      // to verify this future package case without altering bundled content.
      final file = await File('${supportDirectory.path}/quran.sqlite').copy(
        '${supportDirectory.path}/marker-multipage.sqlite',
      );
      final db = QuranDatabase(NativeDatabase(file, enableMigrations: false));
      try {
        final verse = (await QuranRepository(
          db,
        ).ayahByKey(const AyahRef(surah: 2, ayah: 255)))!;
        final row = await db
            .customSelect('SELECT MAX(id)+1 AS next_id FROM mushaf_word')
            .getSingle();
        final id = row.read<int>('next_id');
        await db.customStatement(
          'INSERT INTO mushaf_word VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          ['madinah-1405h-qpc-v1', id, verse.id, '2:255:52', 'ﭒ', 43, 1, 1],
        );
        await db.customStatement(
          'INSERT INTO mushaf_ayah_page VALUES (?, ?, ?, ?, ?, ?, ?)',
          ['madinah-1405h-qpc-v1', verse.id, 43, 1, 1, id, id],
        );
        final marker = await readAyahEndMarker(
          db,
          const AyahRef(surah: 2, ayah: 255),
        );
        expect(verse.page, 42);
        expect(marker.page, 43);
        expect(marker.glyph, 'ﭒ');
      } finally {
        await db.close();
        await file.delete();
      }
    },
  );

  testWidgets(
    'missing print assets show a warning while Arabic stays readable',
    (tester) async {
      await pumpApp(
        tester,
        route: '/quran/surah/2',
        glyphLoader: (ayah) async => throw const FormatException(
          'Missing QUL glyph assets',
        ),
      );
      expect(
        find.text(
          'Huruf ayat QPC tidak tersedia. Menampilkan teks Arab QUL yang dapat dibaca.',
        ),
        findsWidgets,
      );
      final verse = (await QuranRepository(
        databases.quran,
      ).ayahByKey(const AyahRef(surah: 2, ayah: 1)))!;
      final arabic = tester.widget<Text>(
        find.byKey(const Key('ayah-arabic-1')),
      );
      expect(arabic.semanticsLabel, verse.textUthmani);
      expect(find.byKey(const Key('ayah-marker-2:1')), findsNothing);
    },
  );

  testWidgets('ayah glyph fonts are requested only for built reading rows', (
    tester,
  ) async {
    final requested = <AyahRef>{};
    await pumpApp(
      tester,
      route: '/quran/surah/2',
      glyphLoader: (ayah) async {
        requested.add(ayah);
        final glyph = glyphs[ayah.key]!;
        await loadQpcPageFont(databases.quran, glyph.page);
        return glyph;
      },
    );
    expect(requested, isNotEmpty);
    expect(requested.length, lessThan(20));
    expect(requested, isNot(contains(const AyahRef(surah: 2, ayah: 286))));
  });
}
