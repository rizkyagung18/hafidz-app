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
import 'package:hafidz_app/features/quran/data/bookmark_repository.dart';
import 'package:hafidz_app/features/quran/data/mushaf_print_data.dart';
import 'package:hafidz_app/features/quran/data/quran_repository.dart';
import 'package:hafidz_app/features/quran/domain/ayah_range.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';
import 'package:hafidz_app/features/quran/presentation/mushaf_page_screen.dart';
import 'package:hafidz_app/features/quran/presentation/reader_controller.dart';
import 'package:hafidz_app/features/voice/data/live_voice_session.dart';
import 'package:hafidz_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _QuietCapture implements LiveAudioCapture {
  _QuietCapture({this.permitted = true});
  final bool permitted;
  bool started = false;
  final StreamController<Uint8List> _chunks = StreamController<Uint8List>();
  bool stopped = false;

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<Stream<Uint8List>> start() async {
    started = true;
    return _chunks.stream;
  }

  @override
  Future<void> stop() async => stopped = true;

  @override
  Future<void> dispose() async {
    if (started) {
      await _chunks.close();
    } else {
      unawaited(_chunks.close());
    }
  }
}

class _EventSocket implements LiveVoiceSocket {
  final StreamController<dynamic> _events = StreamController<dynamic>(
    sync: true,
  );

  @override
  Stream<dynamic> get messages => _events.stream;

  @override
  Future<void> sendAudio(Uint8List bytes) async {}

  @override
  void sendText(String text) {}

  @override
  Future<void> close() => _events.close();

  void emit(String event) => _events.add(event);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory supportDirectory;
  late LocalDatabases databases;

  setUpAll(() async {
    supportDirectory = await Directory.systemTemp.createTemp('hafidz-mushaf-');
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

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> pumpPage(
    WidgetTester tester,
    String route, {
    LiveVoiceSessionFactory? voiceFactory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final router = createAppRouter(initialLocation: route);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          localDatabasesProvider.overrideWithValue(databases),
          if (voiceFactory != null)
            liveVoiceSessionFactoryProvider.overrideWithValue(voiceFactory),
        ],
        child: HafidzApp(key: ValueKey(route), router: router),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return ProviderScope.containerOf(tester.element(find.byType(HafidzApp)));
  }

  test('canonical ayah range parses single and joined keys', () {
    final range = AyahRange.parse('2:255-:256');
    expect(range.contains(const AyahRef(surah: 2, ayah: 255)), isTrue);
    expect(range.contains(const AyahRef(surah: 2, ayah: 256)), isTrue);
    expect(range.contains(const AyahRef(surah: 2, ayah: 257)), isFalse);
    expect(() => AyahRange.parse('2:256-255'), throwsFormatException);
  });

  test(
    'QUL print pages preserve 15 ordered lines and canonical word keys',
    () async {
      for (final number in [1, 42, 604]) {
        final page = await loadPrintPage(databases.quran, number);
        expect(page.number, number);
        final expectedLines = number == 1 ? 8 : 15;
        expect(page.lines, hasLength(expectedLines));
        expect(
          page.lines.map((line) => line.number),
          orderedEquals(List.generate(expectedLines, (index) => index + 1)),
        );
        expect(
          page.lines
              .where((line) => line.kind == 'ayah')
              .expand((line) => line.words),
          isNotEmpty,
        );
      }
      final page42 = await loadPrintPage(databases.quran, 42);
      expect(
        page42.lines
            .expand((line) => line.words)
            .firstWhere((word) => word.id == 5436)
            .ref,
        const AyahRef(surah: 2, ayah: 255),
      );
    },
  );

  testWidgets('deep link highlights printed words and keeps mic outside page', (
    tester,
  ) async {
    final container = await pumpPage(tester, '/quran/page/42?ayah=2:255&hl=1');
    expect(find.byKey(const Key('mushaf-pages')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-line-42-8')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-word-42-5436')), findsOneWidget);
    expect(
      container.read(readerControllerProvider)?.range.start,
      const AyahRef(surah: 2, ayah: 255),
    );
    expect(find.byIcon(Icons.mic), findsOneWidget);
    final mic = tester.getRect(find.byIcon(Icons.mic));
    final print = tester.getRect(find.byKey(const Key('mushaf-line-42-8')));
    expect(mic.overlaps(print), isFalse);
    final micButton = tester.getRect(find.byKey(const Key('mushaf-voice-mic')));
    final pageControl = tester.getRect(
      find.byKey(const Key('mushaf-page-jump')),
    );
    expect(micButton.overlaps(pageControl), isFalse);
  });

  testWidgets('selected text is vertically centered without word padding', (
    tester,
  ) async {
    await pumpPage(tester, '/quran/page/42?ayah=2:255&hl=1');
    final line = tester.getRect(find.byKey(const Key('mushaf-line-42-8')));
    final word = tester.getRect(find.byKey(const Key('mushaf-word-42-5436')));
    expect((line.center.dy - word.center.dy).abs(), lessThan(1));
    expect(word.height, lessThan(line.height));
  });

  testWidgets('opening pages start at the top of the print canvas', (
    tester,
  ) async {
    for (final page in [1, 2]) {
      await pumpPage(tester, '/quran/page/$page');
      for (var attempt = 0; attempt < 20; attempt++) {
        if (find.byKey(Key('mushaf-line-$page-1')).evaluate().isNotEmpty) {
          break;
        }
        await tester.runAsync(
          () async => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      final viewport = tester.getRect(find.byKey(const Key('mushaf-pages')));
      final firstLine = tester.getRect(
        find.byKey(Key('mushaf-line-$page-1')),
      );
      expect(firstLine.top - viewport.top, lessThan(24));
    }
  });

  testWidgets('pressing a printed word opens its canonical ayah actions', (
    tester,
  ) async {
    await pumpPage(tester, '/quran/page/42');
    await tester.tap(find.byKey(const Key('mushaf-word-42-5436')));
    await tester.pumpAndSettle();
    expect(find.text('Ayat 2:255'), findsOneWidget);
    expect(find.byKey(const Key('mushaf-translation-option')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-bookmark-option')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mushaf-translation-option')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Salin ayat'), findsOneWidget);

    String? copied;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied =
                  (call.arguments as Map<Object?, Object?>)['text'] as String?;
            }
            return null;
          });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.ensureVisible(find.byTooltip('Salin ayat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Salin ayat'));
    await tester.pumpAndSettle();
    final canonical = await QuranRepository(databases.quran).ayahByKey(
      const AyahRef(surah: 2, ayah: 255),
    );
    expect(copied, canonical!.textUthmani);
  });

  testWidgets('ayah bookmark option saves the selected ayah', (tester) async {
    await pumpPage(tester, '/quran/page/42');
    await tester.tap(find.byKey(const Key('mushaf-word-42-5436')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mushaf-bookmark-option')));
    await tester.pumpAndSettle();
    final bookmarks = await BookmarkRepository(
      databases.user,
      QuranRepository(databases.quran),
    ).all();
    final ayah = await QuranRepository(databases.quran).ayahByKey(
      const AyahRef(surah: 2, ayah: 255),
    );
    expect(bookmarks.any((bookmark) => bookmark.ayahId == ayah!.id), isTrue);
  });

  testWidgets('top Surah and Juz pills open selectable lists', (tester) async {
    await pumpPage(tester, '/quran/page/42');
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mushaf-surah-list')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-surah-2')), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).last);
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mushaf-juz-list')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-juz-3')), findsOneWidget);
    final targetPage = await QuranRepository(
      databases.quran,
    ).firstPageOfJuz(4);
    expect(targetPage, isNotNull);
    await tester.tap(find.byKey(const Key('mushaf-juz-4')));
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(Key('mushaf-line-$targetPage-1')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(Key('mushaf-line-$targetPage-1')), findsOneWidget);
  });

  testWidgets('the long 2:282 highlights whole segments on page 48', (
    tester,
  ) async {
    await pumpPage(tester, '/quran/page/48?ayah=2:282&hl=1');
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('mushaf-word-48-6171')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(const Key('mushaf-word-48-6171')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-word-48-6299')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-ayah-highlight-48-1')), findsOneWidget);
    expect(
      find.byKey(const Key('mushaf-ayah-highlight-48-15')),
      findsOneWidget,
    );
  });

  testWidgets('dense QPC lines fit the printed page width', (tester) async {
    await pumpPage(tester, '/quran/page/189');
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('mushaf-line-189-8')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.byKey(const Key('mushaf-line-189-8')), findsOneWidget);
  });

  testWidgets('a zoomed printed word still opens its ayah options', (
    tester,
  ) async {
    await pumpPage(tester, '/quran/page/42');
    final word = find.byKey(const Key('mushaf-word-42-5436'));
    final before = tester.getRect(word);
    final center = before.center;
    final left = await tester.startGesture(center - const Offset(25, 0));
    final right = await tester.startGesture(center + const Offset(25, 0));
    await tester.pump();
    await left.moveBy(const Offset(-50, 0));
    await right.moveBy(const Offset(50, 0));
    await tester.pump();
    await left.up();
    await right.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(word).width, greaterThan(before.width));
    await tester.tap(word);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mushaf-translation-option')), findsOneWidget);
    expect(find.byKey(const Key('mushaf-bookmark-option')), findsOneWidget);
  });

  testWidgets('invalid page links show a localized error', (tester) async {
    await pumpPage(tester, '/quran/page/605');
    expect(find.text('Halaman mushaf tidak ditemukan.'), findsOneWidget);
  });

  testWidgets('live voice follows local pages, pauses, resumes, and retries', (
    tester,
  ) async {
    final sockets = <_EventSocket>[];
    final captures = <_QuietCapture>[];
    final callbacks = <void Function(Map<String, dynamic>)>[];
    final container = await pumpPage(
      tester,
      '/quran/page/42',
      voiceFactory: (deviceId, onEvent, onError) {
        final capture = _QuietCapture();
        captures.add(capture);
        callbacks.add(onEvent);
        return LiveVoiceSession(
          deviceId: deviceId,
          onEvent: onEvent,
          onError: onError,
          capture: capture,
          connect: (_, _) async {
            final socket = _EventSocket();
            sockets.add(socket);
            Future<void>.delayed(Duration.zero, () {
              socket.emit(
                '{"type":"ready","sequence":0,"sample_rate":16000,'
                '"format":"pcm_s16le_mono"}',
              );
            });
            return socket;
          },
        );
      },
    );
    await tester.tap(find.byIcon(Icons.mic));
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byKey(const Key('voice-pause-follow')).evaluate().isNotEmpty ||
          find.byKey(const Key('voice-retry')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(sockets, isNotEmpty);
    expect(find.byKey(const Key('voice-pause-follow')), findsOneWidget);

    sockets.single.emit(
      '{"type":"candidate","sequence":1,"revision":0,"surah":2,'
      '"ayah_start":255,"ayah_end":255,"confidence":0.9,'
      '"transcript":"اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ"}',
    );
    await tester.pump();
    expect(find.text('Mencari ayat yang dibaca…'), findsOneWidget);
    expect(find.text('اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ'), findsOneWidget);
    final preview = tester.widget<Text>(
      find.byKey(const Key('voice-transcript')),
    );
    expect(preview.style?.fontSize, 14);
    expect(preview.style?.fontWeight, FontWeight.w400);
    expect(preview.style?.color, const Color(0xFF64716A));
    expect(find.textContaining('Halaman 42'), findsOneWidget);
    expect(container.read(readerControllerProvider), isNull);

    sockets.single.emit(
      '{"type":"ayah","sequence":2,"revision":1,"surah":2,'
      '"ayah_start":255,"ayah_end":255,"confidence":0.9,"page":1}',
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(container.read(readerControllerProvider)?.range.key, '2:255');
    expect(find.byKey(const Key('voice-transcript')), findsNothing);

    sockets.single.emit(
      '{"type":"candidate","sequence":3,"revision":1,"surah":2,'
      '"ayah_start":255,"ayah_end":255,"confidence":0.9,"transcript":"اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ"}',
    );
    await tester.pump();
    expect(
      find.text('Mendengarkan bacaan dan mengikuti ayat…'),
      findsOneWidget,
    );

    expect(find.byKey(const Key('voice-transcript')), findsNothing);
    await tester.tap(find.byKey(const Key('voice-pause-follow')));
    await tester.pump();
    sockets.single.emit(
      '{"type":"ayah","sequence":4,"revision":2,"surah":2,'
      '"ayah_start":257,"ayah_end":257,"confidence":0.9,"page":1,'
      '"transcript":"اللَّهُ وَلِيُّ الَّذِينَ آمَنُوا"}',
    );
    await tester.pump();
    expect(container.read(readerControllerProvider)?.range.key, '2:255');
    expect(find.byKey(const Key('voice-transcript')), findsNothing);
    await tester.tap(find.byKey(const Key('voice-pause-follow')));
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (container.read(readerControllerProvider)?.range.key == '2:257') {
        break;
      }
    }
    expect(container.read(readerControllerProvider)?.range.key, '2:257');
    expect(find.textContaining('Halaman 43'), findsOneWidget);

    sockets.single.emit(
      '{"type":"ayah","sequence":1,"revision":3,"surah":2,'
      '"ayah_start":255,"ayah_end":255,"confidence":0.9,"page":42,'
      '"transcript":"stale transcript"}',
    );
    await tester.pump();
    expect(container.read(readerControllerProvider)?.range.key, '2:257');
    expect(find.text('stale transcript'), findsNothing);

    sockets.single.emit(
      '{"type":"error","sequence":5,"code":"BACKPRESSURE"}',
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(captures.single.stopped, isTrue);
    expect(find.byKey(const Key('voice-retry')), findsOneWidget);
    expect(find.byKey(const Key('voice-transcript')), findsNothing);
    await tester.tap(find.byKey(const Key('voice-retry')));
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (sockets.length == 2 &&
          find.byKey(const Key('voice-pause-follow')).evaluate().isNotEmpty) {
        break;
      }
    }
    expect(sockets, hasLength(2));
    callbacks.first({
      'type': 'candidate',
      'sequence': 99,
      'transcript': 'delayed old session',
    });
    await tester.pump();
    expect(find.byKey(const Key('voice-transcript')), findsNothing);
    expect(find.byKey(const Key('voice-pause-follow')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.stop));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(captures.last.stopped, isTrue);
    expect(find.byKey(const Key('voice-status-strip')), findsNothing);
  });

  Future<void> waitForVoice(WidgetTester tester, Finder finder) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 30));
      if (finder.evaluate().isNotEmpty) return;
    }
    expect(finder, findsOneWidget);
  }

  testWidgets('mic displays permission denial and connection failures', (
    tester,
  ) async {
    for (final permitted in [false, true]) {
      await pumpPage(
        tester,
        '/quran/page/42',
        voiceFactory: (id, onEvent, onError) => LiveVoiceSession(
          deviceId: id,
          onEvent: onEvent,
          onError: onError,
          capture: _QuietCapture(permitted: permitted),
          connect: (_, _) async => throw StateError('backend unavailable'),
        ),
      );
      await tester.tap(find.byKey(const Key('mushaf-voice-mic')));
      await waitForVoice(tester, find.byKey(const Key('voice-retry')));
      expect(find.byKey(const Key('voice-transcript')), findsNothing);
      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const Key('voice-status'))),
      );
      expect(
        find.text(
          permitted ? l10n.voiceConnectFailed : l10n.voicePermissionDenied,
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }
  });

  testWidgets('connecting mic can be stopped before the socket resolves', (
    tester,
  ) async {
    final capture = _QuietCapture();
    final gate = Completer<LiveVoiceSocket>();
    var connected = false;
    await pumpPage(
      tester,
      '/quran/page/42',
      voiceFactory: (id, onEvent, onError) => LiveVoiceSession(
        deviceId: id,
        onEvent: onEvent,
        onError: onError,
        capture: capture,
        connect: (_, _) {
          connected = true;
          return gate.future;
        },
      ),
    );
    await tester.tap(find.byKey(const Key('mushaf-voice-mic')));
    for (var attempt = 0; attempt < 30 && !connected; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
    }
    expect(connected, isTrue);
    await tester.pump();
    expect(find.byIcon(Icons.stop), findsOneWidget);
    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();
    gate.complete(_EventSocket());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(capture.started, isFalse);
    expect(capture.stopped, isTrue);
    expect(find.byKey(const Key('voice-status-strip')), findsNothing);
  });

  testWidgets('background and disposal stop capture and clear the preview', (
    tester,
  ) async {
    final captures = <_QuietCapture>[];
    final sockets = <_EventSocket>[];
    await pumpPage(
      tester,
      '/quran/page/42',
      voiceFactory: (id, onEvent, onError) {
        final capture = _QuietCapture();
        captures.add(capture);
        return LiveVoiceSession(
          deviceId: id,
          onEvent: onEvent,
          onError: onError,
          capture: capture,
          connect: (_, _) async {
            final socket = _EventSocket();
            sockets.add(socket);
            Future<void>.delayed(
              Duration.zero,
              () => socket.emit(
                '{"type":"ready","sequence":0,"sample_rate":16000,"format":"pcm_s16le_mono"}',
              ),
            );
            return socket;
          },
        );
      },
    );
    await tester.tap(find.byKey(const Key('mushaf-voice-mic')));
    await waitForVoice(tester, find.byKey(const Key('voice-pause-follow')));
    sockets.last.emit(
      '{"type":"candidate","sequence":1,"transcript":"اللَّهُ"}',
    );
    await tester.pump();
    expect(find.byKey(const Key('voice-transcript')), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    expect(captures.last.stopped, isTrue);
    // Paused bindings do not draw frames; assert the cleared UI on return.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byKey(const Key('voice-transcript')), findsNothing);
    await tester.tap(find.byKey(const Key('mushaf-voice-mic')));
    await waitForVoice(tester, find.byKey(const Key('voice-pause-follow')));
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    expect(captures.last.stopped, isTrue);
  });
}
