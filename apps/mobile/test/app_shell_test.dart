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
import 'package:hafidz_app/core/i18n/locale_provider.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:hafidz_app/core/router/app_router.dart';
import 'package:hafidz_app/core/theme/app_colors.dart';
import 'package:hafidz_app/core/theme/app_theme.dart';
import 'package:hafidz_app/core/theme/theme_preference_provider.dart';
import 'package:hafidz_app/features/quran/presentation/quran_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory supportDirectory;
  late LocalDatabases databases;

  setUpAll(() async {
    supportDirectory = await Directory.systemTemp.createTemp('hafidz-shell-');
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('bottom tabs and nested routes are navigable', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter();
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

    expect(find.byKey(const Key('surah-list')), findsOneWidget);
    expect(find.text('Belajar'), findsWidgets);

    await tester.tap(find.text('Belajar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Al-Qur'an").last);
    await tester.pumpAndSettle();
    expect(find.text("Al-Qur'an"), findsWidgets);

    router.go('/quran/surah/1?ayah=2');
    await tester.pumpAndSettle();
    expect(find.text('Terjemahan'), findsWidgets);
    expect(find.byKey(const Key('ayah-2')), findsOneWidget);

    router.go('/quran/page/42?ayah=2:255&hl=1');
    await tester.pump();
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      if (find.byKey(const Key('mushaf-word-42-5436')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.textContaining('Halaman 42'), findsWidgets);
    expect(find.byKey(const Key('mushaf-word-42-5436')), findsOneWidget);

    router.go('/voice');
    await tester.pumpAndSettle();
    expect(find.text('Cari Ayat Suara'), findsOneWidget);

    router.go('/voice/result');
    await tester.pumpAndSettle();
    expect(find.text('Hasil pencarian'), findsOneWidget);

    router.go('/settings');
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan'), findsOneWidget);

    router.go('/doa/morning');
    await tester.pumpAndSettle();
    expect(find.textContaining('Doa morning'), findsOneWidget);

    router.go('/hadith/bukhari/1');
    await tester.pumpAndSettle();
    expect(find.textContaining('bukhari #1'), findsOneWidget);

    router.go('/prayer/month');
    await tester.pumpAndSettle();
    expect(find.text('Jadwal bulanan'), findsOneWidget);

    router.go('/prayer/settings');
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan adzan'), findsOneWidget);

    router.go('/prayer/location');
    await tester.pumpAndSettle();
    expect(find.text('Lokasi sholat'), findsOneWidget);

    router.go('/qibla');
    await tester.pumpAndSettle();
    expect(find.text('Kiblat'), findsWidgets);

    router.go('/doa');
    await tester.pumpAndSettle();
    expect(find.text('Doa harian'), findsOneWidget);

    router.go('/hadith');
    await tester.pumpAndSettle();
    expect(find.text('Hadis'), findsOneWidget);

    router.go('/hadith/bukhari');
    await tester.pumpAndSettle();
    expect(find.text('bukhari'), findsOneWidget);

    router.go('/asmaul-husna');
    await tester.pumpAndSettle();
    expect(find.text('Asmaul Husna'), findsOneWidget);

    router.go('/tasbih');
    await tester.pumpAndSettle();
    expect(find.text('Tasbih'), findsOneWidget);

    router.go('/hijri');
    await tester.pumpAndSettle();
    expect(find.text('Kalender Hijriah'), findsOneWidget);

    router.go('/about');
    await tester.pumpAndSettle();
    expect(find.text('Tentang & Atribusi'), findsOneWidget);
  });

  testWidgets('custom Hafidz Quran links resolve to the correct Mushaf page', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(
      initialLocation: 'hafidz://quran/ayah/2:255',
    );
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
    await tester.pump();
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('mushaf-word-42-5436')).evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.textContaining('Halaman 42'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('settings can switch light / dark / sepia', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: '/settings');
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

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HafidzApp)),
    );

    expect(container.read(themePreferenceProvider), AppThemePreference.light);
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
      AppColors.surfaceLight,
    );

    await tester.tap(find.text('Gelap'));
    await tester.pumpAndSettle();
    expect(container.read(themePreferenceProvider), AppThemePreference.dark);
    expect(prefs.getString('theme_preference'), 'dark');
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
      AppColors.surfaceDark,
    );

    await tester.tap(find.text('Sepia'));
    await tester.pumpAndSettle();
    expect(container.read(themePreferenceProvider), AppThemePreference.sepia);
    expect(prefs.getString('theme_preference'), 'sepia');
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
      AppColors.surfaceSepia,
    );

    await tester.tap(find.text('Terang'));
    await tester.pumpAndSettle();
    expect(container.read(themePreferenceProvider), AppThemePreference.light);
    expect(prefs.getString('theme_preference'), 'light');

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(container.read(localeProvider).languageCode, 'en');
    expect(prefs.getString('locale_code'), 'en');
    expect(find.text('Theme'), findsOneWidget);
  });

  testWidgets('Surah search opens the Madinah chooser and translation route', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter();
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

    await tester.enterText(
      find.byKey(const Key('surah-search')),
      'xyz-no-surah',
    );
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada surah yang cocok.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('surah-search')),
      'Baqarah',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-2')), findsOneWidget);
    expect(find.byKey(const Key('surah-1')), findsNothing);

    await tester.tap(find.byKey(const Key('surah-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('madinah-photo')), findsOneWidget);
    expect(find.byKey(const Key('choose-mushaf')), findsOneWidget);
    expect(find.byKey(const Key('choose-translation')), findsOneWidget);
    expect(find.text('Murattal'), findsNothing);

    await tester.tap(find.byKey(const Key('choose-translation')));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is QuranSurahScreen && widget.surah == 2,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Arabic search opens the Makkah chooser', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter();
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

    await tester.enterText(find.byKey(const Key('surah-search')), 'الفاتحة');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('surah-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('makkah-photo')), findsOneWidget);
    await tester.tap(find.byKey(const Key('choose-mushaf')));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(QuranPageScreen).evaluate().isNotEmpty) break;
    }
    expect(
      find.byWidgetPredicate(
        (widget) => widget is QuranPageScreen && widget.page == 1,
      ),
      findsOneWidget,
    );
  });

  testWidgets('all Juz start pages come from the local database', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter();
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
    await tester.tap(find.byKey(const Key('library-tab-juz')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HafidzApp)),
    );
    final surahs = await container.read(surahListProvider.future);
    final pages = await container.read(juzStartPagesProvider.future);
    expect(surahs.length, 114);
    expect(pages.length, 30);
    expect(
      pages.every((page) => page != null && page >= 1 && page <= 604),
      isTrue,
    );
    expect(find.byKey(const Key('juz-2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('juz-2')));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(QuranPageScreen).evaluate().isNotEmpty) break;
    }
    expect(
      find.byWidgetPredicate(
        (widget) => widget is QuranPageScreen && widget.page == pages[1],
      ),
      findsOneWidget,
    );
  });

  testWidgets('Surah library adapts to dark and sepia at two sizes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'theme_preference': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter();
    addTearDown(router.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);

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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HafidzApp)),
    );
    expect(container.read(themePreferenceProvider), AppThemePreference.dark);
    expect(find.byKey(const Key('surah-list')), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(1024, 768);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('surah-list')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await container
        .read(themePreferenceProvider.notifier)
        .setPreference(AppThemePreference.sepia);
    await tester.pumpAndSettle();
    expect(container.read(themePreferenceProvider), AppThemePreference.sepia);
    expect(find.byKey(const Key('surah-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
