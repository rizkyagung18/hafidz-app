import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';

/// Exact QUL presentation data, separate from canonical Arabic text.
class QpcAyahGlyph {
  const QpcAyahGlyph({required this.text, required this.page});

  final String text;
  final int page;

  String get fontFamily => 'QPCPage$page';

  // QUL 1:1 has four text glyphs followed by its numbered ending glyph.
  String get openingText => text.substring(0, text.lastIndexOf(' '));
}

Future<Map<String, QpcAyahGlyph>> readQpcAyahGlyphs() async {
  final data = await rootBundle.load(
    'assets/db/qpc-v1-ayah-by-ayah-glyphs.db',
  );
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return compute(_readDatabase, bytes);
}

Map<String, QpcAyahGlyph> _readDatabase(Uint8List bytes) {
  const expectedHash =
      '04c5d8f1df4f694983bbb4acfd9cd3c4a5f7f0a007927372ad9b6148bd1b9fa0';
  if (sha256.convert(bytes).toString() != expectedHash) {
    throw const FormatException('QUL ayah glyph database checksum mismatch');
  }
  final temporary = Directory.systemTemp.createTempSync('hafidz-qpc-');
  try {
    final file = File('${temporary.path}/glyphs.db')..writeAsBytesSync(bytes);
    final db = sqlite3.open(file.path, mode: OpenMode.readOnly);
    try {
      final result = <String, QpcAyahGlyph>{};
      for (final row in db.select(
        'SELECT verse_key,surah,ayah,text,page_number FROM verses ORDER BY id',
      )) {
        final key = row['verse_key'] as String;
        final text = row['text'] as String;
        final page = row['page_number'] as int;
        if (key != '${row['surah']}:${row['ayah']}' ||
            text.isEmpty ||
            page < 1 ||
            page > 604 ||
            result.containsKey(key)) {
          throw FormatException('Invalid QUL ayah glyph row: $key');
        }
        result[key] = QpcAyahGlyph(text: text, page: page);
      }
      if (result.length != 6236) {
        throw const FormatException('Incomplete QUL ayah glyph database');
      }
      return Map.unmodifiable(result);
    } finally {
      db.close();
    }
  } finally {
    temporary.deleteSync(recursive: true);
  }
}
