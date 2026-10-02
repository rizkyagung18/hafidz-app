// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class Bookmark extends Table with TableInfo<Bookmark, BookmarkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Bookmark(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'default\'',
    defaultValue: const CustomExpression('\'default\''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ayahId,
    folder,
    note,
    color,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ayahId, folder},
  ];
  @override
  BookmarkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Bookmark createAlias(String alias) {
    return Bookmark(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(ayah_id, folder)'];
  @override
  bool get dontWriteConstraints => true;
}

class BookmarkData extends DataClass implements Insertable<BookmarkData> {
  final int id;
  final int ayahId;
  final String folder;
  final String? note;
  final String? color;
  final String createdAt;
  final String updatedAt;
  const BookmarkData({
    required this.id,
    required this.ayahId,
    required this.folder,
    this.note,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ayah_id'] = Variable<int>(ayahId);
    map['folder'] = Variable<String>(folder);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  BookmarkCompanion toCompanion(bool nullToAbsent) {
    return BookmarkCompanion(
      id: Value(id),
      ayahId: Value(ayahId),
      folder: Value(folder),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookmarkData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkData(
      id: serializer.fromJson<int>(json['id']),
      ayahId: serializer.fromJson<int>(json['ayah_id']),
      folder: serializer.fromJson<String>(json['folder']),
      note: serializer.fromJson<String?>(json['note']),
      color: serializer.fromJson<String?>(json['color']),
      createdAt: serializer.fromJson<String>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ayah_id': serializer.toJson<int>(ayahId),
      'folder': serializer.toJson<String>(folder),
      'note': serializer.toJson<String?>(note),
      'color': serializer.toJson<String?>(color),
      'created_at': serializer.toJson<String>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  BookmarkData copyWith({
    int? id,
    int? ayahId,
    String? folder,
    Value<String?> note = const Value.absent(),
    Value<String?> color = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => BookmarkData(
    id: id ?? this.id,
    ayahId: ayahId ?? this.ayahId,
    folder: folder ?? this.folder,
    note: note.present ? note.value : this.note,
    color: color.present ? color.value : this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BookmarkData copyWithCompanion(BookmarkCompanion data) {
    return BookmarkData(
      id: data.id.present ? data.id.value : this.id,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      folder: data.folder.present ? data.folder.value : this.folder,
      note: data.note.present ? data.note.value : this.note,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkData(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('folder: $folder, ')
          ..write('note: $note, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ayahId, folder, note, color, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkData &&
          other.id == this.id &&
          other.ayahId == this.ayahId &&
          other.folder == this.folder &&
          other.note == this.note &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BookmarkCompanion extends UpdateCompanion<BookmarkData> {
  final Value<int> id;
  final Value<int> ayahId;
  final Value<String> folder;
  final Value<String?> note;
  final Value<String?> color;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const BookmarkCompanion({
    this.id = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.folder = const Value.absent(),
    this.note = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BookmarkCompanion.insert({
    this.id = const Value.absent(),
    required int ayahId,
    this.folder = const Value.absent(),
    this.note = const Value.absent(),
    this.color = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : ayahId = Value(ayahId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BookmarkData> custom({
    Expression<int>? id,
    Expression<int>? ayahId,
    Expression<String>? folder,
    Expression<String>? note,
    Expression<String>? color,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ayahId != null) 'ayah_id': ayahId,
      if (folder != null) 'folder': folder,
      if (note != null) 'note': note,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BookmarkCompanion copyWith({
    Value<int>? id,
    Value<int>? ayahId,
    Value<String>? folder,
    Value<String?>? note,
    Value<String?>? color,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return BookmarkCompanion(
      id: id ?? this.id,
      ayahId: ayahId ?? this.ayahId,
      folder: folder ?? this.folder,
      note: note ?? this.note,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkCompanion(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('folder: $folder, ')
          ..write('note: $note, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class ReadingPosition extends Table
    with TableInfo<ReadingPosition, ReadingPositionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ReadingPosition(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY CHECK (id = 1)',
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (mode IN (\'mushaf\', \'list\'))',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, ayahId, page, mode, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_position';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingPositionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingPositionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPositionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  ReadingPosition createAlias(String alias) {
    return ReadingPosition(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ReadingPositionData extends DataClass
    implements Insertable<ReadingPositionData> {
  final int id;
  final int ayahId;
  final int page;
  final String mode;
  final String updatedAt;
  const ReadingPositionData({
    required this.id,
    required this.ayahId,
    required this.page,
    required this.mode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ayah_id'] = Variable<int>(ayahId);
    map['page'] = Variable<int>(page);
    map['mode'] = Variable<String>(mode);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  ReadingPositionCompanion toCompanion(bool nullToAbsent) {
    return ReadingPositionCompanion(
      id: Value(id),
      ayahId: Value(ayahId),
      page: Value(page),
      mode: Value(mode),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingPositionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPositionData(
      id: serializer.fromJson<int>(json['id']),
      ayahId: serializer.fromJson<int>(json['ayah_id']),
      page: serializer.fromJson<int>(json['page']),
      mode: serializer.fromJson<String>(json['mode']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ayah_id': serializer.toJson<int>(ayahId),
      'page': serializer.toJson<int>(page),
      'mode': serializer.toJson<String>(mode),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  ReadingPositionData copyWith({
    int? id,
    int? ayahId,
    int? page,
    String? mode,
    String? updatedAt,
  }) => ReadingPositionData(
    id: id ?? this.id,
    ayahId: ayahId ?? this.ayahId,
    page: page ?? this.page,
    mode: mode ?? this.mode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingPositionData copyWithCompanion(ReadingPositionCompanion data) {
    return ReadingPositionData(
      id: data.id.present ? data.id.value : this.id,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      page: data.page.present ? data.page.value : this.page,
      mode: data.mode.present ? data.mode.value : this.mode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionData(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('page: $page, ')
          ..write('mode: $mode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ayahId, page, mode, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPositionData &&
          other.id == this.id &&
          other.ayahId == this.ayahId &&
          other.page == this.page &&
          other.mode == this.mode &&
          other.updatedAt == this.updatedAt);
}

class ReadingPositionCompanion extends UpdateCompanion<ReadingPositionData> {
  final Value<int> id;
  final Value<int> ayahId;
  final Value<int> page;
  final Value<String> mode;
  final Value<String> updatedAt;
  const ReadingPositionCompanion({
    this.id = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.page = const Value.absent(),
    this.mode = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReadingPositionCompanion.insert({
    this.id = const Value.absent(),
    required int ayahId,
    required int page,
    required String mode,
    required String updatedAt,
  }) : ayahId = Value(ayahId),
       page = Value(page),
       mode = Value(mode),
       updatedAt = Value(updatedAt);
  static Insertable<ReadingPositionData> custom({
    Expression<int>? id,
    Expression<int>? ayahId,
    Expression<int>? page,
    Expression<String>? mode,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ayahId != null) 'ayah_id': ayahId,
      if (page != null) 'page': page,
      if (mode != null) 'mode': mode,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReadingPositionCompanion copyWith({
    Value<int>? id,
    Value<int>? ayahId,
    Value<int>? page,
    Value<String>? mode,
    Value<String>? updatedAt,
  }) {
    return ReadingPositionCompanion(
      id: id ?? this.id,
      ayahId: ayahId ?? this.ayahId,
      page: page ?? this.page,
      mode: mode ?? this.mode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionCompanion(')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('page: $page, ')
          ..write('mode: $mode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class KhatamPlan extends Table with TableInfo<KhatamPlan, KhatamPlanData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KhatamPlan(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _targetDaysMeta = const VerificationMeta(
    'targetDays',
  );
  late final GeneratedColumn<int> targetDays = GeneratedColumn<int>(
    'target_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pagesReadJsonMeta = const VerificationMeta(
    'pagesReadJson',
  );
  late final GeneratedColumn<String> pagesReadJson = GeneratedColumn<String>(
    'pages_read_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'[]\'',
    defaultValue: const CustomExpression('\'[]\''),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<String> completedAt = GeneratedColumn<String>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    targetDays,
    pagesReadJson,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'khatam_plan';
  @override
  VerificationContext validateIntegrity(
    Insertable<KhatamPlanData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('target_days')) {
      context.handle(
        _targetDaysMeta,
        targetDays.isAcceptableOrUnknown(data['target_days']!, _targetDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDaysMeta);
    }
    if (data.containsKey('pages_read_json')) {
      context.handle(
        _pagesReadJsonMeta,
        pagesReadJson.isAcceptableOrUnknown(
          data['pages_read_json']!,
          _pagesReadJsonMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KhatamPlanData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KhatamPlanData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      targetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_days'],
      )!,
      pagesReadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pages_read_json'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  KhatamPlan createAlias(String alias) {
    return KhatamPlan(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class KhatamPlanData extends DataClass implements Insertable<KhatamPlanData> {
  final int id;
  final String startedAt;
  final int targetDays;
  final String pagesReadJson;
  final String? completedAt;
  const KhatamPlanData({
    required this.id,
    required this.startedAt,
    required this.targetDays,
    required this.pagesReadJson,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<String>(startedAt);
    map['target_days'] = Variable<int>(targetDays);
    map['pages_read_json'] = Variable<String>(pagesReadJson);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<String>(completedAt);
    }
    return map;
  }

  KhatamPlanCompanion toCompanion(bool nullToAbsent) {
    return KhatamPlanCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      targetDays: Value(targetDays),
      pagesReadJson: Value(pagesReadJson),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory KhatamPlanData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KhatamPlanData(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<String>(json['started_at']),
      targetDays: serializer.fromJson<int>(json['target_days']),
      pagesReadJson: serializer.fromJson<String>(json['pages_read_json']),
      completedAt: serializer.fromJson<String?>(json['completed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'started_at': serializer.toJson<String>(startedAt),
      'target_days': serializer.toJson<int>(targetDays),
      'pages_read_json': serializer.toJson<String>(pagesReadJson),
      'completed_at': serializer.toJson<String?>(completedAt),
    };
  }

  KhatamPlanData copyWith({
    int? id,
    String? startedAt,
    int? targetDays,
    String? pagesReadJson,
    Value<String?> completedAt = const Value.absent(),
  }) => KhatamPlanData(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    targetDays: targetDays ?? this.targetDays,
    pagesReadJson: pagesReadJson ?? this.pagesReadJson,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  KhatamPlanData copyWithCompanion(KhatamPlanCompanion data) {
    return KhatamPlanData(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      targetDays: data.targetDays.present
          ? data.targetDays.value
          : this.targetDays,
      pagesReadJson: data.pagesReadJson.present
          ? data.pagesReadJson.value
          : this.pagesReadJson,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KhatamPlanData(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('targetDays: $targetDays, ')
          ..write('pagesReadJson: $pagesReadJson, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startedAt, targetDays, pagesReadJson, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KhatamPlanData &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.targetDays == this.targetDays &&
          other.pagesReadJson == this.pagesReadJson &&
          other.completedAt == this.completedAt);
}

class KhatamPlanCompanion extends UpdateCompanion<KhatamPlanData> {
  final Value<int> id;
  final Value<String> startedAt;
  final Value<int> targetDays;
  final Value<String> pagesReadJson;
  final Value<String?> completedAt;
  const KhatamPlanCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.targetDays = const Value.absent(),
    this.pagesReadJson = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  KhatamPlanCompanion.insert({
    this.id = const Value.absent(),
    required String startedAt,
    required int targetDays,
    this.pagesReadJson = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : startedAt = Value(startedAt),
       targetDays = Value(targetDays);
  static Insertable<KhatamPlanData> custom({
    Expression<int>? id,
    Expression<String>? startedAt,
    Expression<int>? targetDays,
    Expression<String>? pagesReadJson,
    Expression<String>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (targetDays != null) 'target_days': targetDays,
      if (pagesReadJson != null) 'pages_read_json': pagesReadJson,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  KhatamPlanCompanion copyWith({
    Value<int>? id,
    Value<String>? startedAt,
    Value<int>? targetDays,
    Value<String>? pagesReadJson,
    Value<String?>? completedAt,
  }) {
    return KhatamPlanCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      targetDays: targetDays ?? this.targetDays,
      pagesReadJson: pagesReadJson ?? this.pagesReadJson,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (targetDays.present) {
      map['target_days'] = Variable<int>(targetDays.value);
    }
    if (pagesReadJson.present) {
      map['pages_read_json'] = Variable<String>(pagesReadJson.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<String>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KhatamPlanCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('targetDays: $targetDays, ')
          ..write('pagesReadJson: $pagesReadJson, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class VoiceSearchHistory extends Table
    with TableInfo<VoiceSearchHistory, VoiceSearchHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  VoiceSearchHistory(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _bestKeyMeta = const VerificationMeta(
    'bestKey',
  );
  late final GeneratedColumn<String> bestKey = GeneratedColumn<String>(
    'best_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bestKey,
    confidence,
    transcript,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_search_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceSearchHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('best_key')) {
      context.handle(
        _bestKeyMeta,
        bestKey.isAcceptableOrUnknown(data['best_key']!, _bestKeyMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceSearchHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceSearchHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_key'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  VoiceSearchHistory createAlias(String alias) {
    return VoiceSearchHistory(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class VoiceSearchHistoryData extends DataClass
    implements Insertable<VoiceSearchHistoryData> {
  final int id;
  final String? bestKey;
  final double? confidence;
  final String? transcript;
  final String createdAt;
  const VoiceSearchHistoryData({
    required this.id,
    this.bestKey,
    this.confidence,
    this.transcript,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bestKey != null) {
      map['best_key'] = Variable<String>(bestKey);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  VoiceSearchHistoryCompanion toCompanion(bool nullToAbsent) {
    return VoiceSearchHistoryCompanion(
      id: Value(id),
      bestKey: bestKey == null && nullToAbsent
          ? const Value.absent()
          : Value(bestKey),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      createdAt: Value(createdAt),
    );
  }

  factory VoiceSearchHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceSearchHistoryData(
      id: serializer.fromJson<int>(json['id']),
      bestKey: serializer.fromJson<String?>(json['best_key']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'best_key': serializer.toJson<String?>(bestKey),
      'confidence': serializer.toJson<double?>(confidence),
      'transcript': serializer.toJson<String?>(transcript),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  VoiceSearchHistoryData copyWith({
    int? id,
    Value<String?> bestKey = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    String? createdAt,
  }) => VoiceSearchHistoryData(
    id: id ?? this.id,
    bestKey: bestKey.present ? bestKey.value : this.bestKey,
    confidence: confidence.present ? confidence.value : this.confidence,
    transcript: transcript.present ? transcript.value : this.transcript,
    createdAt: createdAt ?? this.createdAt,
  );
  VoiceSearchHistoryData copyWithCompanion(VoiceSearchHistoryCompanion data) {
    return VoiceSearchHistoryData(
      id: data.id.present ? data.id.value : this.id,
      bestKey: data.bestKey.present ? data.bestKey.value : this.bestKey,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceSearchHistoryData(')
          ..write('id: $id, ')
          ..write('bestKey: $bestKey, ')
          ..write('confidence: $confidence, ')
          ..write('transcript: $transcript, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bestKey, confidence, transcript, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceSearchHistoryData &&
          other.id == this.id &&
          other.bestKey == this.bestKey &&
          other.confidence == this.confidence &&
          other.transcript == this.transcript &&
          other.createdAt == this.createdAt);
}

class VoiceSearchHistoryCompanion
    extends UpdateCompanion<VoiceSearchHistoryData> {
  final Value<int> id;
  final Value<String?> bestKey;
  final Value<double?> confidence;
  final Value<String?> transcript;
  final Value<String> createdAt;
  const VoiceSearchHistoryCompanion({
    this.id = const Value.absent(),
    this.bestKey = const Value.absent(),
    this.confidence = const Value.absent(),
    this.transcript = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VoiceSearchHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.bestKey = const Value.absent(),
    this.confidence = const Value.absent(),
    this.transcript = const Value.absent(),
    required String createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<VoiceSearchHistoryData> custom({
    Expression<int>? id,
    Expression<String>? bestKey,
    Expression<double>? confidence,
    Expression<String>? transcript,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bestKey != null) 'best_key': bestKey,
      if (confidence != null) 'confidence': confidence,
      if (transcript != null) 'transcript': transcript,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VoiceSearchHistoryCompanion copyWith({
    Value<int>? id,
    Value<String?>? bestKey,
    Value<double?>? confidence,
    Value<String?>? transcript,
    Value<String>? createdAt,
  }) {
    return VoiceSearchHistoryCompanion(
      id: id ?? this.id,
      bestKey: bestKey ?? this.bestKey,
      confidence: confidence ?? this.confidence,
      transcript: transcript ?? this.transcript,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bestKey.present) {
      map['best_key'] = Variable<String>(bestKey.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceSearchHistoryCompanion(')
          ..write('id: $id, ')
          ..write('bestKey: $bestKey, ')
          ..write('confidence: $confidence, ')
          ..write('transcript: $transcript, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class PrayerCache extends Table with TableInfo<PrayerCache, PrayerCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PrayerCache(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _timesJsonMeta = const VerificationMeta(
    'timesJson',
  );
  late final GeneratedColumn<String> timesJson = GeneratedColumn<String>(
    'times_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  late final GeneratedColumn<String> fetchedAt = GeneratedColumn<String>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    locationId,
    date,
    source,
    timesJson,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('times_json')) {
      context.handle(
        _timesJsonMeta,
        timesJson.isAcceptableOrUnknown(data['times_json']!, _timesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_timesJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {locationId, date};
  @override
  PrayerCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerCacheData(
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      timesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  PrayerCache createAlias(String alias) {
    return PrayerCache(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(location_id, date)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class PrayerCacheData extends DataClass implements Insertable<PrayerCacheData> {
  final String locationId;
  final String date;
  final String source;
  final String timesJson;
  final String fetchedAt;
  const PrayerCacheData({
    required this.locationId,
    required this.date,
    required this.source,
    required this.timesJson,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['location_id'] = Variable<String>(locationId);
    map['date'] = Variable<String>(date);
    map['source'] = Variable<String>(source);
    map['times_json'] = Variable<String>(timesJson);
    map['fetched_at'] = Variable<String>(fetchedAt);
    return map;
  }

  PrayerCacheCompanion toCompanion(bool nullToAbsent) {
    return PrayerCacheCompanion(
      locationId: Value(locationId),
      date: Value(date),
      source: Value(source),
      timesJson: Value(timesJson),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PrayerCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerCacheData(
      locationId: serializer.fromJson<String>(json['location_id']),
      date: serializer.fromJson<String>(json['date']),
      source: serializer.fromJson<String>(json['source']),
      timesJson: serializer.fromJson<String>(json['times_json']),
      fetchedAt: serializer.fromJson<String>(json['fetched_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'location_id': serializer.toJson<String>(locationId),
      'date': serializer.toJson<String>(date),
      'source': serializer.toJson<String>(source),
      'times_json': serializer.toJson<String>(timesJson),
      'fetched_at': serializer.toJson<String>(fetchedAt),
    };
  }

  PrayerCacheData copyWith({
    String? locationId,
    String? date,
    String? source,
    String? timesJson,
    String? fetchedAt,
  }) => PrayerCacheData(
    locationId: locationId ?? this.locationId,
    date: date ?? this.date,
    source: source ?? this.source,
    timesJson: timesJson ?? this.timesJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  PrayerCacheData copyWithCompanion(PrayerCacheCompanion data) {
    return PrayerCacheData(
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      date: data.date.present ? data.date.value : this.date,
      source: data.source.present ? data.source.value : this.source,
      timesJson: data.timesJson.present ? data.timesJson.value : this.timesJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerCacheData(')
          ..write('locationId: $locationId, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('timesJson: $timesJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(locationId, date, source, timesJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerCacheData &&
          other.locationId == this.locationId &&
          other.date == this.date &&
          other.source == this.source &&
          other.timesJson == this.timesJson &&
          other.fetchedAt == this.fetchedAt);
}

class PrayerCacheCompanion extends UpdateCompanion<PrayerCacheData> {
  final Value<String> locationId;
  final Value<String> date;
  final Value<String> source;
  final Value<String> timesJson;
  final Value<String> fetchedAt;
  final Value<int> rowid;
  const PrayerCacheCompanion({
    this.locationId = const Value.absent(),
    this.date = const Value.absent(),
    this.source = const Value.absent(),
    this.timesJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerCacheCompanion.insert({
    required String locationId,
    required String date,
    required String source,
    required String timesJson,
    required String fetchedAt,
    this.rowid = const Value.absent(),
  }) : locationId = Value(locationId),
       date = Value(date),
       source = Value(source),
       timesJson = Value(timesJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<PrayerCacheData> custom({
    Expression<String>? locationId,
    Expression<String>? date,
    Expression<String>? source,
    Expression<String>? timesJson,
    Expression<String>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (locationId != null) 'location_id': locationId,
      if (date != null) 'date': date,
      if (source != null) 'source': source,
      if (timesJson != null) 'times_json': timesJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerCacheCompanion copyWith({
    Value<String>? locationId,
    Value<String>? date,
    Value<String>? source,
    Value<String>? timesJson,
    Value<String>? fetchedAt,
    Value<int>? rowid,
  }) {
    return PrayerCacheCompanion(
      locationId: locationId ?? this.locationId,
      date: date ?? this.date,
      source: source ?? this.source,
      timesJson: timesJson ?? this.timesJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (timesJson.present) {
      map['times_json'] = Variable<String>(timesJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<String>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerCacheCompanion(')
          ..write('locationId: $locationId, ')
          ..write('date: $date, ')
          ..write('source: $source, ')
          ..write('timesJson: $timesJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AdzanSetting extends Table
    with TableInfo<AdzanSetting, AdzanSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AdzanSetting(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerMeta = const VerificationMeta('prayer');
  late final GeneratedColumn<String> prayer = GeneratedColumn<String>(
    'prayer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'PRIMARY KEY CHECK (prayer IN (\'imsak\', \'subuh\', \'terbit\', \'dhuha\', \'dzuhur\', \'ashar\', \'maghrib\', \'isya\'))',
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  late final GeneratedColumn<int> enabled = GeneratedColumn<int>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  late final GeneratedColumn<String> sound = GeneratedColumn<String>(
    'sound',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'adzan_makkah\'',
    defaultValue: const CustomExpression('\'adzan_makkah\''),
  );
  static const VerificationMeta _preMinutesMeta = const VerificationMeta(
    'preMinutes',
  );
  late final GeneratedColumn<int> preMinutes = GeneratedColumn<int>(
    'pre_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _offsetMinutesMeta = const VerificationMeta(
    'offsetMinutes',
  );
  late final GeneratedColumn<int> offsetMinutes = GeneratedColumn<int>(
    'offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    prayer,
    enabled,
    sound,
    preMinutes,
    offsetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adzan_setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdzanSettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer')) {
      context.handle(
        _prayerMeta,
        prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('pre_minutes')) {
      context.handle(
        _preMinutesMeta,
        preMinutes.isAcceptableOrUnknown(data['pre_minutes']!, _preMinutesMeta),
      );
    }
    if (data.containsKey('offset_minutes')) {
      context.handle(
        _offsetMinutesMeta,
        offsetMinutes.isAcceptableOrUnknown(
          data['offset_minutes']!,
          _offsetMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayer};
  @override
  AdzanSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdzanSettingData(
      prayer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enabled'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound'],
      )!,
      preMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pre_minutes'],
      )!,
      offsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}offset_minutes'],
      )!,
    );
  }

  @override
  AdzanSetting createAlias(String alias) {
    return AdzanSetting(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AdzanSettingData extends DataClass
    implements Insertable<AdzanSettingData> {
  final String? prayer;
  final int enabled;
  final String sound;
  final int preMinutes;
  final int offsetMinutes;
  const AdzanSettingData({
    this.prayer,
    required this.enabled,
    required this.sound,
    required this.preMinutes,
    required this.offsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || prayer != null) {
      map['prayer'] = Variable<String>(prayer);
    }
    map['enabled'] = Variable<int>(enabled);
    map['sound'] = Variable<String>(sound);
    map['pre_minutes'] = Variable<int>(preMinutes);
    map['offset_minutes'] = Variable<int>(offsetMinutes);
    return map;
  }

  AdzanSettingCompanion toCompanion(bool nullToAbsent) {
    return AdzanSettingCompanion(
      prayer: prayer == null && nullToAbsent
          ? const Value.absent()
          : Value(prayer),
      enabled: Value(enabled),
      sound: Value(sound),
      preMinutes: Value(preMinutes),
      offsetMinutes: Value(offsetMinutes),
    );
  }

  factory AdzanSettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdzanSettingData(
      prayer: serializer.fromJson<String?>(json['prayer']),
      enabled: serializer.fromJson<int>(json['enabled']),
      sound: serializer.fromJson<String>(json['sound']),
      preMinutes: serializer.fromJson<int>(json['pre_minutes']),
      offsetMinutes: serializer.fromJson<int>(json['offset_minutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayer': serializer.toJson<String?>(prayer),
      'enabled': serializer.toJson<int>(enabled),
      'sound': serializer.toJson<String>(sound),
      'pre_minutes': serializer.toJson<int>(preMinutes),
      'offset_minutes': serializer.toJson<int>(offsetMinutes),
    };
  }

  AdzanSettingData copyWith({
    Value<String?> prayer = const Value.absent(),
    int? enabled,
    String? sound,
    int? preMinutes,
    int? offsetMinutes,
  }) => AdzanSettingData(
    prayer: prayer.present ? prayer.value : this.prayer,
    enabled: enabled ?? this.enabled,
    sound: sound ?? this.sound,
    preMinutes: preMinutes ?? this.preMinutes,
    offsetMinutes: offsetMinutes ?? this.offsetMinutes,
  );
  AdzanSettingData copyWithCompanion(AdzanSettingCompanion data) {
    return AdzanSettingData(
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      sound: data.sound.present ? data.sound.value : this.sound,
      preMinutes: data.preMinutes.present
          ? data.preMinutes.value
          : this.preMinutes,
      offsetMinutes: data.offsetMinutes.present
          ? data.offsetMinutes.value
          : this.offsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdzanSettingData(')
          ..write('prayer: $prayer, ')
          ..write('enabled: $enabled, ')
          ..write('sound: $sound, ')
          ..write('preMinutes: $preMinutes, ')
          ..write('offsetMinutes: $offsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(prayer, enabled, sound, preMinutes, offsetMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdzanSettingData &&
          other.prayer == this.prayer &&
          other.enabled == this.enabled &&
          other.sound == this.sound &&
          other.preMinutes == this.preMinutes &&
          other.offsetMinutes == this.offsetMinutes);
}

class AdzanSettingCompanion extends UpdateCompanion<AdzanSettingData> {
  final Value<String?> prayer;
  final Value<int> enabled;
  final Value<String> sound;
  final Value<int> preMinutes;
  final Value<int> offsetMinutes;
  final Value<int> rowid;
  const AdzanSettingCompanion({
    this.prayer = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sound = const Value.absent(),
    this.preMinutes = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdzanSettingCompanion.insert({
    this.prayer = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sound = const Value.absent(),
    this.preMinutes = const Value.absent(),
    this.offsetMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AdzanSettingData> custom({
    Expression<String>? prayer,
    Expression<int>? enabled,
    Expression<String>? sound,
    Expression<int>? preMinutes,
    Expression<int>? offsetMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayer != null) 'prayer': prayer,
      if (enabled != null) 'enabled': enabled,
      if (sound != null) 'sound': sound,
      if (preMinutes != null) 'pre_minutes': preMinutes,
      if (offsetMinutes != null) 'offset_minutes': offsetMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdzanSettingCompanion copyWith({
    Value<String?>? prayer,
    Value<int>? enabled,
    Value<String>? sound,
    Value<int>? preMinutes,
    Value<int>? offsetMinutes,
    Value<int>? rowid,
  }) {
    return AdzanSettingCompanion(
      prayer: prayer ?? this.prayer,
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      preMinutes: preMinutes ?? this.preMinutes,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayer.present) {
      map['prayer'] = Variable<String>(prayer.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<int>(enabled.value);
    }
    if (sound.present) {
      map['sound'] = Variable<String>(sound.value);
    }
    if (preMinutes.present) {
      map['pre_minutes'] = Variable<int>(preMinutes.value);
    }
    if (offsetMinutes.present) {
      map['offset_minutes'] = Variable<int>(offsetMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdzanSettingCompanion(')
          ..write('prayer: $prayer, ')
          ..write('enabled: $enabled, ')
          ..write('sound: $sound, ')
          ..write('preMinutes: $preMinutes, ')
          ..write('offsetMinutes: $offsetMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AudioDownload extends Table
    with TableInfo<AudioDownload, AudioDownloadData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AudioDownload(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _reciterIdMeta = const VerificationMeta(
    'reciterId',
  );
  late final GeneratedColumn<String> reciterId = GeneratedColumn<String>(
    'reciter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
    'surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  late final GeneratedColumn<String> downloadedAt = GeneratedColumn<String>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    reciterId,
    surah,
    path,
    bytes,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_download';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioDownloadData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reciter_id')) {
      context.handle(
        _reciterIdMeta,
        reciterId.isAcceptableOrUnknown(data['reciter_id']!, _reciterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reciterIdMeta);
    }
    if (data.containsKey('surah')) {
      context.handle(
        _surahMeta,
        surah.isAcceptableOrUnknown(data['surah']!, _surahMeta),
      );
    } else if (isInserting) {
      context.missing(_surahMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {reciterId, surah};
  @override
  AudioDownloadData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioDownloadData(
      reciterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter_id'],
      )!,
      surah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  AudioDownload createAlias(String alias) {
    return AudioDownload(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(reciter_id, surah)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class AudioDownloadData extends DataClass
    implements Insertable<AudioDownloadData> {
  final String reciterId;
  final int surah;
  final String path;
  final int? bytes;
  final String downloadedAt;
  const AudioDownloadData({
    required this.reciterId,
    required this.surah,
    required this.path,
    this.bytes,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reciter_id'] = Variable<String>(reciterId);
    map['surah'] = Variable<int>(surah);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || bytes != null) {
      map['bytes'] = Variable<int>(bytes);
    }
    map['downloaded_at'] = Variable<String>(downloadedAt);
    return map;
  }

  AudioDownloadCompanion toCompanion(bool nullToAbsent) {
    return AudioDownloadCompanion(
      reciterId: Value(reciterId),
      surah: Value(surah),
      path: Value(path),
      bytes: bytes == null && nullToAbsent
          ? const Value.absent()
          : Value(bytes),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory AudioDownloadData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioDownloadData(
      reciterId: serializer.fromJson<String>(json['reciter_id']),
      surah: serializer.fromJson<int>(json['surah']),
      path: serializer.fromJson<String>(json['path']),
      bytes: serializer.fromJson<int?>(json['bytes']),
      downloadedAt: serializer.fromJson<String>(json['downloaded_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'reciter_id': serializer.toJson<String>(reciterId),
      'surah': serializer.toJson<int>(surah),
      'path': serializer.toJson<String>(path),
      'bytes': serializer.toJson<int?>(bytes),
      'downloaded_at': serializer.toJson<String>(downloadedAt),
    };
  }

  AudioDownloadData copyWith({
    String? reciterId,
    int? surah,
    String? path,
    Value<int?> bytes = const Value.absent(),
    String? downloadedAt,
  }) => AudioDownloadData(
    reciterId: reciterId ?? this.reciterId,
    surah: surah ?? this.surah,
    path: path ?? this.path,
    bytes: bytes.present ? bytes.value : this.bytes,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  AudioDownloadData copyWithCompanion(AudioDownloadCompanion data) {
    return AudioDownloadData(
      reciterId: data.reciterId.present ? data.reciterId.value : this.reciterId,
      surah: data.surah.present ? data.surah.value : this.surah,
      path: data.path.present ? data.path.value : this.path,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioDownloadData(')
          ..write('reciterId: $reciterId, ')
          ..write('surah: $surah, ')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(reciterId, surah, path, bytes, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioDownloadData &&
          other.reciterId == this.reciterId &&
          other.surah == this.surah &&
          other.path == this.path &&
          other.bytes == this.bytes &&
          other.downloadedAt == this.downloadedAt);
}

class AudioDownloadCompanion extends UpdateCompanion<AudioDownloadData> {
  final Value<String> reciterId;
  final Value<int> surah;
  final Value<String> path;
  final Value<int?> bytes;
  final Value<String> downloadedAt;
  final Value<int> rowid;
  const AudioDownloadCompanion({
    this.reciterId = const Value.absent(),
    this.surah = const Value.absent(),
    this.path = const Value.absent(),
    this.bytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioDownloadCompanion.insert({
    required String reciterId,
    required int surah,
    required String path,
    this.bytes = const Value.absent(),
    required String downloadedAt,
    this.rowid = const Value.absent(),
  }) : reciterId = Value(reciterId),
       surah = Value(surah),
       path = Value(path),
       downloadedAt = Value(downloadedAt);
  static Insertable<AudioDownloadData> custom({
    Expression<String>? reciterId,
    Expression<int>? surah,
    Expression<String>? path,
    Expression<int>? bytes,
    Expression<String>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (reciterId != null) 'reciter_id': reciterId,
      if (surah != null) 'surah': surah,
      if (path != null) 'path': path,
      if (bytes != null) 'bytes': bytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioDownloadCompanion copyWith({
    Value<String>? reciterId,
    Value<int>? surah,
    Value<String>? path,
    Value<int?>? bytes,
    Value<String>? downloadedAt,
    Value<int>? rowid,
  }) {
    return AudioDownloadCompanion(
      reciterId: reciterId ?? this.reciterId,
      surah: surah ?? this.surah,
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (reciterId.present) {
      map['reciter_id'] = Variable<String>(reciterId.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<String>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioDownloadCompanion(')
          ..write('reciterId: $reciterId, ')
          ..write('surah: $surah, ')
          ..write('path: $path, ')
          ..write('bytes: $bytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TasbihCounter extends Table
    with TableInfo<TasbihCounter, TasbihCounterData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TasbihCounter(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, count, target, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_counter';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasbihCounterData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihCounterData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihCounterData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  TasbihCounter createAlias(String alias) {
    return TasbihCounter(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TasbihCounterData extends DataClass
    implements Insertable<TasbihCounterData> {
  final int id;
  final String label;
  final int count;
  final int? target;
  final String updatedAt;
  const TasbihCounterData({
    required this.id,
    required this.label,
    required this.count,
    this.target,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<int>(target);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  TasbihCounterCompanion toCompanion(bool nullToAbsent) {
    return TasbihCounterCompanion(
      id: Value(id),
      label: Value(label),
      count: Value(count),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      updatedAt: Value(updatedAt),
    );
  }

  factory TasbihCounterData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihCounterData(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      count: serializer.fromJson<int>(json['count']),
      target: serializer.fromJson<int?>(json['target']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'count': serializer.toJson<int>(count),
      'target': serializer.toJson<int?>(target),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  TasbihCounterData copyWith({
    int? id,
    String? label,
    int? count,
    Value<int?> target = const Value.absent(),
    String? updatedAt,
  }) => TasbihCounterData(
    id: id ?? this.id,
    label: label ?? this.label,
    count: count ?? this.count,
    target: target.present ? target.value : this.target,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TasbihCounterData copyWithCompanion(TasbihCounterCompanion data) {
    return TasbihCounterData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      count: data.count.present ? data.count.value : this.count,
      target: data.target.present ? data.target.value : this.target,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihCounterData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('count: $count, ')
          ..write('target: $target, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, count, target, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihCounterData &&
          other.id == this.id &&
          other.label == this.label &&
          other.count == this.count &&
          other.target == this.target &&
          other.updatedAt == this.updatedAt);
}

class TasbihCounterCompanion extends UpdateCompanion<TasbihCounterData> {
  final Value<int> id;
  final Value<String> label;
  final Value<int> count;
  final Value<int?> target;
  final Value<String> updatedAt;
  const TasbihCounterCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.count = const Value.absent(),
    this.target = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasbihCounterCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    this.count = const Value.absent(),
    this.target = const Value.absent(),
    required String updatedAt,
  }) : label = Value(label),
       updatedAt = Value(updatedAt);
  static Insertable<TasbihCounterData> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? count,
    Expression<int>? target,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (count != null) 'count': count,
      if (target != null) 'target': target,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasbihCounterCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<int>? count,
    Value<int?>? target,
    Value<String>? updatedAt,
  }) {
    return TasbihCounterCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      count: count ?? this.count,
      target: target ?? this.target,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihCounterCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('count: $count, ')
          ..write('target: $target, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class KvSetting extends Table with TableInfo<KvSetting, KvSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KvSetting(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvSettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvSettingData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  KvSetting createAlias(String alias) {
    return KvSetting(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class KvSettingData extends DataClass implements Insertable<KvSettingData> {
  final String? key;
  final String value;
  const KvSettingData({this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    map['value'] = Variable<String>(value);
    return map;
  }

  KvSettingCompanion toCompanion(bool nullToAbsent) {
    return KvSettingCompanion(
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      value: Value(value),
    );
  }

  factory KvSettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvSettingData(
      key: serializer.fromJson<String?>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String?>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvSettingData copyWith({
    Value<String?> key = const Value.absent(),
    String? value,
  }) => KvSettingData(
    key: key.present ? key.value : this.key,
    value: value ?? this.value,
  );
  KvSettingData copyWithCompanion(KvSettingCompanion data) {
    return KvSettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvSettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvSettingData &&
          other.key == this.key &&
          other.value == this.value);
}

class KvSettingCompanion extends UpdateCompanion<KvSettingData> {
  final Value<String?> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvSettingCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvSettingCompanion.insert({
    this.key = const Value.absent(),
    required String value,
    this.rowid = const Value.absent(),
  }) : value = Value(value);
  static Insertable<KvSettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvSettingCompanion copyWith({
    Value<String?>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvSettingCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvSettingCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final Bookmark bookmark = Bookmark(this);
  late final ReadingPosition readingPosition = ReadingPosition(this);
  late final KhatamPlan khatamPlan = KhatamPlan(this);
  late final VoiceSearchHistory voiceSearchHistory = VoiceSearchHistory(this);
  late final PrayerCache prayerCache = PrayerCache(this);
  late final AdzanSetting adzanSetting = AdzanSetting(this);
  late final AudioDownload audioDownload = AudioDownload(this);
  late final TasbihCounter tasbihCounter = TasbihCounter(this);
  late final KvSetting kvSetting = KvSetting(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmark,
    readingPosition,
    khatamPlan,
    voiceSearchHistory,
    prayerCache,
    adzanSetting,
    audioDownload,
    tasbihCounter,
    kvSetting,
  ];
}

typedef $BookmarkCreateCompanionBuilder =
    BookmarkCompanion Function({
      Value<int> id,
      required int ayahId,
      Value<String> folder,
      Value<String?> note,
      Value<String?> color,
      required String createdAt,
      required String updatedAt,
    });
typedef $BookmarkUpdateCompanionBuilder =
    BookmarkCompanion Function({
      Value<int> id,
      Value<int> ayahId,
      Value<String> folder,
      Value<String?> note,
      Value<String?> color,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $BookmarkFilterComposer extends Composer<_$UserDatabase, Bookmark> {
  $BookmarkFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $BookmarkOrderingComposer extends Composer<_$UserDatabase, Bookmark> {
  $BookmarkOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BookmarkAnnotationComposer extends Composer<_$UserDatabase, Bookmark> {
  $BookmarkAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $BookmarkTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          Bookmark,
          BookmarkData,
          $BookmarkFilterComposer,
          $BookmarkOrderingComposer,
          $BookmarkAnnotationComposer,
          $BookmarkCreateCompanionBuilder,
          $BookmarkUpdateCompanionBuilder,
          (
            BookmarkData,
            BaseReferences<_$UserDatabase, Bookmark, BookmarkData>,
          ),
          BookmarkData,
          PrefetchHooks Function()
        > {
  $BookmarkTableManager(_$UserDatabase db, Bookmark table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BookmarkFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BookmarkOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BookmarkAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<String> folder = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => BookmarkCompanion(
                id: id,
                ayahId: ayahId,
                folder: folder,
                note: note,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ayahId,
                Value<String> folder = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> color = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => BookmarkCompanion.insert(
                id: id,
                ayahId: ayahId,
                folder: folder,
                note: note,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Bookmark, BookmarkData>(table),
                  BaseReferences<_$UserDatabase, Bookmark, BookmarkData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BookmarkProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      Bookmark,
      BookmarkData,
      $BookmarkFilterComposer,
      $BookmarkOrderingComposer,
      $BookmarkAnnotationComposer,
      $BookmarkCreateCompanionBuilder,
      $BookmarkUpdateCompanionBuilder,
      (BookmarkData, BaseReferences<_$UserDatabase, Bookmark, BookmarkData>),
      BookmarkData,
      PrefetchHooks Function()
    >;
typedef $ReadingPositionCreateCompanionBuilder =
    ReadingPositionCompanion Function({
      Value<int> id,
      required int ayahId,
      required int page,
      required String mode,
      required String updatedAt,
    });
typedef $ReadingPositionUpdateCompanionBuilder =
    ReadingPositionCompanion Function({
      Value<int> id,
      Value<int> ayahId,
      Value<int> page,
      Value<String> mode,
      Value<String> updatedAt,
    });

class $ReadingPositionFilterComposer
    extends Composer<_$UserDatabase, ReadingPosition> {
  $ReadingPositionFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ReadingPositionOrderingComposer
    extends Composer<_$UserDatabase, ReadingPosition> {
  $ReadingPositionOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahId => $composableBuilder(
    column: $table.ayahId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ReadingPositionAnnotationComposer
    extends Composer<_$UserDatabase, ReadingPosition> {
  $ReadingPositionAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $ReadingPositionTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          ReadingPosition,
          ReadingPositionData,
          $ReadingPositionFilterComposer,
          $ReadingPositionOrderingComposer,
          $ReadingPositionAnnotationComposer,
          $ReadingPositionCreateCompanionBuilder,
          $ReadingPositionUpdateCompanionBuilder,
          (
            ReadingPositionData,
            BaseReferences<
              _$UserDatabase,
              ReadingPosition,
              ReadingPositionData
            >,
          ),
          ReadingPositionData,
          PrefetchHooks Function()
        > {
  $ReadingPositionTableManager(_$UserDatabase db, ReadingPosition table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ReadingPositionFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ReadingPositionOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ReadingPositionAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => ReadingPositionCompanion(
                id: id,
                ayahId: ayahId,
                page: page,
                mode: mode,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ayahId,
                required int page,
                required String mode,
                required String updatedAt,
              }) => ReadingPositionCompanion.insert(
                id: id,
                ayahId: ayahId,
                page: page,
                mode: mode,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ReadingPosition, ReadingPositionData>(table),
                  BaseReferences<
                    _$UserDatabase,
                    ReadingPosition,
                    ReadingPositionData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ReadingPositionProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      ReadingPosition,
      ReadingPositionData,
      $ReadingPositionFilterComposer,
      $ReadingPositionOrderingComposer,
      $ReadingPositionAnnotationComposer,
      $ReadingPositionCreateCompanionBuilder,
      $ReadingPositionUpdateCompanionBuilder,
      (
        ReadingPositionData,
        BaseReferences<_$UserDatabase, ReadingPosition, ReadingPositionData>,
      ),
      ReadingPositionData,
      PrefetchHooks Function()
    >;
typedef $KhatamPlanCreateCompanionBuilder =
    KhatamPlanCompanion Function({
      Value<int> id,
      required String startedAt,
      required int targetDays,
      Value<String> pagesReadJson,
      Value<String?> completedAt,
    });
typedef $KhatamPlanUpdateCompanionBuilder =
    KhatamPlanCompanion Function({
      Value<int> id,
      Value<String> startedAt,
      Value<int> targetDays,
      Value<String> pagesReadJson,
      Value<String?> completedAt,
    });

class $KhatamPlanFilterComposer extends Composer<_$UserDatabase, KhatamPlan> {
  $KhatamPlanFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pagesReadJson => $composableBuilder(
    column: $table.pagesReadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $KhatamPlanOrderingComposer extends Composer<_$UserDatabase, KhatamPlan> {
  $KhatamPlanOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pagesReadJson => $composableBuilder(
    column: $table.pagesReadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $KhatamPlanAnnotationComposer
    extends Composer<_$UserDatabase, KhatamPlan> {
  $KhatamPlanAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pagesReadJson => $composableBuilder(
    column: $table.pagesReadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $KhatamPlanTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          KhatamPlan,
          KhatamPlanData,
          $KhatamPlanFilterComposer,
          $KhatamPlanOrderingComposer,
          $KhatamPlanAnnotationComposer,
          $KhatamPlanCreateCompanionBuilder,
          $KhatamPlanUpdateCompanionBuilder,
          (
            KhatamPlanData,
            BaseReferences<_$UserDatabase, KhatamPlan, KhatamPlanData>,
          ),
          KhatamPlanData,
          PrefetchHooks Function()
        > {
  $KhatamPlanTableManager(_$UserDatabase db, KhatamPlan table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $KhatamPlanFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $KhatamPlanOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $KhatamPlanAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<int> targetDays = const Value.absent(),
                Value<String> pagesReadJson = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
              }) => KhatamPlanCompanion(
                id: id,
                startedAt: startedAt,
                targetDays: targetDays,
                pagesReadJson: pagesReadJson,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startedAt,
                required int targetDays,
                Value<String> pagesReadJson = const Value.absent(),
                Value<String?> completedAt = const Value.absent(),
              }) => KhatamPlanCompanion.insert(
                id: id,
                startedAt: startedAt,
                targetDays: targetDays,
                pagesReadJson: pagesReadJson,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<KhatamPlan, KhatamPlanData>(table),
                  BaseReferences<_$UserDatabase, KhatamPlan, KhatamPlanData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $KhatamPlanProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      KhatamPlan,
      KhatamPlanData,
      $KhatamPlanFilterComposer,
      $KhatamPlanOrderingComposer,
      $KhatamPlanAnnotationComposer,
      $KhatamPlanCreateCompanionBuilder,
      $KhatamPlanUpdateCompanionBuilder,
      (
        KhatamPlanData,
        BaseReferences<_$UserDatabase, KhatamPlan, KhatamPlanData>,
      ),
      KhatamPlanData,
      PrefetchHooks Function()
    >;
typedef $VoiceSearchHistoryCreateCompanionBuilder =
    VoiceSearchHistoryCompanion Function({
      Value<int> id,
      Value<String?> bestKey,
      Value<double?> confidence,
      Value<String?> transcript,
      required String createdAt,
    });
typedef $VoiceSearchHistoryUpdateCompanionBuilder =
    VoiceSearchHistoryCompanion Function({
      Value<int> id,
      Value<String?> bestKey,
      Value<double?> confidence,
      Value<String?> transcript,
      Value<String> createdAt,
    });

class $VoiceSearchHistoryFilterComposer
    extends Composer<_$UserDatabase, VoiceSearchHistory> {
  $VoiceSearchHistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestKey => $composableBuilder(
    column: $table.bestKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $VoiceSearchHistoryOrderingComposer
    extends Composer<_$UserDatabase, VoiceSearchHistory> {
  $VoiceSearchHistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestKey => $composableBuilder(
    column: $table.bestKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $VoiceSearchHistoryAnnotationComposer
    extends Composer<_$UserDatabase, VoiceSearchHistory> {
  $VoiceSearchHistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bestKey =>
      $composableBuilder(column: $table.bestKey, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $VoiceSearchHistoryTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          VoiceSearchHistory,
          VoiceSearchHistoryData,
          $VoiceSearchHistoryFilterComposer,
          $VoiceSearchHistoryOrderingComposer,
          $VoiceSearchHistoryAnnotationComposer,
          $VoiceSearchHistoryCreateCompanionBuilder,
          $VoiceSearchHistoryUpdateCompanionBuilder,
          (
            VoiceSearchHistoryData,
            BaseReferences<
              _$UserDatabase,
              VoiceSearchHistory,
              VoiceSearchHistoryData
            >,
          ),
          VoiceSearchHistoryData,
          PrefetchHooks Function()
        > {
  $VoiceSearchHistoryTableManager(_$UserDatabase db, VoiceSearchHistory table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $VoiceSearchHistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $VoiceSearchHistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $VoiceSearchHistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> bestKey = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => VoiceSearchHistoryCompanion(
                id: id,
                bestKey: bestKey,
                confidence: confidence,
                transcript: transcript,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> bestKey = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                required String createdAt,
              }) => VoiceSearchHistoryCompanion.insert(
                id: id,
                bestKey: bestKey,
                confidence: confidence,
                transcript: transcript,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<VoiceSearchHistory, VoiceSearchHistoryData>(
                    table,
                  ),
                  BaseReferences<
                    _$UserDatabase,
                    VoiceSearchHistory,
                    VoiceSearchHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $VoiceSearchHistoryProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      VoiceSearchHistory,
      VoiceSearchHistoryData,
      $VoiceSearchHistoryFilterComposer,
      $VoiceSearchHistoryOrderingComposer,
      $VoiceSearchHistoryAnnotationComposer,
      $VoiceSearchHistoryCreateCompanionBuilder,
      $VoiceSearchHistoryUpdateCompanionBuilder,
      (
        VoiceSearchHistoryData,
        BaseReferences<
          _$UserDatabase,
          VoiceSearchHistory,
          VoiceSearchHistoryData
        >,
      ),
      VoiceSearchHistoryData,
      PrefetchHooks Function()
    >;
typedef $PrayerCacheCreateCompanionBuilder =
    PrayerCacheCompanion Function({
      required String locationId,
      required String date,
      required String source,
      required String timesJson,
      required String fetchedAt,
      Value<int> rowid,
    });
typedef $PrayerCacheUpdateCompanionBuilder =
    PrayerCacheCompanion Function({
      Value<String> locationId,
      Value<String> date,
      Value<String> source,
      Value<String> timesJson,
      Value<String> fetchedAt,
      Value<int> rowid,
    });

class $PrayerCacheFilterComposer extends Composer<_$UserDatabase, PrayerCache> {
  $PrayerCacheFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timesJson => $composableBuilder(
    column: $table.timesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $PrayerCacheOrderingComposer
    extends Composer<_$UserDatabase, PrayerCache> {
  $PrayerCacheOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timesJson => $composableBuilder(
    column: $table.timesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PrayerCacheAnnotationComposer
    extends Composer<_$UserDatabase, PrayerCache> {
  $PrayerCacheAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get timesJson =>
      $composableBuilder(column: $table.timesJson, builder: (column) => column);

  GeneratedColumn<String> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $PrayerCacheTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          PrayerCache,
          PrayerCacheData,
          $PrayerCacheFilterComposer,
          $PrayerCacheOrderingComposer,
          $PrayerCacheAnnotationComposer,
          $PrayerCacheCreateCompanionBuilder,
          $PrayerCacheUpdateCompanionBuilder,
          (
            PrayerCacheData,
            BaseReferences<_$UserDatabase, PrayerCache, PrayerCacheData>,
          ),
          PrayerCacheData,
          PrefetchHooks Function()
        > {
  $PrayerCacheTableManager(_$UserDatabase db, PrayerCache table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PrayerCacheFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PrayerCacheOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PrayerCacheAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> locationId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> timesJson = const Value.absent(),
                Value<String> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerCacheCompanion(
                locationId: locationId,
                date: date,
                source: source,
                timesJson: timesJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String locationId,
                required String date,
                required String source,
                required String timesJson,
                required String fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => PrayerCacheCompanion.insert(
                locationId: locationId,
                date: date,
                source: source,
                timesJson: timesJson,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PrayerCache, PrayerCacheData>(table),
                  BaseReferences<_$UserDatabase, PrayerCache, PrayerCacheData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PrayerCacheProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      PrayerCache,
      PrayerCacheData,
      $PrayerCacheFilterComposer,
      $PrayerCacheOrderingComposer,
      $PrayerCacheAnnotationComposer,
      $PrayerCacheCreateCompanionBuilder,
      $PrayerCacheUpdateCompanionBuilder,
      (
        PrayerCacheData,
        BaseReferences<_$UserDatabase, PrayerCache, PrayerCacheData>,
      ),
      PrayerCacheData,
      PrefetchHooks Function()
    >;
typedef $AdzanSettingCreateCompanionBuilder =
    AdzanSettingCompanion Function({
      Value<String?> prayer,
      Value<int> enabled,
      Value<String> sound,
      Value<int> preMinutes,
      Value<int> offsetMinutes,
      Value<int> rowid,
    });
typedef $AdzanSettingUpdateCompanionBuilder =
    AdzanSettingCompanion Function({
      Value<String?> prayer,
      Value<int> enabled,
      Value<String> sound,
      Value<int> preMinutes,
      Value<int> offsetMinutes,
      Value<int> rowid,
    });

class $AdzanSettingFilterComposer
    extends Composer<_$UserDatabase, AdzanSetting> {
  $AdzanSettingFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preMinutes => $composableBuilder(
    column: $table.preMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $AdzanSettingOrderingComposer
    extends Composer<_$UserDatabase, AdzanSetting> {
  $AdzanSettingOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prayer => $composableBuilder(
    column: $table.prayer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preMinutes => $composableBuilder(
    column: $table.preMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AdzanSettingAnnotationComposer
    extends Composer<_$UserDatabase, AdzanSetting> {
  $AdzanSettingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<int> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<int> get preMinutes => $composableBuilder(
    column: $table.preMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get offsetMinutes => $composableBuilder(
    column: $table.offsetMinutes,
    builder: (column) => column,
  );
}

class $AdzanSettingTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          AdzanSetting,
          AdzanSettingData,
          $AdzanSettingFilterComposer,
          $AdzanSettingOrderingComposer,
          $AdzanSettingAnnotationComposer,
          $AdzanSettingCreateCompanionBuilder,
          $AdzanSettingUpdateCompanionBuilder,
          (
            AdzanSettingData,
            BaseReferences<_$UserDatabase, AdzanSetting, AdzanSettingData>,
          ),
          AdzanSettingData,
          PrefetchHooks Function()
        > {
  $AdzanSettingTableManager(_$UserDatabase db, AdzanSetting table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AdzanSettingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AdzanSettingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AdzanSettingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> prayer = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String> sound = const Value.absent(),
                Value<int> preMinutes = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdzanSettingCompanion(
                prayer: prayer,
                enabled: enabled,
                sound: sound,
                preMinutes: preMinutes,
                offsetMinutes: offsetMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> prayer = const Value.absent(),
                Value<int> enabled = const Value.absent(),
                Value<String> sound = const Value.absent(),
                Value<int> preMinutes = const Value.absent(),
                Value<int> offsetMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdzanSettingCompanion.insert(
                prayer: prayer,
                enabled: enabled,
                sound: sound,
                preMinutes: preMinutes,
                offsetMinutes: offsetMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AdzanSetting, AdzanSettingData>(table),
                  BaseReferences<
                    _$UserDatabase,
                    AdzanSetting,
                    AdzanSettingData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AdzanSettingProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      AdzanSetting,
      AdzanSettingData,
      $AdzanSettingFilterComposer,
      $AdzanSettingOrderingComposer,
      $AdzanSettingAnnotationComposer,
      $AdzanSettingCreateCompanionBuilder,
      $AdzanSettingUpdateCompanionBuilder,
      (
        AdzanSettingData,
        BaseReferences<_$UserDatabase, AdzanSetting, AdzanSettingData>,
      ),
      AdzanSettingData,
      PrefetchHooks Function()
    >;
typedef $AudioDownloadCreateCompanionBuilder =
    AudioDownloadCompanion Function({
      required String reciterId,
      required int surah,
      required String path,
      Value<int?> bytes,
      required String downloadedAt,
      Value<int> rowid,
    });
typedef $AudioDownloadUpdateCompanionBuilder =
    AudioDownloadCompanion Function({
      Value<String> reciterId,
      Value<int> surah,
      Value<String> path,
      Value<int?> bytes,
      Value<String> downloadedAt,
      Value<int> rowid,
    });

class $AudioDownloadFilterComposer
    extends Composer<_$UserDatabase, AudioDownload> {
  $AudioDownloadFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get reciterId => $composableBuilder(
    column: $table.reciterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $AudioDownloadOrderingComposer
    extends Composer<_$UserDatabase, AudioDownload> {
  $AudioDownloadOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get reciterId => $composableBuilder(
    column: $table.reciterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AudioDownloadAnnotationComposer
    extends Composer<_$UserDatabase, AudioDownload> {
  $AudioDownloadAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get reciterId =>
      $composableBuilder(column: $table.reciterId, builder: (column) => column);

  GeneratedColumn<int> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );
}

class $AudioDownloadTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          AudioDownload,
          AudioDownloadData,
          $AudioDownloadFilterComposer,
          $AudioDownloadOrderingComposer,
          $AudioDownloadAnnotationComposer,
          $AudioDownloadCreateCompanionBuilder,
          $AudioDownloadUpdateCompanionBuilder,
          (
            AudioDownloadData,
            BaseReferences<_$UserDatabase, AudioDownload, AudioDownloadData>,
          ),
          AudioDownloadData,
          PrefetchHooks Function()
        > {
  $AudioDownloadTableManager(_$UserDatabase db, AudioDownload table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AudioDownloadFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AudioDownloadOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AudioDownloadAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> reciterId = const Value.absent(),
                Value<int> surah = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int?> bytes = const Value.absent(),
                Value<String> downloadedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioDownloadCompanion(
                reciterId: reciterId,
                surah: surah,
                path: path,
                bytes: bytes,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String reciterId,
                required int surah,
                required String path,
                Value<int?> bytes = const Value.absent(),
                required String downloadedAt,
                Value<int> rowid = const Value.absent(),
              }) => AudioDownloadCompanion.insert(
                reciterId: reciterId,
                surah: surah,
                path: path,
                bytes: bytes,
                downloadedAt: downloadedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AudioDownload, AudioDownloadData>(table),
                  BaseReferences<
                    _$UserDatabase,
                    AudioDownload,
                    AudioDownloadData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AudioDownloadProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      AudioDownload,
      AudioDownloadData,
      $AudioDownloadFilterComposer,
      $AudioDownloadOrderingComposer,
      $AudioDownloadAnnotationComposer,
      $AudioDownloadCreateCompanionBuilder,
      $AudioDownloadUpdateCompanionBuilder,
      (
        AudioDownloadData,
        BaseReferences<_$UserDatabase, AudioDownload, AudioDownloadData>,
      ),
      AudioDownloadData,
      PrefetchHooks Function()
    >;
typedef $TasbihCounterCreateCompanionBuilder =
    TasbihCounterCompanion Function({
      Value<int> id,
      required String label,
      Value<int> count,
      Value<int?> target,
      required String updatedAt,
    });
typedef $TasbihCounterUpdateCompanionBuilder =
    TasbihCounterCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<int> count,
      Value<int?> target,
      Value<String> updatedAt,
    });

class $TasbihCounterFilterComposer
    extends Composer<_$UserDatabase, TasbihCounter> {
  $TasbihCounterFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TasbihCounterOrderingComposer
    extends Composer<_$UserDatabase, TasbihCounter> {
  $TasbihCounterOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TasbihCounterAnnotationComposer
    extends Composer<_$UserDatabase, TasbihCounter> {
  $TasbihCounterAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $TasbihCounterTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          TasbihCounter,
          TasbihCounterData,
          $TasbihCounterFilterComposer,
          $TasbihCounterOrderingComposer,
          $TasbihCounterAnnotationComposer,
          $TasbihCounterCreateCompanionBuilder,
          $TasbihCounterUpdateCompanionBuilder,
          (
            TasbihCounterData,
            BaseReferences<_$UserDatabase, TasbihCounter, TasbihCounterData>,
          ),
          TasbihCounterData,
          PrefetchHooks Function()
        > {
  $TasbihCounterTableManager(_$UserDatabase db, TasbihCounter table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TasbihCounterFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TasbihCounterOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TasbihCounterAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => TasbihCounterCompanion(
                id: id,
                label: label,
                count: count,
                target: target,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                Value<int> count = const Value.absent(),
                Value<int?> target = const Value.absent(),
                required String updatedAt,
              }) => TasbihCounterCompanion.insert(
                id: id,
                label: label,
                count: count,
                target: target,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TasbihCounter, TasbihCounterData>(table),
                  BaseReferences<
                    _$UserDatabase,
                    TasbihCounter,
                    TasbihCounterData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TasbihCounterProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      TasbihCounter,
      TasbihCounterData,
      $TasbihCounterFilterComposer,
      $TasbihCounterOrderingComposer,
      $TasbihCounterAnnotationComposer,
      $TasbihCounterCreateCompanionBuilder,
      $TasbihCounterUpdateCompanionBuilder,
      (
        TasbihCounterData,
        BaseReferences<_$UserDatabase, TasbihCounter, TasbihCounterData>,
      ),
      TasbihCounterData,
      PrefetchHooks Function()
    >;
typedef $KvSettingCreateCompanionBuilder =
    KvSettingCompanion Function({
      Value<String?> key,
      required String value,
      Value<int> rowid,
    });
typedef $KvSettingUpdateCompanionBuilder =
    KvSettingCompanion Function({
      Value<String?> key,
      Value<String> value,
      Value<int> rowid,
    });

class $KvSettingFilterComposer extends Composer<_$UserDatabase, KvSetting> {
  $KvSettingFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $KvSettingOrderingComposer extends Composer<_$UserDatabase, KvSetting> {
  $KvSettingOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $KvSettingAnnotationComposer extends Composer<_$UserDatabase, KvSetting> {
  $KvSettingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $KvSettingTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          KvSetting,
          KvSettingData,
          $KvSettingFilterComposer,
          $KvSettingOrderingComposer,
          $KvSettingAnnotationComposer,
          $KvSettingCreateCompanionBuilder,
          $KvSettingUpdateCompanionBuilder,
          (
            KvSettingData,
            BaseReferences<_$UserDatabase, KvSetting, KvSettingData>,
          ),
          KvSettingData,
          PrefetchHooks Function()
        > {
  $KvSettingTableManager(_$UserDatabase db, KvSetting table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $KvSettingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $KvSettingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $KvSettingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvSettingCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                Value<String?> key = const Value.absent(),
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KvSettingCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<KvSetting, KvSettingData>(table),
                  BaseReferences<_$UserDatabase, KvSetting, KvSettingData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $KvSettingProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      KvSetting,
      KvSettingData,
      $KvSettingFilterComposer,
      $KvSettingOrderingComposer,
      $KvSettingAnnotationComposer,
      $KvSettingCreateCompanionBuilder,
      $KvSettingUpdateCompanionBuilder,
      (KvSettingData, BaseReferences<_$UserDatabase, KvSetting, KvSettingData>),
      KvSettingData,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $BookmarkTableManager get bookmark =>
      $BookmarkTableManager(_db, _db.bookmark);
  $ReadingPositionTableManager get readingPosition =>
      $ReadingPositionTableManager(_db, _db.readingPosition);
  $KhatamPlanTableManager get khatamPlan =>
      $KhatamPlanTableManager(_db, _db.khatamPlan);
  $VoiceSearchHistoryTableManager get voiceSearchHistory =>
      $VoiceSearchHistoryTableManager(_db, _db.voiceSearchHistory);
  $PrayerCacheTableManager get prayerCache =>
      $PrayerCacheTableManager(_db, _db.prayerCache);
  $AdzanSettingTableManager get adzanSetting =>
      $AdzanSettingTableManager(_db, _db.adzanSetting);
  $AudioDownloadTableManager get audioDownload =>
      $AudioDownloadTableManager(_db, _db.audioDownload);
  $TasbihCounterTableManager get tasbihCounter =>
      $TasbihCounterTableManager(_db, _db.tasbihCounter);
  $KvSettingTableManager get kvSetting =>
      $KvSettingTableManager(_db, _db.kvSetting);
}
