import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hafidz_app/core/network/dio_provider.dart';
import 'package:record/record.dart';

const livePcmFrameBytes = 16000; // 0.5 s of 16 kHz mono PCM16LE.
const liveMaxQueuedFrames = 2;

class LiveVoiceFailure implements Exception {
  const LiveVoiceFailure(this.code);

  final String code;

  @override
  String toString() => 'LiveVoiceFailure($code)';
}

/// Keeps arbitrary recorder chunks aligned to complete, even-byte PCM frames.
class LivePcmFramer {
  final List<int> _pending = [];

  List<Uint8List> add(Uint8List chunk) {
    _pending.addAll(chunk);
    final frames = <Uint8List>[];
    while (_pending.length >= livePcmFrameBytes) {
      frames.add(Uint8List.fromList(_pending.sublist(0, livePcmFrameBytes)));
      _pending.removeRange(0, livePcmFrameBytes);
    }
    return frames;
  }

  int get pendingBytes => _pending.length;

  void clear() => _pending.clear();
}

abstract interface class LiveAudioCapture {
  Future<bool> hasPermission();
  Future<Stream<Uint8List>> start();
  Future<void> stop();
  Future<void> dispose();
}

class RecorderLiveAudioCapture implements LiveAudioCapture {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<Stream<Uint8List>> start() => _recorder.startStream(
    const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
      streamBufferSize: livePcmFrameBytes,
    ),
  );

  @override
  Future<void> stop() => _recorder.stop().then((_) {});

  @override
  Future<void> dispose() => _recorder.dispose();
}

abstract interface class LiveVoiceSocket {
  Stream<dynamic> get messages;
  Future<void> sendAudio(Uint8List bytes);
  void sendText(String text);
  Future<void> close();
}

class IoLiveVoiceSocket implements LiveVoiceSocket {
  IoLiveVoiceSocket(this._socket);

  final WebSocket _socket;

  @override
  Stream<dynamic> get messages => _socket;

  @override
  Future<void> sendAudio(Uint8List bytes) =>
      _socket.addStream(Stream<Uint8List>.value(bytes));

  @override
  void sendText(String text) => _socket.add(text);

  @override
  Future<void> close() => _socket.close();
}

typedef LiveVoiceSocketConnector =
    Future<LiveVoiceSocket> Function(
      Uri uri,
      String deviceId,
    );

Future<LiveVoiceSocket> connectLiveVoiceSocket(
  Uri uri,
  String deviceId,
) async {
  final socket = await WebSocket.connect(
    uri.toString(),
    headers: {'X-Device-Id': deviceId},
  ).timeout(const Duration(seconds: 10));
  return IoLiveVoiceSocket(socket);
}

/// Ephemeral capture and WebSocket transport; no recorder file is created.
class LiveVoiceSession {
  LiveVoiceSession({
    required this.deviceId,
    required this.onEvent,
    required this.onError,
    LiveAudioCapture? capture,
    LiveVoiceSocketConnector? connect,
  }) : _capture = capture ?? RecorderLiveAudioCapture(),
       _connect = connect ?? connectLiveVoiceSocket;

  final String deviceId;
  final void Function(Map<String, dynamic>) onEvent;
  final void Function(Object) onError;
  final LiveAudioCapture _capture;
  final LiveVoiceSocketConnector _connect;
  final LivePcmFramer _framer = LivePcmFramer();
  final Queue<Uint8List> _frames = Queue<Uint8List>();

  LiveVoiceSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  StreamSubscription<Uint8List>? _audioSubscription;
  Future<void>? _drainTask;
  Future<void>? _stopTask;
  Timer? _expiry;
  bool _stopping = false;
  bool _failed = false;

  Future<void> start({int? hintSurah}) async {
    if (_stopping || _socket != null) throw StateError('Session already used');
    try {
      if (!await _capture.hasPermission()) {
        throw const LiveVoiceFailure('MIC_PERMISSION_DENIED');
      }
      final base = Uri.parse(apiBaseUrl);
      final uri = base.replace(
        scheme: base.scheme == 'https' ? 'wss' : 'ws',
        path: '/v1/voice/live',
        queryParameters: hintSurah == null
            ? null
            : {'hint_surah': '$hintSurah'},
      );
      final ready = Completer<void>();
      final socket = await _connect(uri, deviceId).timeout(
        const Duration(seconds: 10),
      );
      _socket = socket;
      _socketSubscription = socket.messages.listen(
        (message) {
          if (message is! String) {
            _fail(const LiveVoiceFailure('INVALID_SERVER_EVENT'));
            return;
          }
          try {
            final event = jsonDecode(message) as Map<String, dynamic>;
            if (event['type'] == 'ready' && !ready.isCompleted) {
              if (event['sequence'] != 0 ||
                  event['sample_rate'] != 16000 ||
                  event['format'] != 'pcm_s16le_mono') {
                throw const LiveVoiceFailure('INVALID_SERVER_EVENT');
              }
              ready.complete();
            } else if (!ready.isCompleted) {
              throw const LiveVoiceFailure('INVALID_SERVER_EVENT');
            }
            onEvent(event);
          } on Object catch (error) {
            if (!ready.isCompleted) ready.completeError(error);
            _fail(error);
          }
        },
        onError: (Object error) {
          if (!ready.isCompleted) ready.completeError(error);
          _fail(error);
        },
        onDone: () {
          const error = LiveVoiceFailure('VOICE_DISCONNECTED');
          if (!ready.isCompleted) ready.completeError(error);
          _fail(error);
        },
      );
      await ready.future.timeout(const Duration(seconds: 10));
      if (_stopping) throw const LiveVoiceFailure('VOICE_DISCONNECTED');
      final audio = await _capture.start();
      if (_stopping) throw const LiveVoiceFailure('VOICE_DISCONNECTED');
      _audioSubscription = audio.listen(_onPcm, onError: _fail);
      _expiry = Timer(const Duration(seconds: 180), () {
        _fail(const LiveVoiceFailure('SESSION_EXPIRED'));
      });
    } on Object {
      await stop();
      rethrow;
    }
  }

  void _onPcm(Uint8List chunk) {
    if (_stopping) return;
    if (chunk.length > 65536) {
      _fail(const LiveVoiceFailure('BACKPRESSURE'));
      return;
    }
    for (final frame in _framer.add(chunk)) {
      if (_frames.length >= liveMaxQueuedFrames) {
        _fail(const LiveVoiceFailure('BACKPRESSURE'));
        return;
      }
      _frames.add(frame);
    }
    _ensureDrain();
  }

  void _ensureDrain() {
    if (_drainTask != null || _frames.isEmpty || _stopping) return;
    _drainTask = _drain().whenComplete(() {
      _drainTask = null;
      _ensureDrain();
    });
  }

  Future<void> _drain() async {
    try {
      while (_frames.isNotEmpty && !_stopping) {
        await _socket!.sendAudio(_frames.removeFirst());
      }
    } on Object catch (error) {
      _fail(error);
    }
  }

  void _fail(Object error) {
    if (_stopping || _failed) return;
    _failed = true;
    onError(error);
    unawaited(stop());
  }

  Future<void> stop() => _stopTask ??= _stop();

  Future<void> _stop() async {
    _stopping = true;
    _expiry?.cancel();
    await _audioSubscription?.cancel();
    try {
      await _capture.stop();
    } on Object {
      // Capture may not have started if connection or permission failed.
    }
    _frames.clear();
    _framer.clear();
    try {
      await _drainTask?.timeout(const Duration(seconds: 2));
    } on Object {
      // A stalled network must not keep the microphone session alive.
    }
    final socket = _socket;
    _socket = null;
    if (socket != null) {
      try {
        if (!_failed) socket.sendText(jsonEncode({'type': 'stop'}));
        await socket.close().timeout(const Duration(seconds: 2));
      } on Object {
        // The remote peer may have closed first.
      }
    }
    await _socketSubscription?.cancel();
    await _capture.dispose();
  }
}
