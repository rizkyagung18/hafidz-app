import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:hafidz_app/core/database/quran_database.dart';
import 'package:hafidz_app/core/database/user_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _quranAsset = 'assets/db/quran.sqlite';
const _checksumAsset = 'assets/db/quran.sqlite.sha256';
const _printAsset = 'assets/mushaf';
const _expectedQuranVersion = 3;
const _edition = 'madinah-1405h-qpc-v1';

class LocalDatabases {
  const LocalDatabases({
    required this.quran,
    required this.user,
    this.printAssets,
  });

  final QuranDatabase quran;
  final UserDatabase user;
  final Directory? printAssets;

  Future<void> close() async {
    await quran.close();
    await user.close();
  }
}

/// Install a verified content/print pair while keeping a previous v3 pair.
Future<LocalDatabases> openLocalDatabases({
  AssetBundle? assets,
  Directory? supportDirectory,
}) async {
  final bundle = assets ?? rootBundle;
  final directory = supportDirectory ?? await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  final contentFile = File(p.join(directory.path, 'quran.sqlite'));
  final previousFile = File(p.join(directory.path, 'quran.sqlite.previous'));
  final packs = Directory(p.join(directory.path, 'mushaf-packs'));
  await packs.create(recursive: true);
  ({QuranDatabase db, Directory pack})? installed;
  try {
    final expectedHash = (await bundle.loadString(
      _checksumAsset,
    )).split(RegExp(r'\s+')).first;
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedHash)) {
      throw const FormatException('Invalid bundled Quran database checksum');
    }
    final active = await _verifiedInstalled(contentFile, packs);
    if (active != null && await _fileHash(contentFile) == expectedHash) {
      installed = active;
    } else {
      final data = await bundle.load(_quranAsset);
      final bytes = _bytes(data);
      if (sha256.convert(bytes).toString() != expectedHash) {
        installed = active ?? await _verifiedInstalled(previousFile, packs);
        if (installed == null) {
          throw const FormatException('Bundled Quran database checksum mismatch');
        }
      } else {
        await active?.db.close();
        installed = await _installBundle(
          bundle: bundle,
          bytes: bytes,
          directory: directory,
          packs: packs,
          contentFile: contentFile,
          previousFile: previousFile,
          expectedHash: expectedHash,
        );
      }
    }
  } catch (_) {
    installed =
        await _verifiedInstalled(contentFile, packs) ??
        await _verifiedInstalled(previousFile, packs);
    if (installed == null) rethrow;
  }
  try {
    final user = UserDatabase(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'user.sqlite')),
        setup: (db) => db.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    try {
      await user.customSelect('SELECT 1').getSingle();
      return LocalDatabases(
        quran: installed.db,
        user: user,
        printAssets: installed.pack,
      );
    } catch (_) {
      await user.close();
      rethrow;
    }
  } catch (_) {
    await installed.db.close();
    rethrow;
  }
}

Future<String> _fileHash(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

File _hashMarker(File file) => File('${file.path}.verified.sha256');

Future<({QuranDatabase db, Directory pack})?> _verifiedInstalled(
  File file,
  Directory packs,
) async {
  final marker = _hashMarker(file);
  if (!file.existsSync() || !marker.existsSync()) return null;
  final recorded = (await marker.readAsString()).trim();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(recorded) ||
      await _fileHash(file) != recorded) {
    return null;
  }
  final db = _openQuran(file);
  try {
    final manifestHash = await _checkVersion(db);
    final pack = Directory(p.join(packs.path, manifestHash));
    await _verifyPackFromDisk(db, pack);
    return (db: db, pack: pack);
  } on Object catch (_) {
    await db.close();
    return null;
  }
}

Future<({QuranDatabase db, Directory pack})> _installBundle({
  required AssetBundle bundle,
  required Uint8List bytes,
  required Directory directory,
  required Directory packs,
  required File contentFile,
  required File previousFile,
  required String expectedHash,
}) async {
  final temporary = File(p.join(directory.path, 'quran.sqlite.installing'));
  if (temporary.existsSync()) await temporary.delete();
  try {
    await temporary.writeAsBytes(bytes, flush: true);
    final staged = _openQuran(temporary);
    try {
      final manifestHash = await _checkVersion(staged);
      await _stagePack(bundle, staged, packs, manifestHash);
    } finally {
      await staged.close();
    }

    final old = await _verifiedInstalled(contentFile, packs);
    if (old != null) {
      await old.db.close();
      if (previousFile.existsSync()) await previousFile.delete();
      final previousMarker = _hashMarker(previousFile);
      if (previousMarker.existsSync()) await previousMarker.delete();
      await contentFile.rename(previousFile.path);
      await _hashMarker(contentFile).rename(previousMarker.path);
    } else if (contentFile.existsSync()) {
      // A v1/v2 or damaged immutable copy is replaceable; user.sqlite is separate.
      await contentFile.delete();
      final marker = _hashMarker(contentFile);
      if (marker.existsSync()) await marker.delete();
    }
    await temporary.rename(contentFile.path);
    await _hashMarker(contentFile).writeAsString(expectedHash, flush: true);
    final verified = await _verifiedInstalled(contentFile, packs);
    if (verified == null) {
      throw const FormatException(
        'Installed Quran print package failed verification',
      );
    }
    return verified;
  } finally {
    if (temporary.existsSync()) await temporary.delete();
  }
}

Future<void> _stagePack(
  AssetBundle bundle,
  QuranDatabase db,
  Directory packs,
  String manifestHash,
) async {
  final finalPack = Directory(p.join(packs.path, manifestHash));
  if (finalPack.existsSync()) {
    try {
      await _verifyPackFromDisk(db, finalPack);
      return;
    } on Object catch (_) {
      // Rebuild the damaged generated copy from the still-verified bundle.
    }
  }
  final staging = Directory(p.join(packs.path, '$manifestHash.installing'));
  if (staging.existsSync()) await staging.delete(recursive: true);
  await staging.create(recursive: true);
  try {
    final manifestData = await bundle.load('$_printAsset/manifest.json');
    final manifest = _bytes(manifestData);
    if (sha256.convert(manifest).toString() != manifestHash) {
      throw const FormatException(
        'Bundled Mushaf manifest does not match Quran database',
      );
    }
    await File(
      p.join(staging.path, 'manifest.json'),
    ).writeAsBytes(manifest, flush: true);
    final records = await _assetRecords(db, manifest);
    for (final record in records) {
      final data = await bundle.load('$_printAsset/${record.path}');
      final bytes = _bytes(data);
      if (bytes.length != record.size ||
          sha256.convert(bytes).toString() != record.digest) {
        throw FormatException(
          'Bundled Mushaf asset checksum mismatch: ${record.path}',
        );
      }
      final target = File(p.join(staging.path, record.path));
      await target.parent.create(recursive: true);
      await target.writeAsBytes(bytes, flush: true);
    }
    await _verifyPackFromDisk(db, staging);
    if (finalPack.existsSync()) await finalPack.delete(recursive: true);
    await staging.rename(finalPack.path);
  } finally {
    if (staging.existsSync()) await staging.delete(recursive: true);
  }
}

Uint8List _bytes(ByteData data) =>
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

Future<List<({String path, String digest, int size})>> _assetRecords(
  QuranDatabase db,
  Uint8List manifestBytes,
) async {
  final manifest =
      jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
  if (manifest['pack_version'] != 3 ||
      manifest['edition'] != _edition ||
      manifest['pages'] != 604) {
    throw const FormatException('Unsupported Mushaf asset manifest');
  }
  final fonts = manifest['font_sha256'] as Map<String, dynamic>;
  final headers = manifest['header_png_sha256'] as Map<String, dynamic>;
  if (fonts.length != 608 || headers.length != 114) {
    throw const FormatException('Incomplete Mushaf asset manifest');
  }
  final rows = await db
      .customSelect(
        'SELECT id,kind,path,sha256,byte_size FROM mushaf_asset WHERE edition_id = ?',
        variables: [const Variable<String>(_edition)],
      )
      .get();
  if (rows.length != 722) {
    throw const FormatException('Incomplete Mushaf database asset records');
  }
  final result = <({String path, String digest, int size})>[];
  for (final row in rows) {
    final id = row.read<String>('id');
    final kind = row.read<String>('kind');
    final path = row.read<String>('path');
    final digest = row.read<String>('sha256');
    String expectedPath;
    Object? expectedHash;
    if (kind == 'font' && id.startsWith('font:')) {
      final file = id.substring(5);
      expectedPath = 'fonts/$file';
      expectedHash = fonts[file];
    } else if (kind == 'header' && id.startsWith('header:')) {
      final number = id.substring(7);
      expectedPath = 'headers/$number.png';
      expectedHash = headers[number];
    } else {
      throw FormatException('Invalid Mushaf asset identity: $id');
    }
    if (path != expectedPath ||
        digest != expectedHash ||
        row.read<int>('byte_size') < 1) {
      throw FormatException('Mushaf asset differs from manifest: $id');
    }
    result.add((path: path, digest: digest, size: row.read<int>('byte_size')));
  }
  return result;
}

Future<void> _verifyPackFromDisk(QuranDatabase db, Directory pack) async {
  if (!pack.existsSync()) {
    throw const FormatException('Installed Mushaf pack is missing');
  }
  final manifest = await File(p.join(pack.path, 'manifest.json')).readAsBytes();
  final expected = await _checkVersion(db);
  if (sha256.convert(manifest).toString() != expected) {
    throw const FormatException(
      'Installed Mushaf manifest differs from Quran database',
    );
  }
  for (final record in await _assetRecords(db, manifest)) {
    final file = File(p.join(pack.path, record.path));
    if (!file.existsSync() ||
        await file.length() != record.size ||
        await _fileHash(file) != record.digest) {
      throw FormatException(
        'Installed Mushaf asset is damaged: ${record.path}',
      );
    }
  }
}

QuranDatabase _openQuran(File file) => QuranDatabase(
  NativeDatabase.createInBackground(
    file,
    enableMigrations: false,
    setup: (db) => db.execute('PRAGMA query_only = ON'),
  ),
);

Future<String> _checkVersion(QuranDatabase database) async {
  final pragma = await database.customSelect('PRAGMA user_version').getSingle();
  final meta = await database
      .customSelect(
        "SELECT value FROM meta WHERE key = 'db_version'",
      )
      .getSingle();
  if (pragma.read<int>('user_version') != _expectedQuranVersion ||
      meta.read<String>('value') != '$_expectedQuranVersion') {
    throw const FormatException('Unsupported Quran database version');
  }
  final edition = await database
      .customSelect(
        'SELECT manifest_sha256,page_count,pack_version FROM mushaf_edition WHERE id = ?',
        variables: [const Variable<String>(_edition)],
      )
      .getSingleOrNull();
  if (edition == null ||
      edition.read<int>('page_count') != 604 ||
      edition.read<int>('pack_version') != 3) {
    throw const FormatException('Unsupported Quran print edition');
  }
  final counts = await database
      .customSelect(
        'SELECT (SELECT COUNT(*) FROM mushaf_page) AS pages, '
        '(SELECT COUNT(*) FROM mushaf_word) AS words, '
        '(SELECT COUNT(*) FROM mushaf_asset) AS assets, '
        '(SELECT page FROM ayah WHERE surah=2 AND ayah=255) AS spot',
      )
      .getSingle();
  if (counts.read<int>('pages') != 604 ||
      counts.read<int>('words') != 83668 ||
      counts.read<int>('assets') != 722 ||
      counts.read<int>('spot') != 42) {
    throw const FormatException('Incomplete Quran print database');
  }
  final digest = edition.read<String>('manifest_sha256');
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
    throw const FormatException('Invalid Quran print manifest checksum');
  }
  return digest;
}
