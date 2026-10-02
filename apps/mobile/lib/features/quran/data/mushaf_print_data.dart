import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/features/quran/domain/ayah_ref.dart';

const _base = 'assets/mushaf';
final Map<int, Future<void>> _loadedPageFonts = {};
Future<void>? _loadedAuxiliaryFonts;

class PrintWord {
  const PrintWord({required this.id, required this.ref, required this.glyph});

  final int id;
  final AyahRef ref;
  final String glyph;
}

class PrintLine {
  const PrintLine({
    required this.number,
    required this.kind,
    required this.centered,
    required this.surah,
    required this.words,
    this.headingGlyph,
    this.headingPng,
  });

  final int number;
  final String kind;
  final bool centered;
  final int? surah;
  final List<PrintWord> words;
  final String? headingGlyph;
  final Uint8List? headingPng;
}

class PrintPage {
  const PrintPage({required this.number, required this.lines});

  final int number;
  final List<PrintLine> lines;
}

Future<Uint8List> _loadAsset(String path, Directory? packDirectory) async {
  if (packDirectory != null) {
    return File('${packDirectory.path}/$path').readAsBytes();
  }
  final data = await rootBundle.load('$_base/$path');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Future<Map<String, dynamic>> _loadManifest(
  QuranDatabase db,
  Directory? packDirectory,
) async {
  final bytes = await _loadAsset('manifest.json', packDirectory);
  final digest = sha256.convert(bytes).toString();
  final manifest = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  if (manifest['pack_version'] != 3 ||
      manifest['edition'] != 'madinah-1405h-qpc-v1' ||
      manifest['pages'] != 604) {
    throw const FormatException('Unsupported QUL 1405H print pack');
  }
  final edition = await db
      .customSelect(
        'SELECT manifest_sha256 FROM mushaf_edition WHERE id = ?',
        variables: [const Variable<String>('madinah-1405h-qpc-v1')],
      )
      .getSingleOrNull();
  if (edition == null || edition.read<String>('manifest_sha256') != digest) {
    throw const FormatException(
      'QUL print database and assets are from different packs',
    );
  }
  return manifest;
}

Future<String> _assetHash(
  QuranDatabase db,
  String id,
  String path,
  String manifestHash,
) async {
  final asset = await db
      .customSelect(
        'SELECT path, sha256 FROM mushaf_asset WHERE edition_id = ? AND id = ?',
        variables: [
          const Variable<String>('madinah-1405h-qpc-v1'),
          Variable<String>(id),
        ],
      )
      .getSingleOrNull();
  if (asset == null ||
      asset.read<String>('path') != path ||
      asset.read<String>('sha256') != manifestHash) {
    throw FormatException('QUL print asset record differs: $id');
  }
  return manifestHash;
}

Future<void> _loadVerifiedFont(
  String file,
  String family,
  String expectedHash,
  Directory? packDirectory,
) async {
  final bytes = await _loadAsset('fonts/$file', packDirectory);
  if (expectedHash != sha256.convert(bytes).toString()) {
    throw FormatException('QUL font checksum mismatch: $file');
  }
  await (FontLoader(
    family,
  )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}

Future<void> _ensureFonts(
  QuranDatabase db,
  int page,
  Map<String, dynamic> manifest,
  Directory? packDirectory,
) async {
  final hashes = manifest['font_sha256'] as Map<String, dynamic>;
  Future<String> verified(String file) => _assetHash(
    db,
    'font:$file',
    'fonts/$file',
    hashes[file] as String,
  );
  final common = await verified('quran-common.ttf');
  final v1 = await verified('surah_name_v1.ttf');
  final v2 = await verified('surah-name-v2.ttf');
  final header = await verified('QCF_SurahHeader_COLOR-Regular.ttf');
  final pageHash = await verified('p$page.ttf');
  _loadedAuxiliaryFonts ??= () async {
    await _loadVerifiedFont(
      'quran-common.ttf',
      'QPCCommon',
      common,
      packDirectory,
    );
    await _loadVerifiedFont(
      'surah_name_v1.ttf',
      'QPCSurahNameV1',
      v1,
      packDirectory,
    );
    await _loadVerifiedFont(
      'surah-name-v2.ttf',
      'QULSurahNameV2',
      v2,
      packDirectory,
    );
    await _loadVerifiedFont(
      'QCF_SurahHeader_COLOR-Regular.ttf',
      'QULSurahHeader',
      header,
      packDirectory,
    );
  }();
  _loadedPageFonts[page] ??= _loadVerifiedFont(
    'p$page.ttf',
    'QPCPage$page',
    pageHash,
    packDirectory,
  );
  await Future.wait([_loadedAuxiliaryFonts!, _loadedPageFonts[page]!]);
}

Future<PrintPage> loadPrintPage(
  QuranDatabase db,
  int page, {
  Directory? packDirectory,
}) async {
  if (page < 1 || page > 604) throw RangeError.range(page, 1, 604);
  final manifest = await _loadManifest(db, packDirectory);
  final pageRow = await db
      .customSelect(
        'SELECT font_asset_id, line_count FROM mushaf_page '
        'WHERE edition_id = ? AND page = ?',
        variables: [
          const Variable<String>('madinah-1405h-qpc-v1'),
          Variable<int>(page),
        ],
      )
      .getSingleOrNull();
  if (pageRow == null ||
      pageRow.read<String>('font_asset_id') != 'font:p$page.ttf') {
    throw FormatException('Missing QUL print page $page');
  }
  final sourceLines = await db
      .customSelect(
        'SELECT line,kind,centered,surah,first_word_id,last_word_id '
        'FROM mushaf_line WHERE edition_id = ? AND page = ? ORDER BY line',
        variables: [
          const Variable<String>('madinah-1405h-qpc-v1'),
          Variable<int>(page),
        ],
      )
      .get();
  if (sourceLines.length != pageRow.read<int>('line_count')) {
    throw FormatException('Incomplete QUL lines on page $page');
  }
  final lines = <PrintLine>[];
  for (final line in sourceLines) {
    final kind = line.read<String>('kind');
    if (!{'ayah', 'surah_name', 'basmallah'}.contains(kind)) {
      throw FormatException('Unknown QUL line kind on page $page');
    }
    final words = <PrintWord>[];
    final sourceWords = await db
        .customSelect(
          'SELECT w.id,w.glyph,w.position,a.surah,a.ayah FROM mushaf_word AS w '
          'JOIN ayah AS a ON a.id = w.ayah_id '
          'WHERE w.edition_id = ? AND w.page = ? AND w.line = ? '
          'ORDER BY w.position',
          variables: [
            const Variable<String>('madinah-1405h-qpc-v1'),
            Variable<int>(page),
            Variable<int>(line.read<int>('line')),
          ],
        )
        .get();
    final first = line.read<int?>('first_word_id');
    final last = line.read<int?>('last_word_id');
    if (sourceWords.length != (first == null ? 0 : last! - first + 1)) {
      throw FormatException('QUL word range differs on page $page');
    }
    for (final (index, word) in sourceWords.indexed) {
      if (word.read<int>('position') != index + 1 ||
          word.read<int>('id') != first! + index) {
        throw FormatException('QUL word order differs on page $page');
      }
      words.add(
        PrintWord(
          id: word.read<int>('id'),
          ref: AyahRef(
            surah: word.read<int>('surah'),
            ayah: word.read<int>('ayah'),
          ),
          glyph: word.read<String>('glyph'),
        ),
      );
    }
    if (kind == 'ayah' && words.isEmpty) {
      throw FormatException('Empty QUL ayah line on page $page');
    }
    Uint8List? headingPng;
    if (kind == 'surah_name') {
      final surah = line.read<int>('surah');
      final expected = await _assetHash(
        db,
        'header:$surah',
        'headers/$surah.png',
        (manifest['header_png_sha256'] as Map<String, dynamic>)['$surah']
            as String,
      );
      headingPng = await _loadAsset('headers/$surah.png', packDirectory);
      if (sha256.convert(headingPng).toString() != expected) {
        throw FormatException('QUL Surah header checksum mismatch: $surah');
      }
    }
    lines.add(
      PrintLine(
        number: line.read<int>('line'),
        kind: kind,
        centered: line.read<int>('centered') == 1,
        surah: line.read<int?>('surah'),
        words: words,
        headingGlyph: kind == 'surah_name'
            ? (manifest['surah_header_glyphs']
                      as Map<String, dynamic>)['${line.read<int>('surah')}']
                  as String?
            : null,
        headingPng: headingPng,
      ),
    );
  }
  if (lines.any(
    (line) =>
        line.kind == 'surah_name' &&
        (line.headingGlyph == null || line.headingPng == null),
  )) {
    throw FormatException('Missing QUL Surah header glyph on page $page');
  }
  if (lines.isEmpty ||
      lines.asMap().entries.any(
        (entry) => entry.value.number != entry.key + 1,
      )) {
    throw FormatException('Incomplete QUL lines on page $page');
  }
  await _ensureFonts(db, page, manifest, packDirectory);
  return PrintPage(number: page, lines: lines);
}
