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
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/data/reading_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory supportDirectory;
  late LocalDatabases databases;

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

  Future<void> pumpApp(WidgetTester tester, {String route = '/quran'}) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: route);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localDatabasesProvider.overrideWithValue(databases),
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

    final list = tester.widget<ListView>(find.byKey(const Key('surah-list')));
    expect(list.childrenDelegate.estimatedChildCount, 114);
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

    expect(find.text(verse.textUthmani), findsOneWidget);
    expect(verse.textLatin, isNull);
    expect(find.text(verse.translationId), findsOneWidget);
    final arabic = tester.widget<Text>(find.text(verse.textUthmani));
    expect(arabic.style?.fontFamily, 'Me Quran');

    expect(find.text('Latin'), findsNothing);
    await tester.tap(find.text('Terjemahan'));
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
      await pumpApp(tester, route: '/quran/surah/1');
      final verse = (await QuranRepository(databases.quran).ayahByKey(
        const AyahRef(surah: 1, ayah: 1),
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

      await tester.tap(
        find.descendant(of: card, matching: find.byTooltip('Putar ayat')),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Pemutar murottal akan tersedia pada tahap berikutnya.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('direct Al-Baqarah jump builds only nearby ayat', (tester) async {
    await pumpApp(tester, route: '/quran/surah/2?ayah=255');
    final verse = (await QuranRepository(databases.quran).ayahByKey(
      const AyahRef(surah: 2, ayah: 255),
    ))!;

    expect(find.byKey(const Key('ayah-255')), findsOneWidget);
    expect(find.text(verse.textUthmani), findsOneWidget);
    expect(verse.page, 42);
    expect(find.byType(Card).evaluate().length, lessThan(30));

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
}
