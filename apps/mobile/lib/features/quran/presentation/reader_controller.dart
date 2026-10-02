import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hafidz_app/features/quran/domain/ayah_range.dart';

part 'reader_controller.freezed.dart';

@freezed
abstract class ReaderHighlight with _$ReaderHighlight {
  const factory ReaderHighlight({
    required AyahRange range,
    required bool pulsing,
  }) = _ReaderHighlight;
}

final readerControllerProvider =
    NotifierProvider<ReaderController, ReaderHighlight?>(ReaderController.new);

/// Keeps the marker after the pulse so navigation and audio can share it.
class ReaderController extends Notifier<ReaderHighlight?> {
  Timer? _pulseTimer;

  @override
  ReaderHighlight? build() {
    ref.onDispose(() => _pulseTimer?.cancel());
    return null;
  }

  void highlight(
    AyahRange range, {
    Duration pulse = const Duration(seconds: 4),
  }) {
    _pulseTimer?.cancel();
    state = ReaderHighlight(range: range, pulsing: pulse > Duration.zero);
    if (pulse > Duration.zero) {
      _pulseTimer = Timer(pulse, () {
        state = ReaderHighlight(range: range, pulsing: false);
      });
    }
  }

  void clear() {
    _pulseTimer?.cancel();
    state = null;
  }
}
