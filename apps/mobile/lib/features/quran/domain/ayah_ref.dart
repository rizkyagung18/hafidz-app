import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah_ref.freezed.dart';

/// Canonical Quran reference. The global database ID stays internal.
@freezed
abstract class AyahRef with _$AyahRef {
  const factory AyahRef({required int surah, required int ayah}) = _AyahRef;

  const AyahRef._();

  factory AyahRef.parse(String key) {
    final parts = key.split(':');
    if (parts.length != 2 ||
        !RegExp(r'^[1-9][0-9]*$').hasMatch(parts[0]) ||
        !RegExp(r'^[1-9][0-9]*$').hasMatch(parts[1])) {
      throw FormatException('Invalid ayah key: $key');
    }
    return AyahRef(surah: int.parse(parts[0]), ayah: int.parse(parts[1]));
  }

  String get key => '$surah:$ayah';
}
