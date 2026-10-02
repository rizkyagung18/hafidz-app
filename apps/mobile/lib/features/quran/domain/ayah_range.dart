import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

part 'ayah_range.freezed.dart';

/// Inclusive range of canonical Qur'an references.
@freezed
abstract class AyahRange with _$AyahRange {
  const factory AyahRange({required AyahRef start, required AyahRef end}) =
      _AyahRange;

  const AyahRange._();

  factory AyahRange.single(AyahRef ref) => AyahRange(start: ref, end: ref);

  /// Accepts `2:255`, `2:255-256`, `2:255-:256`, or `2:255-2:256`.
  factory AyahRange.parse(String key) {
    final parts = key.split('-');
    if (parts.isEmpty || parts.length > 2) {
      throw FormatException('Invalid ayah range: $key');
    }
    final start = AyahRef.parse(parts.first);
    if (parts.length == 1) return AyahRange.single(start);
    final suffix = parts.last;
    final end = AyahRef.parse(
      suffix.startsWith(':')
          ? '${start.surah}$suffix'
          : suffix.contains(':')
          ? suffix
          : '${start.surah}:$suffix',
    );
    if (end.surah < start.surah ||
        (end.surah == start.surah && end.ayah < start.ayah)) {
      throw FormatException('Reversed ayah range: $key');
    }
    return AyahRange(start: start, end: end);
  }

  bool contains(AyahRef ref) =>
      (ref.surah > start.surah ||
          (ref.surah == start.surah && ref.ayah >= start.ayah)) &&
      (ref.surah < end.surah ||
          (ref.surah == end.surah && ref.ayah <= end.ayah));

  String get key => start == end ? start.key : '${start.key}-${end.key}';
}
