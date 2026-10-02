import 'package:hafidz_app/features/quran/domain/ayah_range.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

/// Validated protocol data. Server page numbers are deliberately ignored.
class LiveVoiceMessage {
  const LiveVoiceMessage({
    required this.type,
    required this.sequence,
    this.revision,
    this.range,
    this.code,
  });

  final String type;
  final int sequence;
  final int? revision;
  final AyahRange? range;
  final String? code;

  static LiveVoiceMessage? parse(Map<String, dynamic> json) {
    final type = json['type'];
    final sequence = json['sequence'];
    if (type is! String || sequence is! int || sequence < 0) return null;
    if (!const {
      'ready',
      'candidate',
      'ayah',
      'ambiguous',
      'error',
      'stopped',
    }.contains(type)) {
      return null;
    }
    if (type == 'ayah') {
      final surah = json['surah'];
      final start = json['ayah_start'];
      final end = json['ayah_end'];
      final revision = json['revision'];
      final confidence = json['confidence'];
      if (surah is! int ||
          surah < 1 ||
          surah > 114 ||
          start is! int ||
          start < 1 ||
          end is! int ||
          end < start ||
          revision is! int ||
          revision < 1 ||
          confidence is! num ||
          !confidence.isFinite ||
          confidence < 0 ||
          confidence > 1) {
        return null;
      }
      return LiveVoiceMessage(
        type: type,
        sequence: sequence,
        revision: revision,
        range: AyahRange(
          start: AyahRef(surah: surah, ayah: start),
          end: AyahRef(surah: surah, ayah: end),
        ),
      );
    }
    if (type == 'error' && json['code'] is! String) return null;
    return LiveVoiceMessage(
      type: type,
      sequence: sequence,
      code: json['code'] is String ? json['code'] as String : null,
    );
  }
}
