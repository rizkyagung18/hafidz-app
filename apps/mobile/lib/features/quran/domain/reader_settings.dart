import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_settings.freezed.dart';

@freezed
abstract class ReaderSettings with _$ReaderSettings {
  const factory ReaderSettings({
    @Default(true) bool showLatin,
    @Default(true) bool showTranslation,
  }) = _ReaderSettings;
}
