import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hafidz_app/features/voice/data/live_voice_session.dart';
import 'package:hafidz_app/features/voice/domain/live_voice_message.dart';

class FakeCapture implements LiveAudioCapture {
  FakeCapture({this.permitted = true});

  final bool permitted;
  final StreamController<Uint8List> chunks = StreamController<Uint8List>(
    sync: true,
  );
  bool started = false;
  bool stopped = false;
  bool disposed = false;

  @override
  Future<bool> hasPermission() async => permitted;

  @override
  Future<Stream<Uint8List>> start() async {
    started = true;
    return chunks.stream;
  }

  @override
  Future<void> stop() async => stopped = true;

  @override
  Future<void> dispose() async {
    disposed = true;
    if (started) await chunks.close();
  }
}

class FakeSocket implements LiveVoiceSocket {
  final StreamController<dynamic> events = StreamController<dynamic>(
    sync: true,
  );
  final List<Uint8List> frames = [];
  final List<String> commands = [];
  Completer<void>? sendGate;
  bool closed = false;

  @override
  Stream<dynamic> get messages => events.stream;

  @override
  Future<void> sendAudio(Uint8List bytes) async {
    frames.add(bytes);
    await sendGate?.future;
  }

  @override
  void sendText(String text) => commands.add(text);

  @override
  Future<void> close() async {
    closed = true;
    await events.close();
  }

  void ready() => events.add(
    '{"type":"ready","sequence":0,"sample_rate":16000,'
    '"format":"pcm_s16le_mono"}',
  );
}

void main() {
  test('PCM framer produces exact half-second even-byte frames', () {
    final framer = LivePcmFramer();
    expect(framer.add(Uint8List(8001)), isEmpty);
    final first = framer.add(Uint8List(7999));
    expect(first, hasLength(1));
    expect(first.single, hasLength(livePcmFrameBytes));
    expect(framer.pendingBytes, 0);
    expect(framer.add(Uint8List(16001)), hasLength(1));
    expect(framer.pendingBytes, 1);
  });

  test('live event parser rejects invalid sequence, range, and confidence', () {
    final valid = LiveVoiceMessage.parse({
      'type': 'ayah',
      'sequence': 2,
      'revision': 1,
      'surah': 2,
      'ayah_start': 255,
      'ayah_end': 256,
      'confidence': 0.9,
      'page': 999,
    });
    expect(valid?.range?.key, '2:255-2:256');
    for (final invalid in [
      {'type': 'ayah', 'sequence': -1},
      {
        'type': 'ayah',
        'sequence': 2,
        'revision': 1,
        'surah': 2,
        'ayah_start': 256,
        'ayah_end': 255,
        'confidence': 0.9,
      },
      {
        'type': 'ayah',
        'sequence': 2,
        'revision': 1,
        'surah': 2,
        'ayah_start': 255,
        'ayah_end': 256,
        'confidence': 1.2,
      },
    ]) {
      expect(LiveVoiceMessage.parse(invalid), isNull);
    }
  });

  test('capture begins after ready and sends only fixed PCM frames', () async {
    final capture = FakeCapture();
    final socket = FakeSocket();
    final received = <Map<String, dynamic>>[];
    final errors = <Object>[];
    Uri? connectedUri;
    final session = LiveVoiceSession(
      deviceId: 'test-device',
      onEvent: received.add,
      onError: errors.add,
      capture: capture,
      connect: (uri, _) async {
        connectedUri = uri;
        Future<void>.delayed(Duration.zero, socket.ready);
        return socket;
      },
    );
    await session.start(hintSurah: 2);
    expect(capture.started, isTrue);
    expect(connectedUri?.path, '/v1/voice/live');
    expect(connectedUri?.queryParameters['hint_surah'], '2');
    capture.chunks.add(Uint8List.fromList(List<int>.filled(8001, 1)));
    capture.chunks.add(Uint8List.fromList(List<int>.filled(23999, 2)));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(socket.frames.map((frame) => frame.length), [16000, 16000]);
    expect(socket.frames.first[0], 1);
    expect(socket.frames.first[8001], 2);
    expect(socket.frames.last[0], 2);
    expect(received.single['type'], 'ready');
    await session.stop();
    expect(socket.commands, ['{"type":"stop"}']);
    expect(capture.stopped, isTrue);
    expect(capture.disposed, isTrue);
    expect(errors, isEmpty);
  });

  test('denied permission never opens a socket or captures audio', () async {
    final capture = FakeCapture(permitted: false);
    var connected = false;
    final session = LiveVoiceSession(
      deviceId: 'test-device',
      onEvent: (_) {},
      onError: (_) {},
      capture: capture,
      connect: (_, _) async {
        connected = true;
        return FakeSocket();
      },
    );
    await expectLater(
      session.start(),
      throwsA(
        isA<LiveVoiceFailure>().having(
          (failure) => failure.code,
          'code',
          'MIC_PERMISSION_DENIED',
        ),
      ),
    );
    expect(connected, isFalse);
    expect(capture.started, isFalse);
    expect(capture.disposed, isTrue);
  });

  test('bounded send queue stops capture on backpressure', () async {
    final capture = FakeCapture();
    final socket = FakeSocket()..sendGate = Completer<void>();
    final errors = <Object>[];
    final session = LiveVoiceSession(
      deviceId: 'test-device',
      onEvent: (_) {},
      onError: errors.add,
      capture: capture,
      connect: (_, _) async {
        Future<void>.delayed(Duration.zero, socket.ready);
        return socket;
      },
    );
    await session.start();
    for (var index = 0; index < 4; index++) {
      capture.chunks.add(Uint8List(livePcmFrameBytes));
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(errors.single, isA<LiveVoiceFailure>());
    expect((errors.single as LiveVoiceFailure).code, 'BACKPRESSURE');
    socket.sendGate!.complete();
    await session.stop();
    expect(capture.stopped, isTrue);
    expect(socket.closed, isTrue);
  });

  test('disconnect stops capture and reports one failure', () async {
    final capture = FakeCapture();
    final socket = FakeSocket();
    final errors = <Object>[];
    final session = LiveVoiceSession(
      deviceId: 'test-device',
      onEvent: (_) {},
      onError: errors.add,
      capture: capture,
      connect: (_, _) async {
        Future<void>.delayed(Duration.zero, socket.ready);
        return socket;
      },
    );
    await session.start();
    await socket.close();
    await session.stop();
    expect(errors, hasLength(1));
    expect((errors.single as LiveVoiceFailure).code, 'VOICE_DISCONNECTED');
    expect(capture.stopped, isTrue);
  });
}
