import 'package:hafidz_app/core/database/user_database.dart';
import 'package:hafidz_app/features/quran/domain/reader_settings.dart';

/// Stores list-reader switches in the user database's documented kv keys.
class ReaderSettingsRepository {
  const ReaderSettingsRepository(this._db);

  final UserDatabase _db;

  Future<ReaderSettings> load() async {
    final rows = await (_db.select(
      _db.kvSetting,
    )..where((row) => row.key.isIn(['show_latin', 'show_translation']))).get();
    final values = {for (final row in rows) row.key: row.value};
    return ReaderSettings(
      showLatin: values['show_latin'] != 'false',
      showTranslation: values['show_translation'] != 'false',
    );
  }

  Future<void> save(ReaderSettings settings) async {
    await _db.transaction(() async {
      await _set('show_latin', settings.showLatin);
      await _set('show_translation', settings.showTranslation);
    });
  }

  Future<void> _set(String key, bool value) => _db.customStatement(
    'INSERT INTO kv_setting (key, value) VALUES (?, ?) '
    'ON CONFLICT(key) DO UPDATE SET value=excluded.value',
    [key, '$value'],
  );
}
