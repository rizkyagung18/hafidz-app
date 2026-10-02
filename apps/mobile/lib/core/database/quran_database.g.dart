// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_database.dart';

// ignore_for_file: type=lint
class Meta extends Table with TableInfo<Meta, MetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Meta(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaData> instance, {
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
  MetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaData(
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
  Meta createAlias(String alias) {
    return Meta(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MetaData extends DataClass implements Insertable<MetaData> {
  final String? key;
  final String value;
  const MetaData({this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      value: Value(value),
    );
  }

  factory MetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaData(
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

  MetaData copyWith({
    Value<String?> key = const Value.absent(),
    String? value,
  }) => MetaData(
    key: key.present ? key.value : this.key,
    value: value ?? this.value,
  );
  MetaData copyWithCompanion(MetaCompanion data) {
    return MetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaData(')
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
      (other is MetaData && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaData> {
  final Value<String?> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    this.key = const Value.absent(),
    required String value,
    this.rowid = const Value.absent(),
  }) : value = Value(value);
  static Insertable<MetaData> custom({
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

  MetaCompanion copyWith({
    Value<String?>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
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
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Surah extends Table with TableInfo<Surah, SurahData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Surah(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameLatinMeta = const VerificationMeta(
    'nameLatin',
  );
  late final GeneratedColumn<String> nameLatin = GeneratedColumn<String>(
    'name_latin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _translationEnMeta = const VerificationMeta(
    'translationEn',
  );
  late final GeneratedColumn<String> translationEn = GeneratedColumn<String>(
    'translation_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _ayahCountMeta = const VerificationMeta(
    'ayahCount',
  );
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
    'ayah_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _revelationPlaceMeta = const VerificationMeta(
    'revelationPlace',
  );
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
    'revelation_place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (revelation_place IN (\'makkah\', \'madinah\'))',
  );
  static const VerificationMeta _revelationOrderMeta = const VerificationMeta(
    'revelationOrder',
  );
  late final GeneratedColumn<int> revelationOrder = GeneratedColumn<int>(
    'revelation_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _firstPageMeta = const VerificationMeta(
    'firstPage',
  );
  late final GeneratedColumn<int> firstPage = GeneratedColumn<int>(
    'first_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bismillahPreMeta = const VerificationMeta(
    'bismillahPre',
  );
  late final GeneratedColumn<int> bismillahPre = GeneratedColumn<int>(
    'bismillah_pre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    nameArabic,
    nameLatin,
    translationId,
    translationEn,
    ayahCount,
    revelationPlace,
    revelationOrder,
    firstPage,
    bismillahPre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surah';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurahData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_latin')) {
      context.handle(
        _nameLatinMeta,
        nameLatin.isAcceptableOrUnknown(data['name_latin']!, _nameLatinMeta),
      );
    } else if (isInserting) {
      context.missing(_nameLatinMeta);
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    }
    if (data.containsKey('translation_en')) {
      context.handle(
        _translationEnMeta,
        translationEn.isAcceptableOrUnknown(
          data['translation_en']!,
          _translationEnMeta,
        ),
      );
    }
    if (data.containsKey('ayah_count')) {
      context.handle(
        _ayahCountMeta,
        ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
        _revelationPlaceMeta,
        revelationPlace.isAcceptableOrUnknown(
          data['revelation_place']!,
          _revelationPlaceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revelationPlaceMeta);
    }
    if (data.containsKey('revelation_order')) {
      context.handle(
        _revelationOrderMeta,
        revelationOrder.isAcceptableOrUnknown(
          data['revelation_order']!,
          _revelationOrderMeta,
        ),
      );
    }
    if (data.containsKey('first_page')) {
      context.handle(
        _firstPageMeta,
        firstPage.isAcceptableOrUnknown(data['first_page']!, _firstPageMeta),
      );
    } else if (isInserting) {
      context.missing(_firstPageMeta);
    }
    if (data.containsKey('bismillah_pre')) {
      context.handle(
        _bismillahPreMeta,
        bismillahPre.isAcceptableOrUnknown(
          data['bismillah_pre']!,
          _bismillahPreMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  SurahData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahData(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameLatin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_latin'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      ),
      translationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_en'],
      ),
      ayahCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_count'],
      )!,
      revelationPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place'],
      )!,
      revelationOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revelation_order'],
      ),
      firstPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_page'],
      )!,
      bismillahPre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bismillah_pre'],
      )!,
    );
  }

  @override
  Surah createAlias(String alias) {
    return Surah(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SurahData extends DataClass implements Insertable<SurahData> {
  final int number;
  final String nameArabic;
  final String nameLatin;
  final String? translationId;
  final String? translationEn;
  final int ayahCount;
  final String revelationPlace;
  final int? revelationOrder;
  final int firstPage;
  final int bismillahPre;
  const SurahData({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    this.translationId,
    this.translationEn,
    required this.ayahCount,
    required this.revelationPlace,
    this.revelationOrder,
    required this.firstPage,
    required this.bismillahPre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_latin'] = Variable<String>(nameLatin);
    if (!nullToAbsent || translationId != null) {
      map['translation_id'] = Variable<String>(translationId);
    }
    if (!nullToAbsent || translationEn != null) {
      map['translation_en'] = Variable<String>(translationEn);
    }
    map['ayah_count'] = Variable<int>(ayahCount);
    map['revelation_place'] = Variable<String>(revelationPlace);
    if (!nullToAbsent || revelationOrder != null) {
      map['revelation_order'] = Variable<int>(revelationOrder);
    }
    map['first_page'] = Variable<int>(firstPage);
    map['bismillah_pre'] = Variable<int>(bismillahPre);
    return map;
  }

  SurahCompanion toCompanion(bool nullToAbsent) {
    return SurahCompanion(
      number: Value(number),
      nameArabic: Value(nameArabic),
      nameLatin: Value(nameLatin),
      translationId: translationId == null && nullToAbsent
          ? const Value.absent()
          : Value(translationId),
      translationEn: translationEn == null && nullToAbsent
          ? const Value.absent()
          : Value(translationEn),
      ayahCount: Value(ayahCount),
      revelationPlace: Value(revelationPlace),
      revelationOrder: revelationOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationOrder),
      firstPage: Value(firstPage),
      bismillahPre: Value(bismillahPre),
    );
  }

  factory SurahData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahData(
      number: serializer.fromJson<int>(json['number']),
      nameArabic: serializer.fromJson<String>(json['name_arabic']),
      nameLatin: serializer.fromJson<String>(json['name_latin']),
      translationId: serializer.fromJson<String?>(json['translation_id']),
      translationEn: serializer.fromJson<String?>(json['translation_en']),
      ayahCount: serializer.fromJson<int>(json['ayah_count']),
      revelationPlace: serializer.fromJson<String>(json['revelation_place']),
      revelationOrder: serializer.fromJson<int?>(json['revelation_order']),
      firstPage: serializer.fromJson<int>(json['first_page']),
      bismillahPre: serializer.fromJson<int>(json['bismillah_pre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'name_arabic': serializer.toJson<String>(nameArabic),
      'name_latin': serializer.toJson<String>(nameLatin),
      'translation_id': serializer.toJson<String?>(translationId),
      'translation_en': serializer.toJson<String?>(translationEn),
      'ayah_count': serializer.toJson<int>(ayahCount),
      'revelation_place': serializer.toJson<String>(revelationPlace),
      'revelation_order': serializer.toJson<int?>(revelationOrder),
      'first_page': serializer.toJson<int>(firstPage),
      'bismillah_pre': serializer.toJson<int>(bismillahPre),
    };
  }

  SurahData copyWith({
    int? number,
    String? nameArabic,
    String? nameLatin,
    Value<String?> translationId = const Value.absent(),
    Value<String?> translationEn = const Value.absent(),
    int? ayahCount,
    String? revelationPlace,
    Value<int?> revelationOrder = const Value.absent(),
    int? firstPage,
    int? bismillahPre,
  }) => SurahData(
    number: number ?? this.number,
    nameArabic: nameArabic ?? this.nameArabic,
    nameLatin: nameLatin ?? this.nameLatin,
    translationId: translationId.present
        ? translationId.value
        : this.translationId,
    translationEn: translationEn.present
        ? translationEn.value
        : this.translationEn,
    ayahCount: ayahCount ?? this.ayahCount,
    revelationPlace: revelationPlace ?? this.revelationPlace,
    revelationOrder: revelationOrder.present
        ? revelationOrder.value
        : this.revelationOrder,
    firstPage: firstPage ?? this.firstPage,
    bismillahPre: bismillahPre ?? this.bismillahPre,
  );
  SurahData copyWithCompanion(SurahCompanion data) {
    return SurahData(
      number: data.number.present ? data.number.value : this.number,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameLatin: data.nameLatin.present ? data.nameLatin.value : this.nameLatin,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      translationEn: data.translationEn.present
          ? data.translationEn.value
          : this.translationEn,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      revelationOrder: data.revelationOrder.present
          ? data.revelationOrder.value
          : this.revelationOrder,
      firstPage: data.firstPage.present ? data.firstPage.value : this.firstPage,
      bismillahPre: data.bismillahPre.present
          ? data.bismillahPre.value
          : this.bismillahPre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahData(')
          ..write('number: $number, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameLatin: $nameLatin, ')
          ..write('translationId: $translationId, ')
          ..write('translationEn: $translationEn, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('firstPage: $firstPage, ')
          ..write('bismillahPre: $bismillahPre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    number,
    nameArabic,
    nameLatin,
    translationId,
    translationEn,
    ayahCount,
    revelationPlace,
    revelationOrder,
    firstPage,
    bismillahPre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahData &&
          other.number == this.number &&
          other.nameArabic == this.nameArabic &&
          other.nameLatin == this.nameLatin &&
          other.translationId == this.translationId &&
          other.translationEn == this.translationEn &&
          other.ayahCount == this.ayahCount &&
          other.revelationPlace == this.revelationPlace &&
          other.revelationOrder == this.revelationOrder &&
          other.firstPage == this.firstPage &&
          other.bismillahPre == this.bismillahPre);
}

class SurahCompanion extends UpdateCompanion<SurahData> {
  final Value<int> number;
  final Value<String> nameArabic;
  final Value<String> nameLatin;
  final Value<String?> translationId;
  final Value<String?> translationEn;
  final Value<int> ayahCount;
  final Value<String> revelationPlace;
  final Value<int?> revelationOrder;
  final Value<int> firstPage;
  final Value<int> bismillahPre;
  const SurahCompanion({
    this.number = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameLatin = const Value.absent(),
    this.translationId = const Value.absent(),
    this.translationEn = const Value.absent(),
    this.ayahCount = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.revelationOrder = const Value.absent(),
    this.firstPage = const Value.absent(),
    this.bismillahPre = const Value.absent(),
  });
  SurahCompanion.insert({
    this.number = const Value.absent(),
    required String nameArabic,
    required String nameLatin,
    this.translationId = const Value.absent(),
    this.translationEn = const Value.absent(),
    required int ayahCount,
    required String revelationPlace,
    this.revelationOrder = const Value.absent(),
    required int firstPage,
    this.bismillahPre = const Value.absent(),
  }) : nameArabic = Value(nameArabic),
       nameLatin = Value(nameLatin),
       ayahCount = Value(ayahCount),
       revelationPlace = Value(revelationPlace),
       firstPage = Value(firstPage);
  static Insertable<SurahData> custom({
    Expression<int>? number,
    Expression<String>? nameArabic,
    Expression<String>? nameLatin,
    Expression<String>? translationId,
    Expression<String>? translationEn,
    Expression<int>? ayahCount,
    Expression<String>? revelationPlace,
    Expression<int>? revelationOrder,
    Expression<int>? firstPage,
    Expression<int>? bismillahPre,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameLatin != null) 'name_latin': nameLatin,
      if (translationId != null) 'translation_id': translationId,
      if (translationEn != null) 'translation_en': translationEn,
      if (ayahCount != null) 'ayah_count': ayahCount,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (revelationOrder != null) 'revelation_order': revelationOrder,
      if (firstPage != null) 'first_page': firstPage,
      if (bismillahPre != null) 'bismillah_pre': bismillahPre,
    });
  }

  SurahCompanion copyWith({
    Value<int>? number,
    Value<String>? nameArabic,
    Value<String>? nameLatin,
    Value<String?>? translationId,
    Value<String?>? translationEn,
    Value<int>? ayahCount,
    Value<String>? revelationPlace,
    Value<int?>? revelationOrder,
    Value<int>? firstPage,
    Value<int>? bismillahPre,
  }) {
    return SurahCompanion(
      number: number ?? this.number,
      nameArabic: nameArabic ?? this.nameArabic,
      nameLatin: nameLatin ?? this.nameLatin,
      translationId: translationId ?? this.translationId,
      translationEn: translationEn ?? this.translationEn,
      ayahCount: ayahCount ?? this.ayahCount,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      firstPage: firstPage ?? this.firstPage,
      bismillahPre: bismillahPre ?? this.bismillahPre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameLatin.present) {
      map['name_latin'] = Variable<String>(nameLatin.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (translationEn.present) {
      map['translation_en'] = Variable<String>(translationEn.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (revelationOrder.present) {
      map['revelation_order'] = Variable<int>(revelationOrder.value);
    }
    if (firstPage.present) {
      map['first_page'] = Variable<int>(firstPage.value);
    }
    if (bismillahPre.present) {
      map['bismillah_pre'] = Variable<int>(bismillahPre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahCompanion(')
          ..write('number: $number, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameLatin: $nameLatin, ')
          ..write('translationId: $translationId, ')
          ..write('translationEn: $translationEn, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('firstPage: $firstPage, ')
          ..write('bismillahPre: $bismillahPre')
          ..write(')'))
        .toString();
  }
}

class Ayah extends Table with TableInfo<Ayah, AyahData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Ayah(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
    'surah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES surah(number)',
  );
  static const VerificationMeta _ayahMeta = const VerificationMeta('ayah');
  late final GeneratedColumn<int> ayah = GeneratedColumn<int>(
    'ayah',
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
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _hizbQuarterMeta = const VerificationMeta(
    'hizbQuarter',
  );
  late final GeneratedColumn<int> hizbQuarter = GeneratedColumn<int>(
    'hizb_quarter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _rukuMeta = const VerificationMeta('ruku');
  late final GeneratedColumn<int> ruku = GeneratedColumn<int>(
    'ruku',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _manzilMeta = const VerificationMeta('manzil');
  late final GeneratedColumn<int> manzil = GeneratedColumn<int>(
    'manzil',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sajdaMeta = const VerificationMeta('sajda');
  late final GeneratedColumn<int> sajda = GeneratedColumn<int>(
    'sajda',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _textUthmaniMeta = const VerificationMeta(
    'textUthmani',
  );
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
    'text_uthmani',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _textSimpleMeta = const VerificationMeta(
    'textSimple',
  );
  late final GeneratedColumn<String> textSimple = GeneratedColumn<String>(
    'text_simple',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _textNormMeta = const VerificationMeta(
    'textNorm',
  );
  late final GeneratedColumn<String> textNorm = GeneratedColumn<String>(
    'text_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _textLatinMeta = const VerificationMeta(
    'textLatin',
  );
  late final GeneratedColumn<String> textLatin = GeneratedColumn<String>(
    'text_latin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _translationEnMeta = const VerificationMeta(
    'translationEn',
  );
  late final GeneratedColumn<String> translationEn = GeneratedColumn<String>(
    'translation_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _hizbMeta = const VerificationMeta('hizb');
  late final GeneratedColumn<int> hizb = GeneratedColumn<int>(
    'hizb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    surah,
    ayah,
    page,
    juz,
    hizbQuarter,
    ruku,
    manzil,
    sajda,
    textUthmani,
    textSimple,
    textNorm,
    textLatin,
    translationId,
    translationEn,
    hizb,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('surah')) {
      context.handle(
        _surahMeta,
        surah.isAcceptableOrUnknown(data['surah']!, _surahMeta),
      );
    } else if (isInserting) {
      context.missing(_surahMeta);
    }
    if (data.containsKey('ayah')) {
      context.handle(
        _ayahMeta,
        ayah.isAcceptableOrUnknown(data['ayah']!, _ayahMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('hizb_quarter')) {
      context.handle(
        _hizbQuarterMeta,
        hizbQuarter.isAcceptableOrUnknown(
          data['hizb_quarter']!,
          _hizbQuarterMeta,
        ),
      );
    }
    if (data.containsKey('ruku')) {
      context.handle(
        _rukuMeta,
        ruku.isAcceptableOrUnknown(data['ruku']!, _rukuMeta),
      );
    }
    if (data.containsKey('manzil')) {
      context.handle(
        _manzilMeta,
        manzil.isAcceptableOrUnknown(data['manzil']!, _manzilMeta),
      );
    }
    if (data.containsKey('sajda')) {
      context.handle(
        _sajdaMeta,
        sajda.isAcceptableOrUnknown(data['sajda']!, _sajdaMeta),
      );
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
        _textUthmaniMeta,
        textUthmani.isAcceptableOrUnknown(
          data['text_uthmani']!,
          _textUthmaniMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_textUthmaniMeta);
    }
    if (data.containsKey('text_simple')) {
      context.handle(
        _textSimpleMeta,
        textSimple.isAcceptableOrUnknown(data['text_simple']!, _textSimpleMeta),
      );
    } else if (isInserting) {
      context.missing(_textSimpleMeta);
    }
    if (data.containsKey('text_norm')) {
      context.handle(
        _textNormMeta,
        textNorm.isAcceptableOrUnknown(data['text_norm']!, _textNormMeta),
      );
    } else if (isInserting) {
      context.missing(_textNormMeta);
    }
    if (data.containsKey('text_latin')) {
      context.handle(
        _textLatinMeta,
        textLatin.isAcceptableOrUnknown(data['text_latin']!, _textLatinMeta),
      );
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('translation_en')) {
      context.handle(
        _translationEnMeta,
        translationEn.isAcceptableOrUnknown(
          data['translation_en']!,
          _translationEnMeta,
        ),
      );
    }
    if (data.containsKey('hizb')) {
      context.handle(
        _hizbMeta,
        hizb.isAcceptableOrUnknown(data['hizb']!, _hizbMeta),
      );
    } else if (isInserting) {
      context.missing(_hizbMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {surah, ayah},
  ];
  @override
  AyahData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      surah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah'],
      )!,
      ayah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
      hizbQuarter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb_quarter'],
      ),
      ruku: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ruku'],
      ),
      manzil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manzil'],
      ),
      sajda: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sajda'],
      )!,
      textUthmani: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_uthmani'],
      )!,
      textSimple: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_simple'],
      )!,
      textNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_norm'],
      )!,
      textLatin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_latin'],
      ),
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      translationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_en'],
      ),
      hizb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb'],
      )!,
    );
  }

  @override
  Ayah createAlias(String alias) {
    return Ayah(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(surah, ayah)'];
  @override
  bool get dontWriteConstraints => true;
}

class AyahData extends DataClass implements Insertable<AyahData> {
  final int id;
  final int surah;
  final int ayah;
  final int page;
  final int juz;
  final int? hizbQuarter;
  final int? ruku;
  final int? manzil;
  final int sajda;
  final String textUthmani;
  final String textSimple;
  final String textNorm;
  final String? textLatin;
  final String translationId;
  final String? translationEn;
  final int hizb;
  const AyahData({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.page,
    required this.juz,
    this.hizbQuarter,
    this.ruku,
    this.manzil,
    required this.sajda,
    required this.textUthmani,
    required this.textSimple,
    required this.textNorm,
    this.textLatin,
    required this.translationId,
    this.translationEn,
    required this.hizb,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['surah'] = Variable<int>(surah);
    map['ayah'] = Variable<int>(ayah);
    map['page'] = Variable<int>(page);
    map['juz'] = Variable<int>(juz);
    if (!nullToAbsent || hizbQuarter != null) {
      map['hizb_quarter'] = Variable<int>(hizbQuarter);
    }
    if (!nullToAbsent || ruku != null) {
      map['ruku'] = Variable<int>(ruku);
    }
    if (!nullToAbsent || manzil != null) {
      map['manzil'] = Variable<int>(manzil);
    }
    map['sajda'] = Variable<int>(sajda);
    map['text_uthmani'] = Variable<String>(textUthmani);
    map['text_simple'] = Variable<String>(textSimple);
    map['text_norm'] = Variable<String>(textNorm);
    if (!nullToAbsent || textLatin != null) {
      map['text_latin'] = Variable<String>(textLatin);
    }
    map['translation_id'] = Variable<String>(translationId);
    if (!nullToAbsent || translationEn != null) {
      map['translation_en'] = Variable<String>(translationEn);
    }
    map['hizb'] = Variable<int>(hizb);
    return map;
  }

  AyahCompanion toCompanion(bool nullToAbsent) {
    return AyahCompanion(
      id: Value(id),
      surah: Value(surah),
      ayah: Value(ayah),
      page: Value(page),
      juz: Value(juz),
      hizbQuarter: hizbQuarter == null && nullToAbsent
          ? const Value.absent()
          : Value(hizbQuarter),
      ruku: ruku == null && nullToAbsent ? const Value.absent() : Value(ruku),
      manzil: manzil == null && nullToAbsent
          ? const Value.absent()
          : Value(manzil),
      sajda: Value(sajda),
      textUthmani: Value(textUthmani),
      textSimple: Value(textSimple),
      textNorm: Value(textNorm),
      textLatin: textLatin == null && nullToAbsent
          ? const Value.absent()
          : Value(textLatin),
      translationId: Value(translationId),
      translationEn: translationEn == null && nullToAbsent
          ? const Value.absent()
          : Value(translationEn),
      hizb: Value(hizb),
    );
  }

  factory AyahData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahData(
      id: serializer.fromJson<int>(json['id']),
      surah: serializer.fromJson<int>(json['surah']),
      ayah: serializer.fromJson<int>(json['ayah']),
      page: serializer.fromJson<int>(json['page']),
      juz: serializer.fromJson<int>(json['juz']),
      hizbQuarter: serializer.fromJson<int?>(json['hizb_quarter']),
      ruku: serializer.fromJson<int?>(json['ruku']),
      manzil: serializer.fromJson<int?>(json['manzil']),
      sajda: serializer.fromJson<int>(json['sajda']),
      textUthmani: serializer.fromJson<String>(json['text_uthmani']),
      textSimple: serializer.fromJson<String>(json['text_simple']),
      textNorm: serializer.fromJson<String>(json['text_norm']),
      textLatin: serializer.fromJson<String?>(json['text_latin']),
      translationId: serializer.fromJson<String>(json['translation_id']),
      translationEn: serializer.fromJson<String?>(json['translation_en']),
      hizb: serializer.fromJson<int>(json['hizb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'surah': serializer.toJson<int>(surah),
      'ayah': serializer.toJson<int>(ayah),
      'page': serializer.toJson<int>(page),
      'juz': serializer.toJson<int>(juz),
      'hizb_quarter': serializer.toJson<int?>(hizbQuarter),
      'ruku': serializer.toJson<int?>(ruku),
      'manzil': serializer.toJson<int?>(manzil),
      'sajda': serializer.toJson<int>(sajda),
      'text_uthmani': serializer.toJson<String>(textUthmani),
      'text_simple': serializer.toJson<String>(textSimple),
      'text_norm': serializer.toJson<String>(textNorm),
      'text_latin': serializer.toJson<String?>(textLatin),
      'translation_id': serializer.toJson<String>(translationId),
      'translation_en': serializer.toJson<String?>(translationEn),
      'hizb': serializer.toJson<int>(hizb),
    };
  }

  AyahData copyWith({
    int? id,
    int? surah,
    int? ayah,
    int? page,
    int? juz,
    Value<int?> hizbQuarter = const Value.absent(),
    Value<int?> ruku = const Value.absent(),
    Value<int?> manzil = const Value.absent(),
    int? sajda,
    String? textUthmani,
    String? textSimple,
    String? textNorm,
    Value<String?> textLatin = const Value.absent(),
    String? translationId,
    Value<String?> translationEn = const Value.absent(),
    int? hizb,
  }) => AyahData(
    id: id ?? this.id,
    surah: surah ?? this.surah,
    ayah: ayah ?? this.ayah,
    page: page ?? this.page,
    juz: juz ?? this.juz,
    hizbQuarter: hizbQuarter.present ? hizbQuarter.value : this.hizbQuarter,
    ruku: ruku.present ? ruku.value : this.ruku,
    manzil: manzil.present ? manzil.value : this.manzil,
    sajda: sajda ?? this.sajda,
    textUthmani: textUthmani ?? this.textUthmani,
    textSimple: textSimple ?? this.textSimple,
    textNorm: textNorm ?? this.textNorm,
    textLatin: textLatin.present ? textLatin.value : this.textLatin,
    translationId: translationId ?? this.translationId,
    translationEn: translationEn.present
        ? translationEn.value
        : this.translationEn,
    hizb: hizb ?? this.hizb,
  );
  AyahData copyWithCompanion(AyahCompanion data) {
    return AyahData(
      id: data.id.present ? data.id.value : this.id,
      surah: data.surah.present ? data.surah.value : this.surah,
      ayah: data.ayah.present ? data.ayah.value : this.ayah,
      page: data.page.present ? data.page.value : this.page,
      juz: data.juz.present ? data.juz.value : this.juz,
      hizbQuarter: data.hizbQuarter.present
          ? data.hizbQuarter.value
          : this.hizbQuarter,
      ruku: data.ruku.present ? data.ruku.value : this.ruku,
      manzil: data.manzil.present ? data.manzil.value : this.manzil,
      sajda: data.sajda.present ? data.sajda.value : this.sajda,
      textUthmani: data.textUthmani.present
          ? data.textUthmani.value
          : this.textUthmani,
      textSimple: data.textSimple.present
          ? data.textSimple.value
          : this.textSimple,
      textNorm: data.textNorm.present ? data.textNorm.value : this.textNorm,
      textLatin: data.textLatin.present ? data.textLatin.value : this.textLatin,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      translationEn: data.translationEn.present
          ? data.translationEn.value
          : this.translationEn,
      hizb: data.hizb.present ? data.hizb.value : this.hizb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahData(')
          ..write('id: $id, ')
          ..write('surah: $surah, ')
          ..write('ayah: $ayah, ')
          ..write('page: $page, ')
          ..write('juz: $juz, ')
          ..write('hizbQuarter: $hizbQuarter, ')
          ..write('ruku: $ruku, ')
          ..write('manzil: $manzil, ')
          ..write('sajda: $sajda, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textSimple: $textSimple, ')
          ..write('textNorm: $textNorm, ')
          ..write('textLatin: $textLatin, ')
          ..write('translationId: $translationId, ')
          ..write('translationEn: $translationEn, ')
          ..write('hizb: $hizb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    surah,
    ayah,
    page,
    juz,
    hizbQuarter,
    ruku,
    manzil,
    sajda,
    textUthmani,
    textSimple,
    textNorm,
    textLatin,
    translationId,
    translationEn,
    hizb,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahData &&
          other.id == this.id &&
          other.surah == this.surah &&
          other.ayah == this.ayah &&
          other.page == this.page &&
          other.juz == this.juz &&
          other.hizbQuarter == this.hizbQuarter &&
          other.ruku == this.ruku &&
          other.manzil == this.manzil &&
          other.sajda == this.sajda &&
          other.textUthmani == this.textUthmani &&
          other.textSimple == this.textSimple &&
          other.textNorm == this.textNorm &&
          other.textLatin == this.textLatin &&
          other.translationId == this.translationId &&
          other.translationEn == this.translationEn &&
          other.hizb == this.hizb);
}

class AyahCompanion extends UpdateCompanion<AyahData> {
  final Value<int> id;
  final Value<int> surah;
  final Value<int> ayah;
  final Value<int> page;
  final Value<int> juz;
  final Value<int?> hizbQuarter;
  final Value<int?> ruku;
  final Value<int?> manzil;
  final Value<int> sajda;
  final Value<String> textUthmani;
  final Value<String> textSimple;
  final Value<String> textNorm;
  final Value<String?> textLatin;
  final Value<String> translationId;
  final Value<String?> translationEn;
  final Value<int> hizb;
  const AyahCompanion({
    this.id = const Value.absent(),
    this.surah = const Value.absent(),
    this.ayah = const Value.absent(),
    this.page = const Value.absent(),
    this.juz = const Value.absent(),
    this.hizbQuarter = const Value.absent(),
    this.ruku = const Value.absent(),
    this.manzil = const Value.absent(),
    this.sajda = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.textSimple = const Value.absent(),
    this.textNorm = const Value.absent(),
    this.textLatin = const Value.absent(),
    this.translationId = const Value.absent(),
    this.translationEn = const Value.absent(),
    this.hizb = const Value.absent(),
  });
  AyahCompanion.insert({
    this.id = const Value.absent(),
    required int surah,
    required int ayah,
    required int page,
    required int juz,
    this.hizbQuarter = const Value.absent(),
    this.ruku = const Value.absent(),
    this.manzil = const Value.absent(),
    this.sajda = const Value.absent(),
    required String textUthmani,
    required String textSimple,
    required String textNorm,
    this.textLatin = const Value.absent(),
    required String translationId,
    this.translationEn = const Value.absent(),
    required int hizb,
  }) : surah = Value(surah),
       ayah = Value(ayah),
       page = Value(page),
       juz = Value(juz),
       textUthmani = Value(textUthmani),
       textSimple = Value(textSimple),
       textNorm = Value(textNorm),
       translationId = Value(translationId),
       hizb = Value(hizb);
  static Insertable<AyahData> custom({
    Expression<int>? id,
    Expression<int>? surah,
    Expression<int>? ayah,
    Expression<int>? page,
    Expression<int>? juz,
    Expression<int>? hizbQuarter,
    Expression<int>? ruku,
    Expression<int>? manzil,
    Expression<int>? sajda,
    Expression<String>? textUthmani,
    Expression<String>? textSimple,
    Expression<String>? textNorm,
    Expression<String>? textLatin,
    Expression<String>? translationId,
    Expression<String>? translationEn,
    Expression<int>? hizb,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (surah != null) 'surah': surah,
      if (ayah != null) 'ayah': ayah,
      if (page != null) 'page': page,
      if (juz != null) 'juz': juz,
      if (hizbQuarter != null) 'hizb_quarter': hizbQuarter,
      if (ruku != null) 'ruku': ruku,
      if (manzil != null) 'manzil': manzil,
      if (sajda != null) 'sajda': sajda,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (textSimple != null) 'text_simple': textSimple,
      if (textNorm != null) 'text_norm': textNorm,
      if (textLatin != null) 'text_latin': textLatin,
      if (translationId != null) 'translation_id': translationId,
      if (translationEn != null) 'translation_en': translationEn,
      if (hizb != null) 'hizb': hizb,
    });
  }

  AyahCompanion copyWith({
    Value<int>? id,
    Value<int>? surah,
    Value<int>? ayah,
    Value<int>? page,
    Value<int>? juz,
    Value<int?>? hizbQuarter,
    Value<int?>? ruku,
    Value<int?>? manzil,
    Value<int>? sajda,
    Value<String>? textUthmani,
    Value<String>? textSimple,
    Value<String>? textNorm,
    Value<String?>? textLatin,
    Value<String>? translationId,
    Value<String?>? translationEn,
    Value<int>? hizb,
  }) {
    return AyahCompanion(
      id: id ?? this.id,
      surah: surah ?? this.surah,
      ayah: ayah ?? this.ayah,
      page: page ?? this.page,
      juz: juz ?? this.juz,
      hizbQuarter: hizbQuarter ?? this.hizbQuarter,
      ruku: ruku ?? this.ruku,
      manzil: manzil ?? this.manzil,
      sajda: sajda ?? this.sajda,
      textUthmani: textUthmani ?? this.textUthmani,
      textSimple: textSimple ?? this.textSimple,
      textNorm: textNorm ?? this.textNorm,
      textLatin: textLatin ?? this.textLatin,
      translationId: translationId ?? this.translationId,
      translationEn: translationEn ?? this.translationEn,
      hizb: hizb ?? this.hizb,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (ayah.present) {
      map['ayah'] = Variable<int>(ayah.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (hizbQuarter.present) {
      map['hizb_quarter'] = Variable<int>(hizbQuarter.value);
    }
    if (ruku.present) {
      map['ruku'] = Variable<int>(ruku.value);
    }
    if (manzil.present) {
      map['manzil'] = Variable<int>(manzil.value);
    }
    if (sajda.present) {
      map['sajda'] = Variable<int>(sajda.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (textSimple.present) {
      map['text_simple'] = Variable<String>(textSimple.value);
    }
    if (textNorm.present) {
      map['text_norm'] = Variable<String>(textNorm.value);
    }
    if (textLatin.present) {
      map['text_latin'] = Variable<String>(textLatin.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (translationEn.present) {
      map['translation_en'] = Variable<String>(translationEn.value);
    }
    if (hizb.present) {
      map['hizb'] = Variable<int>(hizb.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahCompanion(')
          ..write('id: $id, ')
          ..write('surah: $surah, ')
          ..write('ayah: $ayah, ')
          ..write('page: $page, ')
          ..write('juz: $juz, ')
          ..write('hizbQuarter: $hizbQuarter, ')
          ..write('ruku: $ruku, ')
          ..write('manzil: $manzil, ')
          ..write('sajda: $sajda, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textSimple: $textSimple, ')
          ..write('textNorm: $textNorm, ')
          ..write('textLatin: $textLatin, ')
          ..write('translationId: $translationId, ')
          ..write('translationEn: $translationEn, ')
          ..write('hizb: $hizb')
          ..write(')'))
        .toString();
  }
}

class Tafsir extends Table with TableInfo<Tafsir, TafsirData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tafsir(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES ayah(id)',
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
  static const VerificationMeta _tafsirTextMeta = const VerificationMeta(
    'tafsirText',
  );
  late final GeneratedColumn<String> tafsirText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [ayahId, source, tafsirText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tafsir';
  @override
  VerificationContext validateIntegrity(
    Insertable<TafsirData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _tafsirTextMeta,
        tafsirText.isAcceptableOrUnknown(data['text']!, _tafsirTextMeta),
      );
    } else if (isInserting) {
      context.missing(_tafsirTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ayahId, source};
  @override
  TafsirData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TafsirData(
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      tafsirText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
    );
  }

  @override
  Tafsir createAlias(String alias) {
    return Tafsir(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['PRIMARY KEY(ayah_id, source)'];
  @override
  bool get dontWriteConstraints => true;
}

class TafsirData extends DataClass implements Insertable<TafsirData> {
  final int ayahId;
  final String source;
  final String tafsirText;
  const TafsirData({
    required this.ayahId,
    required this.source,
    required this.tafsirText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ayah_id'] = Variable<int>(ayahId);
    map['source'] = Variable<String>(source);
    map['text'] = Variable<String>(tafsirText);
    return map;
  }

  TafsirCompanion toCompanion(bool nullToAbsent) {
    return TafsirCompanion(
      ayahId: Value(ayahId),
      source: Value(source),
      tafsirText: Value(tafsirText),
    );
  }

  factory TafsirData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TafsirData(
      ayahId: serializer.fromJson<int>(json['ayah_id']),
      source: serializer.fromJson<String>(json['source']),
      tafsirText: serializer.fromJson<String>(json['text']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ayah_id': serializer.toJson<int>(ayahId),
      'source': serializer.toJson<String>(source),
      'text': serializer.toJson<String>(tafsirText),
    };
  }

  TafsirData copyWith({int? ayahId, String? source, String? tafsirText}) =>
      TafsirData(
        ayahId: ayahId ?? this.ayahId,
        source: source ?? this.source,
        tafsirText: tafsirText ?? this.tafsirText,
      );
  TafsirData copyWithCompanion(TafsirCompanion data) {
    return TafsirData(
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      source: data.source.present ? data.source.value : this.source,
      tafsirText: data.tafsirText.present
          ? data.tafsirText.value
          : this.tafsirText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TafsirData(')
          ..write('ayahId: $ayahId, ')
          ..write('source: $source, ')
          ..write('tafsirText: $tafsirText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ayahId, source, tafsirText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TafsirData &&
          other.ayahId == this.ayahId &&
          other.source == this.source &&
          other.tafsirText == this.tafsirText);
}

class TafsirCompanion extends UpdateCompanion<TafsirData> {
  final Value<int> ayahId;
  final Value<String> source;
  final Value<String> tafsirText;
  final Value<int> rowid;
  const TafsirCompanion({
    this.ayahId = const Value.absent(),
    this.source = const Value.absent(),
    this.tafsirText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TafsirCompanion.insert({
    required int ayahId,
    required String source,
    required String tafsirText,
    this.rowid = const Value.absent(),
  }) : ayahId = Value(ayahId),
       source = Value(source),
       tafsirText = Value(tafsirText);
  static Insertable<TafsirData> custom({
    Expression<int>? ayahId,
    Expression<String>? source,
    Expression<String>? tafsirText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ayahId != null) 'ayah_id': ayahId,
      if (source != null) 'source': source,
      if (tafsirText != null) 'text': tafsirText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TafsirCompanion copyWith({
    Value<int>? ayahId,
    Value<String>? source,
    Value<String>? tafsirText,
    Value<int>? rowid,
  }) {
    return TafsirCompanion(
      ayahId: ayahId ?? this.ayahId,
      source: source ?? this.source,
      tafsirText: tafsirText ?? this.tafsirText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (tafsirText.present) {
      map['text'] = Variable<String>(tafsirText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TafsirCompanion(')
          ..write('ayahId: $ayahId, ')
          ..write('source: $source, ')
          ..write('tafsirText: $tafsirText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Page extends Table with TableInfo<Page, PageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Page(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _firstAyahMeta = const VerificationMeta(
    'firstAyah',
  );
  late final GeneratedColumn<int> firstAyah = GeneratedColumn<int>(
    'first_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES ayah(id)',
  );
  static const VerificationMeta _lastAyahMeta = const VerificationMeta(
    'lastAyah',
  );
  late final GeneratedColumn<int> lastAyah = GeneratedColumn<int>(
    'last_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES ayah(id)',
  );
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
    'juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [number, firstAyah, lastAyah, juz];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page';
  @override
  VerificationContext validateIntegrity(
    Insertable<PageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('first_ayah')) {
      context.handle(
        _firstAyahMeta,
        firstAyah.isAcceptableOrUnknown(data['first_ayah']!, _firstAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_firstAyahMeta);
    }
    if (data.containsKey('last_ayah')) {
      context.handle(
        _lastAyahMeta,
        lastAyah.isAcceptableOrUnknown(data['last_ayah']!, _lastAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAyahMeta);
    }
    if (data.containsKey('juz')) {
      context.handle(
        _juzMeta,
        juz.isAcceptableOrUnknown(data['juz']!, _juzMeta),
      );
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  PageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageData(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      firstAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_ayah'],
      )!,
      lastAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ayah'],
      )!,
      juz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz'],
      )!,
    );
  }

  @override
  Page createAlias(String alias) {
    return Page(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PageData extends DataClass implements Insertable<PageData> {
  final int number;
  final int firstAyah;
  final int lastAyah;
  final int juz;
  const PageData({
    required this.number,
    required this.firstAyah,
    required this.lastAyah,
    required this.juz,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['first_ayah'] = Variable<int>(firstAyah);
    map['last_ayah'] = Variable<int>(lastAyah);
    map['juz'] = Variable<int>(juz);
    return map;
  }

  PageCompanion toCompanion(bool nullToAbsent) {
    return PageCompanion(
      number: Value(number),
      firstAyah: Value(firstAyah),
      lastAyah: Value(lastAyah),
      juz: Value(juz),
    );
  }

  factory PageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageData(
      number: serializer.fromJson<int>(json['number']),
      firstAyah: serializer.fromJson<int>(json['first_ayah']),
      lastAyah: serializer.fromJson<int>(json['last_ayah']),
      juz: serializer.fromJson<int>(json['juz']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'first_ayah': serializer.toJson<int>(firstAyah),
      'last_ayah': serializer.toJson<int>(lastAyah),
      'juz': serializer.toJson<int>(juz),
    };
  }

  PageData copyWith({int? number, int? firstAyah, int? lastAyah, int? juz}) =>
      PageData(
        number: number ?? this.number,
        firstAyah: firstAyah ?? this.firstAyah,
        lastAyah: lastAyah ?? this.lastAyah,
        juz: juz ?? this.juz,
      );
  PageData copyWithCompanion(PageCompanion data) {
    return PageData(
      number: data.number.present ? data.number.value : this.number,
      firstAyah: data.firstAyah.present ? data.firstAyah.value : this.firstAyah,
      lastAyah: data.lastAyah.present ? data.lastAyah.value : this.lastAyah,
      juz: data.juz.present ? data.juz.value : this.juz,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageData(')
          ..write('number: $number, ')
          ..write('firstAyah: $firstAyah, ')
          ..write('lastAyah: $lastAyah, ')
          ..write('juz: $juz')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(number, firstAyah, lastAyah, juz);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageData &&
          other.number == this.number &&
          other.firstAyah == this.firstAyah &&
          other.lastAyah == this.lastAyah &&
          other.juz == this.juz);
}

class PageCompanion extends UpdateCompanion<PageData> {
  final Value<int> number;
  final Value<int> firstAyah;
  final Value<int> lastAyah;
  final Value<int> juz;
  const PageCompanion({
    this.number = const Value.absent(),
    this.firstAyah = const Value.absent(),
    this.lastAyah = const Value.absent(),
    this.juz = const Value.absent(),
  });
  PageCompanion.insert({
    this.number = const Value.absent(),
    required int firstAyah,
    required int lastAyah,
    required int juz,
  }) : firstAyah = Value(firstAyah),
       lastAyah = Value(lastAyah),
       juz = Value(juz);
  static Insertable<PageData> custom({
    Expression<int>? number,
    Expression<int>? firstAyah,
    Expression<int>? lastAyah,
    Expression<int>? juz,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (firstAyah != null) 'first_ayah': firstAyah,
      if (lastAyah != null) 'last_ayah': lastAyah,
      if (juz != null) 'juz': juz,
    });
  }

  PageCompanion copyWith({
    Value<int>? number,
    Value<int>? firstAyah,
    Value<int>? lastAyah,
    Value<int>? juz,
  }) {
    return PageCompanion(
      number: number ?? this.number,
      firstAyah: firstAyah ?? this.firstAyah,
      lastAyah: lastAyah ?? this.lastAyah,
      juz: juz ?? this.juz,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (firstAyah.present) {
      map['first_ayah'] = Variable<int>(firstAyah.value);
    }
    if (lastAyah.present) {
      map['last_ayah'] = Variable<int>(lastAyah.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PageCompanion(')
          ..write('number: $number, ')
          ..write('firstAyah: $firstAyah, ')
          ..write('lastAyah: $lastAyah, ')
          ..write('juz: $juz')
          ..write(')'))
        .toString();
  }
}

class Juz extends Table with TableInfo<Juz, JuzData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Juz(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _firstAyahMeta = const VerificationMeta(
    'firstAyah',
  );
  late final GeneratedColumn<int> firstAyah = GeneratedColumn<int>(
    'first_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastAyahMeta = const VerificationMeta(
    'lastAyah',
  );
  late final GeneratedColumn<int> lastAyah = GeneratedColumn<int>(
    'last_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [number, firstAyah, lastAyah];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'juz';
  @override
  VerificationContext validateIntegrity(
    Insertable<JuzData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('first_ayah')) {
      context.handle(
        _firstAyahMeta,
        firstAyah.isAcceptableOrUnknown(data['first_ayah']!, _firstAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_firstAyahMeta);
    }
    if (data.containsKey('last_ayah')) {
      context.handle(
        _lastAyahMeta,
        lastAyah.isAcceptableOrUnknown(data['last_ayah']!, _lastAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAyahMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  JuzData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JuzData(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      firstAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_ayah'],
      )!,
      lastAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ayah'],
      )!,
    );
  }

  @override
  Juz createAlias(String alias) {
    return Juz(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class JuzData extends DataClass implements Insertable<JuzData> {
  final int number;
  final int firstAyah;
  final int lastAyah;
  const JuzData({
    required this.number,
    required this.firstAyah,
    required this.lastAyah,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['first_ayah'] = Variable<int>(firstAyah);
    map['last_ayah'] = Variable<int>(lastAyah);
    return map;
  }

  JuzCompanion toCompanion(bool nullToAbsent) {
    return JuzCompanion(
      number: Value(number),
      firstAyah: Value(firstAyah),
      lastAyah: Value(lastAyah),
    );
  }

  factory JuzData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JuzData(
      number: serializer.fromJson<int>(json['number']),
      firstAyah: serializer.fromJson<int>(json['first_ayah']),
      lastAyah: serializer.fromJson<int>(json['last_ayah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'first_ayah': serializer.toJson<int>(firstAyah),
      'last_ayah': serializer.toJson<int>(lastAyah),
    };
  }

  JuzData copyWith({int? number, int? firstAyah, int? lastAyah}) => JuzData(
    number: number ?? this.number,
    firstAyah: firstAyah ?? this.firstAyah,
    lastAyah: lastAyah ?? this.lastAyah,
  );
  JuzData copyWithCompanion(JuzCompanion data) {
    return JuzData(
      number: data.number.present ? data.number.value : this.number,
      firstAyah: data.firstAyah.present ? data.firstAyah.value : this.firstAyah,
      lastAyah: data.lastAyah.present ? data.lastAyah.value : this.lastAyah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JuzData(')
          ..write('number: $number, ')
          ..write('firstAyah: $firstAyah, ')
          ..write('lastAyah: $lastAyah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(number, firstAyah, lastAyah);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JuzData &&
          other.number == this.number &&
          other.firstAyah == this.firstAyah &&
          other.lastAyah == this.lastAyah);
}

class JuzCompanion extends UpdateCompanion<JuzData> {
  final Value<int> number;
  final Value<int> firstAyah;
  final Value<int> lastAyah;
  const JuzCompanion({
    this.number = const Value.absent(),
    this.firstAyah = const Value.absent(),
    this.lastAyah = const Value.absent(),
  });
  JuzCompanion.insert({
    this.number = const Value.absent(),
    required int firstAyah,
    required int lastAyah,
  }) : firstAyah = Value(firstAyah),
       lastAyah = Value(lastAyah);
  static Insertable<JuzData> custom({
    Expression<int>? number,
    Expression<int>? firstAyah,
    Expression<int>? lastAyah,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (firstAyah != null) 'first_ayah': firstAyah,
      if (lastAyah != null) 'last_ayah': lastAyah,
    });
  }

  JuzCompanion copyWith({
    Value<int>? number,
    Value<int>? firstAyah,
    Value<int>? lastAyah,
  }) {
    return JuzCompanion(
      number: number ?? this.number,
      firstAyah: firstAyah ?? this.firstAyah,
      lastAyah: lastAyah ?? this.lastAyah,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (firstAyah.present) {
      map['first_ayah'] = Variable<int>(firstAyah.value);
    }
    if (lastAyah.present) {
      map['last_ayah'] = Variable<int>(lastAyah.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JuzCompanion(')
          ..write('number: $number, ')
          ..write('firstAyah: $firstAyah, ')
          ..write('lastAyah: $lastAyah')
          ..write(')'))
        .toString();
  }
}

class Hizb extends Table with TableInfo<Hizb, HizbData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Hizb(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _firstAyahMeta = const VerificationMeta(
    'firstAyah',
  );
  late final GeneratedColumn<int> firstAyah = GeneratedColumn<int>(
    'first_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastAyahMeta = const VerificationMeta(
    'lastAyah',
  );
  late final GeneratedColumn<int> lastAyah = GeneratedColumn<int>(
    'last_ayah',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [number, firstAyah, lastAyah];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hizb';
  @override
  VerificationContext validateIntegrity(
    Insertable<HizbData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('first_ayah')) {
      context.handle(
        _firstAyahMeta,
        firstAyah.isAcceptableOrUnknown(data['first_ayah']!, _firstAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_firstAyahMeta);
    }
    if (data.containsKey('last_ayah')) {
      context.handle(
        _lastAyahMeta,
        lastAyah.isAcceptableOrUnknown(data['last_ayah']!, _lastAyahMeta),
      );
    } else if (isInserting) {
      context.missing(_lastAyahMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  HizbData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HizbData(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      firstAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_ayah'],
      )!,
      lastAyah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ayah'],
      )!,
    );
  }

  @override
  Hizb createAlias(String alias) {
    return Hizb(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class HizbData extends DataClass implements Insertable<HizbData> {
  final int number;
  final int firstAyah;
  final int lastAyah;
  const HizbData({
    required this.number,
    required this.firstAyah,
    required this.lastAyah,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['first_ayah'] = Variable<int>(firstAyah);
    map['last_ayah'] = Variable<int>(lastAyah);
    return map;
  }

  HizbCompanion toCompanion(bool nullToAbsent) {
    return HizbCompanion(
      number: Value(number),
      firstAyah: Value(firstAyah),
      lastAyah: Value(lastAyah),
    );
  }

  factory HizbData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HizbData(
      number: serializer.fromJson<int>(json['number']),
      firstAyah: serializer.fromJson<int>(json['first_ayah']),
      lastAyah: serializer.fromJson<int>(json['last_ayah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'first_ayah': serializer.toJson<int>(firstAyah),
      'last_ayah': serializer.toJson<int>(lastAyah),
    };
  }

  HizbData copyWith({int? number, int? firstAyah, int? lastAyah}) => HizbData(
    number: number ?? this.number,
    firstAyah: firstAyah ?? this.firstAyah,
    lastAyah: lastAyah ?? this.lastAyah,
  );
  HizbData copyWithCompanion(HizbCompanion data) {
    return HizbData(
      number: data.number.present ? data.number.value : this.number,
      firstAyah: data.firstAyah.present ? data.firstAyah.value : this.firstAyah,
      lastAyah: data.lastAyah.present ? data.lastAyah.value : this.lastAyah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HizbData(')
          ..write('number: $number, ')
          ..write('firstAyah: $firstAyah, ')
          ..write('lastAyah: $lastAyah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(number, firstAyah, lastAyah);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HizbData &&
          other.number == this.number &&
          other.firstAyah == this.firstAyah &&
          other.lastAyah == this.lastAyah);
}

class HizbCompanion extends UpdateCompanion<HizbData> {
  final Value<int> number;
  final Value<int> firstAyah;
  final Value<int> lastAyah;
  const HizbCompanion({
    this.number = const Value.absent(),
    this.firstAyah = const Value.absent(),
    this.lastAyah = const Value.absent(),
  });
  HizbCompanion.insert({
    this.number = const Value.absent(),
    required int firstAyah,
    required int lastAyah,
  }) : firstAyah = Value(firstAyah),
       lastAyah = Value(lastAyah);
  static Insertable<HizbData> custom({
    Expression<int>? number,
    Expression<int>? firstAyah,
    Expression<int>? lastAyah,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (firstAyah != null) 'first_ayah': firstAyah,
      if (lastAyah != null) 'last_ayah': lastAyah,
    });
  }

  HizbCompanion copyWith({
    Value<int>? number,
    Value<int>? firstAyah,
    Value<int>? lastAyah,
  }) {
    return HizbCompanion(
      number: number ?? this.number,
      firstAyah: firstAyah ?? this.firstAyah,
      lastAyah: lastAyah ?? this.lastAyah,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (firstAyah.present) {
      map['first_ayah'] = Variable<int>(firstAyah.value);
    }
    if (lastAyah.present) {
      map['last_ayah'] = Variable<int>(lastAyah.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HizbCompanion(')
          ..write('number: $number, ')
          ..write('firstAyah: $firstAyah, ')
          ..write('lastAyah: $lastAyah')
          ..write(')'))
        .toString();
  }
}

class AyahFts extends Table
    with TableInfo<AyahFts, AyahFt>, VirtualTableInfo<AyahFts, AyahFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AyahFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _textNormMeta = const VerificationMeta(
    'textNorm',
  );
  late final GeneratedColumn<String> textNorm = GeneratedColumn<String>(
    'text_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _translationEnMeta = const VerificationMeta(
    'translationEn',
  );
  late final GeneratedColumn<String> translationEn = GeneratedColumn<String>(
    'translation_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    textNorm,
    translationId,
    translationEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AyahFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('text_norm')) {
      context.handle(
        _textNormMeta,
        textNorm.isAcceptableOrUnknown(data['text_norm']!, _textNormMeta),
      );
    } else if (isInserting) {
      context.missing(_textNormMeta);
    }
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('translation_en')) {
      context.handle(
        _translationEnMeta,
        translationEn.isAcceptableOrUnknown(
          data['translation_en']!,
          _translationEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  AyahFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahFt(
      textNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_norm'],
      )!,
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      translationEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_en'],
      )!,
    );
  }

  @override
  AyahFts createAlias(String alias) {
    return AyahFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(text_norm, translation_id, translation_en, content=\'ayah\', content_rowid=\'id\', tokenize=\'unicode61 remove_diacritics 2\')';
}

class AyahFt extends DataClass implements Insertable<AyahFt> {
  final String textNorm;
  final String translationId;
  final String translationEn;
  const AyahFt({
    required this.textNorm,
    required this.translationId,
    required this.translationEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['text_norm'] = Variable<String>(textNorm);
    map['translation_id'] = Variable<String>(translationId);
    map['translation_en'] = Variable<String>(translationEn);
    return map;
  }

  AyahFtsCompanion toCompanion(bool nullToAbsent) {
    return AyahFtsCompanion(
      textNorm: Value(textNorm),
      translationId: Value(translationId),
      translationEn: Value(translationEn),
    );
  }

  factory AyahFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahFt(
      textNorm: serializer.fromJson<String>(json['text_norm']),
      translationId: serializer.fromJson<String>(json['translation_id']),
      translationEn: serializer.fromJson<String>(json['translation_en']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'text_norm': serializer.toJson<String>(textNorm),
      'translation_id': serializer.toJson<String>(translationId),
      'translation_en': serializer.toJson<String>(translationEn),
    };
  }

  AyahFt copyWith({
    String? textNorm,
    String? translationId,
    String? translationEn,
  }) => AyahFt(
    textNorm: textNorm ?? this.textNorm,
    translationId: translationId ?? this.translationId,
    translationEn: translationEn ?? this.translationEn,
  );
  AyahFt copyWithCompanion(AyahFtsCompanion data) {
    return AyahFt(
      textNorm: data.textNorm.present ? data.textNorm.value : this.textNorm,
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      translationEn: data.translationEn.present
          ? data.translationEn.value
          : this.translationEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahFt(')
          ..write('textNorm: $textNorm, ')
          ..write('translationId: $translationId, ')
          ..write('translationEn: $translationEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(textNorm, translationId, translationEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahFt &&
          other.textNorm == this.textNorm &&
          other.translationId == this.translationId &&
          other.translationEn == this.translationEn);
}

class AyahFtsCompanion extends UpdateCompanion<AyahFt> {
  final Value<String> textNorm;
  final Value<String> translationId;
  final Value<String> translationEn;
  final Value<int> rowid;
  const AyahFtsCompanion({
    this.textNorm = const Value.absent(),
    this.translationId = const Value.absent(),
    this.translationEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyahFtsCompanion.insert({
    required String textNorm,
    required String translationId,
    required String translationEn,
    this.rowid = const Value.absent(),
  }) : textNorm = Value(textNorm),
       translationId = Value(translationId),
       translationEn = Value(translationEn);
  static Insertable<AyahFt> custom({
    Expression<String>? textNorm,
    Expression<String>? translationId,
    Expression<String>? translationEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (textNorm != null) 'text_norm': textNorm,
      if (translationId != null) 'translation_id': translationId,
      if (translationEn != null) 'translation_en': translationEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyahFtsCompanion copyWith({
    Value<String>? textNorm,
    Value<String>? translationId,
    Value<String>? translationEn,
    Value<int>? rowid,
  }) {
    return AyahFtsCompanion(
      textNorm: textNorm ?? this.textNorm,
      translationId: translationId ?? this.translationId,
      translationEn: translationEn ?? this.translationEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (textNorm.present) {
      map['text_norm'] = Variable<String>(textNorm.value);
    }
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (translationEn.present) {
      map['translation_en'] = Variable<String>(translationEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahFtsCompanion(')
          ..write('textNorm: $textNorm, ')
          ..write('translationId: $translationId, ')
          ..write('translationEn: $translationEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Doa extends Table with TableInfo<Doa, DoaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Doa(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _grupMeta = const VerificationMeta('grup');
  late final GeneratedColumn<String> grup = GeneratedColumn<String>(
    'grup',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
    'nama',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _arMeta = const VerificationMeta('ar');
  late final GeneratedColumn<String> ar = GeneratedColumn<String>(
    'ar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _trMeta = const VerificationMeta('tr');
  late final GeneratedColumn<String> tr = GeneratedColumn<String>(
    'tr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _idnMeta = const VerificationMeta('idn');
  late final GeneratedColumn<String> idn = GeneratedColumn<String>(
    'idn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tentangMeta = const VerificationMeta(
    'tentang',
  );
  late final GeneratedColumn<String> tentang = GeneratedColumn<String>(
    'tentang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grup,
    nama,
    ar,
    tr,
    idn,
    tentang,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doa';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('grup')) {
      context.handle(
        _grupMeta,
        grup.isAcceptableOrUnknown(data['grup']!, _grupMeta),
      );
    }
    if (data.containsKey('nama')) {
      context.handle(
        _namaMeta,
        nama.isAcceptableOrUnknown(data['nama']!, _namaMeta),
      );
    }
    if (data.containsKey('ar')) {
      context.handle(_arMeta, ar.isAcceptableOrUnknown(data['ar']!, _arMeta));
    }
    if (data.containsKey('tr')) {
      context.handle(_trMeta, tr.isAcceptableOrUnknown(data['tr']!, _trMeta));
    }
    if (data.containsKey('idn')) {
      context.handle(
        _idnMeta,
        idn.isAcceptableOrUnknown(data['idn']!, _idnMeta),
      );
    }
    if (data.containsKey('tentang')) {
      context.handle(
        _tentangMeta,
        tentang.isAcceptableOrUnknown(data['tentang']!, _tentangMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      grup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grup'],
      ),
      nama: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nama'],
      ),
      ar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ar'],
      ),
      tr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tr'],
      ),
      idn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idn'],
      ),
      tentang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tentang'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  Doa createAlias(String alias) {
    return Doa(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DoaData extends DataClass implements Insertable<DoaData> {
  final int id;
  final String? grup;
  final String? nama;
  final String? ar;
  final String? tr;
  final String? idn;
  final String? tentang;
  final String? tags;
  const DoaData({
    required this.id,
    this.grup,
    this.nama,
    this.ar,
    this.tr,
    this.idn,
    this.tentang,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || grup != null) {
      map['grup'] = Variable<String>(grup);
    }
    if (!nullToAbsent || nama != null) {
      map['nama'] = Variable<String>(nama);
    }
    if (!nullToAbsent || ar != null) {
      map['ar'] = Variable<String>(ar);
    }
    if (!nullToAbsent || tr != null) {
      map['tr'] = Variable<String>(tr);
    }
    if (!nullToAbsent || idn != null) {
      map['idn'] = Variable<String>(idn);
    }
    if (!nullToAbsent || tentang != null) {
      map['tentang'] = Variable<String>(tentang);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    return map;
  }

  DoaCompanion toCompanion(bool nullToAbsent) {
    return DoaCompanion(
      id: Value(id),
      grup: grup == null && nullToAbsent ? const Value.absent() : Value(grup),
      nama: nama == null && nullToAbsent ? const Value.absent() : Value(nama),
      ar: ar == null && nullToAbsent ? const Value.absent() : Value(ar),
      tr: tr == null && nullToAbsent ? const Value.absent() : Value(tr),
      idn: idn == null && nullToAbsent ? const Value.absent() : Value(idn),
      tentang: tentang == null && nullToAbsent
          ? const Value.absent()
          : Value(tentang),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory DoaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoaData(
      id: serializer.fromJson<int>(json['id']),
      grup: serializer.fromJson<String?>(json['grup']),
      nama: serializer.fromJson<String?>(json['nama']),
      ar: serializer.fromJson<String?>(json['ar']),
      tr: serializer.fromJson<String?>(json['tr']),
      idn: serializer.fromJson<String?>(json['idn']),
      tentang: serializer.fromJson<String?>(json['tentang']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'grup': serializer.toJson<String?>(grup),
      'nama': serializer.toJson<String?>(nama),
      'ar': serializer.toJson<String?>(ar),
      'tr': serializer.toJson<String?>(tr),
      'idn': serializer.toJson<String?>(idn),
      'tentang': serializer.toJson<String?>(tentang),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  DoaData copyWith({
    int? id,
    Value<String?> grup = const Value.absent(),
    Value<String?> nama = const Value.absent(),
    Value<String?> ar = const Value.absent(),
    Value<String?> tr = const Value.absent(),
    Value<String?> idn = const Value.absent(),
    Value<String?> tentang = const Value.absent(),
    Value<String?> tags = const Value.absent(),
  }) => DoaData(
    id: id ?? this.id,
    grup: grup.present ? grup.value : this.grup,
    nama: nama.present ? nama.value : this.nama,
    ar: ar.present ? ar.value : this.ar,
    tr: tr.present ? tr.value : this.tr,
    idn: idn.present ? idn.value : this.idn,
    tentang: tentang.present ? tentang.value : this.tentang,
    tags: tags.present ? tags.value : this.tags,
  );
  DoaData copyWithCompanion(DoaCompanion data) {
    return DoaData(
      id: data.id.present ? data.id.value : this.id,
      grup: data.grup.present ? data.grup.value : this.grup,
      nama: data.nama.present ? data.nama.value : this.nama,
      ar: data.ar.present ? data.ar.value : this.ar,
      tr: data.tr.present ? data.tr.value : this.tr,
      idn: data.idn.present ? data.idn.value : this.idn,
      tentang: data.tentang.present ? data.tentang.value : this.tentang,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoaData(')
          ..write('id: $id, ')
          ..write('grup: $grup, ')
          ..write('nama: $nama, ')
          ..write('ar: $ar, ')
          ..write('tr: $tr, ')
          ..write('idn: $idn, ')
          ..write('tentang: $tentang, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, grup, nama, ar, tr, idn, tentang, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoaData &&
          other.id == this.id &&
          other.grup == this.grup &&
          other.nama == this.nama &&
          other.ar == this.ar &&
          other.tr == this.tr &&
          other.idn == this.idn &&
          other.tentang == this.tentang &&
          other.tags == this.tags);
}

class DoaCompanion extends UpdateCompanion<DoaData> {
  final Value<int> id;
  final Value<String?> grup;
  final Value<String?> nama;
  final Value<String?> ar;
  final Value<String?> tr;
  final Value<String?> idn;
  final Value<String?> tentang;
  final Value<String?> tags;
  const DoaCompanion({
    this.id = const Value.absent(),
    this.grup = const Value.absent(),
    this.nama = const Value.absent(),
    this.ar = const Value.absent(),
    this.tr = const Value.absent(),
    this.idn = const Value.absent(),
    this.tentang = const Value.absent(),
    this.tags = const Value.absent(),
  });
  DoaCompanion.insert({
    this.id = const Value.absent(),
    this.grup = const Value.absent(),
    this.nama = const Value.absent(),
    this.ar = const Value.absent(),
    this.tr = const Value.absent(),
    this.idn = const Value.absent(),
    this.tentang = const Value.absent(),
    this.tags = const Value.absent(),
  });
  static Insertable<DoaData> custom({
    Expression<int>? id,
    Expression<String>? grup,
    Expression<String>? nama,
    Expression<String>? ar,
    Expression<String>? tr,
    Expression<String>? idn,
    Expression<String>? tentang,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grup != null) 'grup': grup,
      if (nama != null) 'nama': nama,
      if (ar != null) 'ar': ar,
      if (tr != null) 'tr': tr,
      if (idn != null) 'idn': idn,
      if (tentang != null) 'tentang': tentang,
      if (tags != null) 'tags': tags,
    });
  }

  DoaCompanion copyWith({
    Value<int>? id,
    Value<String?>? grup,
    Value<String?>? nama,
    Value<String?>? ar,
    Value<String?>? tr,
    Value<String?>? idn,
    Value<String?>? tentang,
    Value<String?>? tags,
  }) {
    return DoaCompanion(
      id: id ?? this.id,
      grup: grup ?? this.grup,
      nama: nama ?? this.nama,
      ar: ar ?? this.ar,
      tr: tr ?? this.tr,
      idn: idn ?? this.idn,
      tentang: tentang ?? this.tentang,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (grup.present) {
      map['grup'] = Variable<String>(grup.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (ar.present) {
      map['ar'] = Variable<String>(ar.value);
    }
    if (tr.present) {
      map['tr'] = Variable<String>(tr.value);
    }
    if (idn.present) {
      map['idn'] = Variable<String>(idn.value);
    }
    if (tentang.present) {
      map['tentang'] = Variable<String>(tentang.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoaCompanion(')
          ..write('id: $id, ')
          ..write('grup: $grup, ')
          ..write('nama: $nama, ')
          ..write('ar: $ar, ')
          ..write('tr: $tr, ')
          ..write('idn: $idn, ')
          ..write('tentang: $tentang, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class AsmaulHusna extends Table with TableInfo<AsmaulHusna, AsmaulHusnaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AsmaulHusna(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _arabicMeta = const VerificationMeta('arabic');
  late final GeneratedColumn<String> arabic = GeneratedColumn<String>(
    'arabic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _latinMeta = const VerificationMeta('latin');
  late final GeneratedColumn<String> latin = GeneratedColumn<String>(
    'latin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _meaningIdMeta = const VerificationMeta(
    'meaningId',
  );
  late final GeneratedColumn<String> meaningId = GeneratedColumn<String>(
    'meaning_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _meaningEnMeta = const VerificationMeta(
    'meaningEn',
  );
  late final GeneratedColumn<String> meaningEn = GeneratedColumn<String>(
    'meaning_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    number,
    arabic,
    latin,
    meaningId,
    meaningEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asmaul_husna';
  @override
  VerificationContext validateIntegrity(
    Insertable<AsmaulHusnaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('arabic')) {
      context.handle(
        _arabicMeta,
        arabic.isAcceptableOrUnknown(data['arabic']!, _arabicMeta),
      );
    }
    if (data.containsKey('latin')) {
      context.handle(
        _latinMeta,
        latin.isAcceptableOrUnknown(data['latin']!, _latinMeta),
      );
    }
    if (data.containsKey('meaning_id')) {
      context.handle(
        _meaningIdMeta,
        meaningId.isAcceptableOrUnknown(data['meaning_id']!, _meaningIdMeta),
      );
    }
    if (data.containsKey('meaning_en')) {
      context.handle(
        _meaningEnMeta,
        meaningEn.isAcceptableOrUnknown(data['meaning_en']!, _meaningEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  AsmaulHusnaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AsmaulHusnaData(
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      arabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic'],
      ),
      latin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latin'],
      ),
      meaningId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_id'],
      ),
      meaningEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_en'],
      ),
    );
  }

  @override
  AsmaulHusna createAlias(String alias) {
    return AsmaulHusna(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AsmaulHusnaData extends DataClass implements Insertable<AsmaulHusnaData> {
  final int number;
  final String? arabic;
  final String? latin;
  final String? meaningId;
  final String? meaningEn;
  const AsmaulHusnaData({
    required this.number,
    this.arabic,
    this.latin,
    this.meaningId,
    this.meaningEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || arabic != null) {
      map['arabic'] = Variable<String>(arabic);
    }
    if (!nullToAbsent || latin != null) {
      map['latin'] = Variable<String>(latin);
    }
    if (!nullToAbsent || meaningId != null) {
      map['meaning_id'] = Variable<String>(meaningId);
    }
    if (!nullToAbsent || meaningEn != null) {
      map['meaning_en'] = Variable<String>(meaningEn);
    }
    return map;
  }

  AsmaulHusnaCompanion toCompanion(bool nullToAbsent) {
    return AsmaulHusnaCompanion(
      number: Value(number),
      arabic: arabic == null && nullToAbsent
          ? const Value.absent()
          : Value(arabic),
      latin: latin == null && nullToAbsent
          ? const Value.absent()
          : Value(latin),
      meaningId: meaningId == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningId),
      meaningEn: meaningEn == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningEn),
    );
  }

  factory AsmaulHusnaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AsmaulHusnaData(
      number: serializer.fromJson<int>(json['number']),
      arabic: serializer.fromJson<String?>(json['arabic']),
      latin: serializer.fromJson<String?>(json['latin']),
      meaningId: serializer.fromJson<String?>(json['meaning_id']),
      meaningEn: serializer.fromJson<String?>(json['meaning_en']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'arabic': serializer.toJson<String?>(arabic),
      'latin': serializer.toJson<String?>(latin),
      'meaning_id': serializer.toJson<String?>(meaningId),
      'meaning_en': serializer.toJson<String?>(meaningEn),
    };
  }

  AsmaulHusnaData copyWith({
    int? number,
    Value<String?> arabic = const Value.absent(),
    Value<String?> latin = const Value.absent(),
    Value<String?> meaningId = const Value.absent(),
    Value<String?> meaningEn = const Value.absent(),
  }) => AsmaulHusnaData(
    number: number ?? this.number,
    arabic: arabic.present ? arabic.value : this.arabic,
    latin: latin.present ? latin.value : this.latin,
    meaningId: meaningId.present ? meaningId.value : this.meaningId,
    meaningEn: meaningEn.present ? meaningEn.value : this.meaningEn,
  );
  AsmaulHusnaData copyWithCompanion(AsmaulHusnaCompanion data) {
    return AsmaulHusnaData(
      number: data.number.present ? data.number.value : this.number,
      arabic: data.arabic.present ? data.arabic.value : this.arabic,
      latin: data.latin.present ? data.latin.value : this.latin,
      meaningId: data.meaningId.present ? data.meaningId.value : this.meaningId,
      meaningEn: data.meaningEn.present ? data.meaningEn.value : this.meaningEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AsmaulHusnaData(')
          ..write('number: $number, ')
          ..write('arabic: $arabic, ')
          ..write('latin: $latin, ')
          ..write('meaningId: $meaningId, ')
          ..write('meaningEn: $meaningEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(number, arabic, latin, meaningId, meaningEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AsmaulHusnaData &&
          other.number == this.number &&
          other.arabic == this.arabic &&
          other.latin == this.latin &&
          other.meaningId == this.meaningId &&
          other.meaningEn == this.meaningEn);
}

class AsmaulHusnaCompanion extends UpdateCompanion<AsmaulHusnaData> {
  final Value<int> number;
  final Value<String?> arabic;
  final Value<String?> latin;
  final Value<String?> meaningId;
  final Value<String?> meaningEn;
  const AsmaulHusnaCompanion({
    this.number = const Value.absent(),
    this.arabic = const Value.absent(),
    this.latin = const Value.absent(),
    this.meaningId = const Value.absent(),
    this.meaningEn = const Value.absent(),
  });
  AsmaulHusnaCompanion.insert({
    this.number = const Value.absent(),
    this.arabic = const Value.absent(),
    this.latin = const Value.absent(),
    this.meaningId = const Value.absent(),
    this.meaningEn = const Value.absent(),
  });
  static Insertable<AsmaulHusnaData> custom({
    Expression<int>? number,
    Expression<String>? arabic,
    Expression<String>? latin,
    Expression<String>? meaningId,
    Expression<String>? meaningEn,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (arabic != null) 'arabic': arabic,
      if (latin != null) 'latin': latin,
      if (meaningId != null) 'meaning_id': meaningId,
      if (meaningEn != null) 'meaning_en': meaningEn,
    });
  }

  AsmaulHusnaCompanion copyWith({
    Value<int>? number,
    Value<String?>? arabic,
    Value<String?>? latin,
    Value<String?>? meaningId,
    Value<String?>? meaningEn,
  }) {
    return AsmaulHusnaCompanion(
      number: number ?? this.number,
      arabic: arabic ?? this.arabic,
      latin: latin ?? this.latin,
      meaningId: meaningId ?? this.meaningId,
      meaningEn: meaningEn ?? this.meaningEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (arabic.present) {
      map['arabic'] = Variable<String>(arabic.value);
    }
    if (latin.present) {
      map['latin'] = Variable<String>(latin.value);
    }
    if (meaningId.present) {
      map['meaning_id'] = Variable<String>(meaningId.value);
    }
    if (meaningEn.present) {
      map['meaning_en'] = Variable<String>(meaningEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AsmaulHusnaCompanion(')
          ..write('number: $number, ')
          ..write('arabic: $arabic, ')
          ..write('latin: $latin, ')
          ..write('meaningId: $meaningId, ')
          ..write('meaningEn: $meaningEn')
          ..write(')'))
        .toString();
  }
}

class PrayerLocation extends Table
    with TableInfo<PrayerLocation, PrayerLocationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PrayerLocation(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _provinceMeta = const VerificationMeta(
    'province',
  );
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
    'province',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tzMeta = const VerificationMeta('tz');
  late final GeneratedColumn<String> tz = GeneratedColumn<String>(
    'tz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _myquranIdMeta = const VerificationMeta(
    'myquranId',
  );
  late final GeneratedColumn<String> myquranId = GeneratedColumn<String>(
    'myquran_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    province,
    lat,
    lng,
    tz,
    myquranId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_location';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerLocationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('province')) {
      context.handle(
        _provinceMeta,
        province.isAcceptableOrUnknown(data['province']!, _provinceMeta),
      );
    } else if (isInserting) {
      context.missing(_provinceMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('tz')) {
      context.handle(_tzMeta, tz.isAcceptableOrUnknown(data['tz']!, _tzMeta));
    } else if (isInserting) {
      context.missing(_tzMeta);
    }
    if (data.containsKey('myquran_id')) {
      context.handle(
        _myquranIdMeta,
        myquranId.isAcceptableOrUnknown(data['myquran_id']!, _myquranIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerLocationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerLocationData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      province: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      tz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tz'],
      )!,
      myquranId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}myquran_id'],
      ),
    );
  }

  @override
  PrayerLocation createAlias(String alias) {
    return PrayerLocation(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PrayerLocationData extends DataClass
    implements Insertable<PrayerLocationData> {
  final String? id;
  final String name;
  final String province;
  final double lat;
  final double lng;
  final String tz;
  final String? myquranId;
  const PrayerLocationData({
    this.id,
    required this.name,
    required this.province,
    required this.lat,
    required this.lng,
    required this.tz,
    this.myquranId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['name'] = Variable<String>(name);
    map['province'] = Variable<String>(province);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['tz'] = Variable<String>(tz);
    if (!nullToAbsent || myquranId != null) {
      map['myquran_id'] = Variable<String>(myquranId);
    }
    return map;
  }

  PrayerLocationCompanion toCompanion(bool nullToAbsent) {
    return PrayerLocationCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: Value(name),
      province: Value(province),
      lat: Value(lat),
      lng: Value(lng),
      tz: Value(tz),
      myquranId: myquranId == null && nullToAbsent
          ? const Value.absent()
          : Value(myquranId),
    );
  }

  factory PrayerLocationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerLocationData(
      id: serializer.fromJson<String?>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      province: serializer.fromJson<String>(json['province']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      tz: serializer.fromJson<String>(json['tz']),
      myquranId: serializer.fromJson<String?>(json['myquran_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String?>(id),
      'name': serializer.toJson<String>(name),
      'province': serializer.toJson<String>(province),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'tz': serializer.toJson<String>(tz),
      'myquran_id': serializer.toJson<String?>(myquranId),
    };
  }

  PrayerLocationData copyWith({
    Value<String?> id = const Value.absent(),
    String? name,
    String? province,
    double? lat,
    double? lng,
    String? tz,
    Value<String?> myquranId = const Value.absent(),
  }) => PrayerLocationData(
    id: id.present ? id.value : this.id,
    name: name ?? this.name,
    province: province ?? this.province,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    tz: tz ?? this.tz,
    myquranId: myquranId.present ? myquranId.value : this.myquranId,
  );
  PrayerLocationData copyWithCompanion(PrayerLocationCompanion data) {
    return PrayerLocationData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      province: data.province.present ? data.province.value : this.province,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      tz: data.tz.present ? data.tz.value : this.tz,
      myquranId: data.myquranId.present ? data.myquranId.value : this.myquranId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLocationData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('tz: $tz, ')
          ..write('myquranId: $myquranId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, province, lat, lng, tz, myquranId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerLocationData &&
          other.id == this.id &&
          other.name == this.name &&
          other.province == this.province &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.tz == this.tz &&
          other.myquranId == this.myquranId);
}

class PrayerLocationCompanion extends UpdateCompanion<PrayerLocationData> {
  final Value<String?> id;
  final Value<String> name;
  final Value<String> province;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> tz;
  final Value<String?> myquranId;
  final Value<int> rowid;
  const PrayerLocationCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.province = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.tz = const Value.absent(),
    this.myquranId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerLocationCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String province,
    required double lat,
    required double lng,
    required String tz,
    this.myquranId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       province = Value(province),
       lat = Value(lat),
       lng = Value(lng),
       tz = Value(tz);
  static Insertable<PrayerLocationData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? province,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? tz,
    Expression<String>? myquranId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (province != null) 'province': province,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (tz != null) 'tz': tz,
      if (myquranId != null) 'myquran_id': myquranId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerLocationCompanion copyWith({
    Value<String?>? id,
    Value<String>? name,
    Value<String>? province,
    Value<double>? lat,
    Value<double>? lng,
    Value<String>? tz,
    Value<String?>? myquranId,
    Value<int>? rowid,
  }) {
    return PrayerLocationCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tz: tz ?? this.tz,
      myquranId: myquranId ?? this.myquranId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (tz.present) {
      map['tz'] = Variable<String>(tz.value);
    }
    if (myquranId.present) {
      map['myquran_id'] = Variable<String>(myquranId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLocationCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('tz: $tz, ')
          ..write('myquranId: $myquranId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MushafEdition extends Table
    with TableInfo<MushafEdition, MushafEditionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MushafEdition(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _packVersionMeta = const VerificationMeta(
    'packVersion',
  );
  late final GeneratedColumn<int> packVersion = GeneratedColumn<int>(
    'pack_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceSha256Meta = const VerificationMeta(
    'sourceSha256',
  );
  late final GeneratedColumn<String> sourceSha256 = GeneratedColumn<String>(
    'source_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _manifestSha256Meta = const VerificationMeta(
    'manifestSha256',
  );
  late final GeneratedColumn<String> manifestSha256 = GeneratedColumn<String>(
    'manifest_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _designWidthMeta = const VerificationMeta(
    'designWidth',
  );
  late final GeneratedColumn<double> designWidth = GeneratedColumn<double>(
    'design_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _wordFontSizeMeta = const VerificationMeta(
    'wordFontSize',
  );
  late final GeneratedColumn<double> wordFontSize = GeneratedColumn<double>(
    'word_font_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packVersion,
    pageCount,
    sourceSha256,
    manifestSha256,
    designWidth,
    wordFontSize,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_edition';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafEditionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pack_version')) {
      context.handle(
        _packVersionMeta,
        packVersion.isAcceptableOrUnknown(
          data['pack_version']!,
          _packVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packVersionMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('source_sha256')) {
      context.handle(
        _sourceSha256Meta,
        sourceSha256.isAcceptableOrUnknown(
          data['source_sha256']!,
          _sourceSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSha256Meta);
    }
    if (data.containsKey('manifest_sha256')) {
      context.handle(
        _manifestSha256Meta,
        manifestSha256.isAcceptableOrUnknown(
          data['manifest_sha256']!,
          _manifestSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manifestSha256Meta);
    }
    if (data.containsKey('design_width')) {
      context.handle(
        _designWidthMeta,
        designWidth.isAcceptableOrUnknown(
          data['design_width']!,
          _designWidthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_designWidthMeta);
    }
    if (data.containsKey('word_font_size')) {
      context.handle(
        _wordFontSizeMeta,
        wordFontSize.isAcceptableOrUnknown(
          data['word_font_size']!,
          _wordFontSizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wordFontSizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MushafEditionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafEditionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      packVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pack_version'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      sourceSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sha256'],
      )!,
      manifestSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_sha256'],
      )!,
      designWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}design_width'],
      )!,
      wordFontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}word_font_size'],
      )!,
    );
  }

  @override
  MushafEdition createAlias(String alias) {
    return MushafEdition(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MushafEditionData extends DataClass
    implements Insertable<MushafEditionData> {
  final String? id;
  final int packVersion;
  final int pageCount;
  final String sourceSha256;
  final String manifestSha256;
  final double designWidth;
  final double wordFontSize;
  const MushafEditionData({
    this.id,
    required this.packVersion,
    required this.pageCount,
    required this.sourceSha256,
    required this.manifestSha256,
    required this.designWidth,
    required this.wordFontSize,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['pack_version'] = Variable<int>(packVersion);
    map['page_count'] = Variable<int>(pageCount);
    map['source_sha256'] = Variable<String>(sourceSha256);
    map['manifest_sha256'] = Variable<String>(manifestSha256);
    map['design_width'] = Variable<double>(designWidth);
    map['word_font_size'] = Variable<double>(wordFontSize);
    return map;
  }

  MushafEditionCompanion toCompanion(bool nullToAbsent) {
    return MushafEditionCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      packVersion: Value(packVersion),
      pageCount: Value(pageCount),
      sourceSha256: Value(sourceSha256),
      manifestSha256: Value(manifestSha256),
      designWidth: Value(designWidth),
      wordFontSize: Value(wordFontSize),
    );
  }

  factory MushafEditionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafEditionData(
      id: serializer.fromJson<String?>(json['id']),
      packVersion: serializer.fromJson<int>(json['pack_version']),
      pageCount: serializer.fromJson<int>(json['page_count']),
      sourceSha256: serializer.fromJson<String>(json['source_sha256']),
      manifestSha256: serializer.fromJson<String>(json['manifest_sha256']),
      designWidth: serializer.fromJson<double>(json['design_width']),
      wordFontSize: serializer.fromJson<double>(json['word_font_size']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String?>(id),
      'pack_version': serializer.toJson<int>(packVersion),
      'page_count': serializer.toJson<int>(pageCount),
      'source_sha256': serializer.toJson<String>(sourceSha256),
      'manifest_sha256': serializer.toJson<String>(manifestSha256),
      'design_width': serializer.toJson<double>(designWidth),
      'word_font_size': serializer.toJson<double>(wordFontSize),
    };
  }

  MushafEditionData copyWith({
    Value<String?> id = const Value.absent(),
    int? packVersion,
    int? pageCount,
    String? sourceSha256,
    String? manifestSha256,
    double? designWidth,
    double? wordFontSize,
  }) => MushafEditionData(
    id: id.present ? id.value : this.id,
    packVersion: packVersion ?? this.packVersion,
    pageCount: pageCount ?? this.pageCount,
    sourceSha256: sourceSha256 ?? this.sourceSha256,
    manifestSha256: manifestSha256 ?? this.manifestSha256,
    designWidth: designWidth ?? this.designWidth,
    wordFontSize: wordFontSize ?? this.wordFontSize,
  );
  MushafEditionData copyWithCompanion(MushafEditionCompanion data) {
    return MushafEditionData(
      id: data.id.present ? data.id.value : this.id,
      packVersion: data.packVersion.present
          ? data.packVersion.value
          : this.packVersion,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      sourceSha256: data.sourceSha256.present
          ? data.sourceSha256.value
          : this.sourceSha256,
      manifestSha256: data.manifestSha256.present
          ? data.manifestSha256.value
          : this.manifestSha256,
      designWidth: data.designWidth.present
          ? data.designWidth.value
          : this.designWidth,
      wordFontSize: data.wordFontSize.present
          ? data.wordFontSize.value
          : this.wordFontSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafEditionData(')
          ..write('id: $id, ')
          ..write('packVersion: $packVersion, ')
          ..write('pageCount: $pageCount, ')
          ..write('sourceSha256: $sourceSha256, ')
          ..write('manifestSha256: $manifestSha256, ')
          ..write('designWidth: $designWidth, ')
          ..write('wordFontSize: $wordFontSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packVersion,
    pageCount,
    sourceSha256,
    manifestSha256,
    designWidth,
    wordFontSize,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafEditionData &&
          other.id == this.id &&
          other.packVersion == this.packVersion &&
          other.pageCount == this.pageCount &&
          other.sourceSha256 == this.sourceSha256 &&
          other.manifestSha256 == this.manifestSha256 &&
          other.designWidth == this.designWidth &&
          other.wordFontSize == this.wordFontSize);
}

class MushafEditionCompanion extends UpdateCompanion<MushafEditionData> {
  final Value<String?> id;
  final Value<int> packVersion;
  final Value<int> pageCount;
  final Value<String> sourceSha256;
  final Value<String> manifestSha256;
  final Value<double> designWidth;
  final Value<double> wordFontSize;
  final Value<int> rowid;
  const MushafEditionCompanion({
    this.id = const Value.absent(),
    this.packVersion = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.sourceSha256 = const Value.absent(),
    this.manifestSha256 = const Value.absent(),
    this.designWidth = const Value.absent(),
    this.wordFontSize = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafEditionCompanion.insert({
    this.id = const Value.absent(),
    required int packVersion,
    required int pageCount,
    required String sourceSha256,
    required String manifestSha256,
    required double designWidth,
    required double wordFontSize,
    this.rowid = const Value.absent(),
  }) : packVersion = Value(packVersion),
       pageCount = Value(pageCount),
       sourceSha256 = Value(sourceSha256),
       manifestSha256 = Value(manifestSha256),
       designWidth = Value(designWidth),
       wordFontSize = Value(wordFontSize);
  static Insertable<MushafEditionData> custom({
    Expression<String>? id,
    Expression<int>? packVersion,
    Expression<int>? pageCount,
    Expression<String>? sourceSha256,
    Expression<String>? manifestSha256,
    Expression<double>? designWidth,
    Expression<double>? wordFontSize,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packVersion != null) 'pack_version': packVersion,
      if (pageCount != null) 'page_count': pageCount,
      if (sourceSha256 != null) 'source_sha256': sourceSha256,
      if (manifestSha256 != null) 'manifest_sha256': manifestSha256,
      if (designWidth != null) 'design_width': designWidth,
      if (wordFontSize != null) 'word_font_size': wordFontSize,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafEditionCompanion copyWith({
    Value<String?>? id,
    Value<int>? packVersion,
    Value<int>? pageCount,
    Value<String>? sourceSha256,
    Value<String>? manifestSha256,
    Value<double>? designWidth,
    Value<double>? wordFontSize,
    Value<int>? rowid,
  }) {
    return MushafEditionCompanion(
      id: id ?? this.id,
      packVersion: packVersion ?? this.packVersion,
      pageCount: pageCount ?? this.pageCount,
      sourceSha256: sourceSha256 ?? this.sourceSha256,
      manifestSha256: manifestSha256 ?? this.manifestSha256,
      designWidth: designWidth ?? this.designWidth,
      wordFontSize: wordFontSize ?? this.wordFontSize,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packVersion.present) {
      map['pack_version'] = Variable<int>(packVersion.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (sourceSha256.present) {
      map['source_sha256'] = Variable<String>(sourceSha256.value);
    }
    if (manifestSha256.present) {
      map['manifest_sha256'] = Variable<String>(manifestSha256.value);
    }
    if (designWidth.present) {
      map['design_width'] = Variable<double>(designWidth.value);
    }
    if (wordFontSize.present) {
      map['word_font_size'] = Variable<double>(wordFontSize.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafEditionCompanion(')
          ..write('id: $id, ')
          ..write('packVersion: $packVersion, ')
          ..write('pageCount: $pageCount, ')
          ..write('sourceSha256: $sourceSha256, ')
          ..write('manifestSha256: $manifestSha256, ')
          ..write('designWidth: $designWidth, ')
          ..write('wordFontSize: $wordFontSize, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MushafAsset extends Table with TableInfo<MushafAsset, MushafAssetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MushafAsset(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES mushaf_edition(id)',
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
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
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rightsStatusMeta = const VerificationMeta(
    'rightsStatus',
  );
  late final GeneratedColumn<String> rightsStatus = GeneratedColumn<String>(
    'rights_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    editionId,
    id,
    kind,
    page,
    path,
    sha256,
    byteSize,
    sourceName,
    rightsStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_asset';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafAssetData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('rights_status')) {
      context.handle(
        _rightsStatusMeta,
        rightsStatus.isAcceptableOrUnknown(
          data['rights_status']!,
          _rightsStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rightsStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {editionId, id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {editionId, path},
  ];
  @override
  MushafAssetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafAssetData(
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      rightsStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rights_status'],
      )!,
    );
  }

  @override
  MushafAsset createAlias(String alias) {
    return MushafAsset(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(edition_id, id)',
    'UNIQUE(edition_id, path)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MushafAssetData extends DataClass implements Insertable<MushafAssetData> {
  final String editionId;
  final String id;
  final String kind;
  final int? page;
  final String path;
  final String sha256;
  final int byteSize;
  final String sourceName;
  final String rightsStatus;
  const MushafAssetData({
    required this.editionId,
    required this.id,
    required this.kind,
    this.page,
    required this.path,
    required this.sha256,
    required this.byteSize,
    required this.sourceName,
    required this.rightsStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition_id'] = Variable<String>(editionId);
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    map['path'] = Variable<String>(path);
    map['sha256'] = Variable<String>(sha256);
    map['byte_size'] = Variable<int>(byteSize);
    map['source_name'] = Variable<String>(sourceName);
    map['rights_status'] = Variable<String>(rightsStatus);
    return map;
  }

  MushafAssetCompanion toCompanion(bool nullToAbsent) {
    return MushafAssetCompanion(
      editionId: Value(editionId),
      id: Value(id),
      kind: Value(kind),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      path: Value(path),
      sha256: Value(sha256),
      byteSize: Value(byteSize),
      sourceName: Value(sourceName),
      rightsStatus: Value(rightsStatus),
    );
  }

  factory MushafAssetData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafAssetData(
      editionId: serializer.fromJson<String>(json['edition_id']),
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      page: serializer.fromJson<int?>(json['page']),
      path: serializer.fromJson<String>(json['path']),
      sha256: serializer.fromJson<String>(json['sha256']),
      byteSize: serializer.fromJson<int>(json['byte_size']),
      sourceName: serializer.fromJson<String>(json['source_name']),
      rightsStatus: serializer.fromJson<String>(json['rights_status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'edition_id': serializer.toJson<String>(editionId),
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'page': serializer.toJson<int?>(page),
      'path': serializer.toJson<String>(path),
      'sha256': serializer.toJson<String>(sha256),
      'byte_size': serializer.toJson<int>(byteSize),
      'source_name': serializer.toJson<String>(sourceName),
      'rights_status': serializer.toJson<String>(rightsStatus),
    };
  }

  MushafAssetData copyWith({
    String? editionId,
    String? id,
    String? kind,
    Value<int?> page = const Value.absent(),
    String? path,
    String? sha256,
    int? byteSize,
    String? sourceName,
    String? rightsStatus,
  }) => MushafAssetData(
    editionId: editionId ?? this.editionId,
    id: id ?? this.id,
    kind: kind ?? this.kind,
    page: page.present ? page.value : this.page,
    path: path ?? this.path,
    sha256: sha256 ?? this.sha256,
    byteSize: byteSize ?? this.byteSize,
    sourceName: sourceName ?? this.sourceName,
    rightsStatus: rightsStatus ?? this.rightsStatus,
  );
  MushafAssetData copyWithCompanion(MushafAssetCompanion data) {
    return MushafAssetData(
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      page: data.page.present ? data.page.value : this.page,
      path: data.path.present ? data.path.value : this.path,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      rightsStatus: data.rightsStatus.present
          ? data.rightsStatus.value
          : this.rightsStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafAssetData(')
          ..write('editionId: $editionId, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('page: $page, ')
          ..write('path: $path, ')
          ..write('sha256: $sha256, ')
          ..write('byteSize: $byteSize, ')
          ..write('sourceName: $sourceName, ')
          ..write('rightsStatus: $rightsStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    editionId,
    id,
    kind,
    page,
    path,
    sha256,
    byteSize,
    sourceName,
    rightsStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafAssetData &&
          other.editionId == this.editionId &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.page == this.page &&
          other.path == this.path &&
          other.sha256 == this.sha256 &&
          other.byteSize == this.byteSize &&
          other.sourceName == this.sourceName &&
          other.rightsStatus == this.rightsStatus);
}

class MushafAssetCompanion extends UpdateCompanion<MushafAssetData> {
  final Value<String> editionId;
  final Value<String> id;
  final Value<String> kind;
  final Value<int?> page;
  final Value<String> path;
  final Value<String> sha256;
  final Value<int> byteSize;
  final Value<String> sourceName;
  final Value<String> rightsStatus;
  final Value<int> rowid;
  const MushafAssetCompanion({
    this.editionId = const Value.absent(),
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.page = const Value.absent(),
    this.path = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.rightsStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafAssetCompanion.insert({
    required String editionId,
    required String id,
    required String kind,
    this.page = const Value.absent(),
    required String path,
    required String sha256,
    required int byteSize,
    required String sourceName,
    required String rightsStatus,
    this.rowid = const Value.absent(),
  }) : editionId = Value(editionId),
       id = Value(id),
       kind = Value(kind),
       path = Value(path),
       sha256 = Value(sha256),
       byteSize = Value(byteSize),
       sourceName = Value(sourceName),
       rightsStatus = Value(rightsStatus);
  static Insertable<MushafAssetData> custom({
    Expression<String>? editionId,
    Expression<String>? id,
    Expression<String>? kind,
    Expression<int>? page,
    Expression<String>? path,
    Expression<String>? sha256,
    Expression<int>? byteSize,
    Expression<String>? sourceName,
    Expression<String>? rightsStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (editionId != null) 'edition_id': editionId,
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (page != null) 'page': page,
      if (path != null) 'path': path,
      if (sha256 != null) 'sha256': sha256,
      if (byteSize != null) 'byte_size': byteSize,
      if (sourceName != null) 'source_name': sourceName,
      if (rightsStatus != null) 'rights_status': rightsStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafAssetCompanion copyWith({
    Value<String>? editionId,
    Value<String>? id,
    Value<String>? kind,
    Value<int?>? page,
    Value<String>? path,
    Value<String>? sha256,
    Value<int>? byteSize,
    Value<String>? sourceName,
    Value<String>? rightsStatus,
    Value<int>? rowid,
  }) {
    return MushafAssetCompanion(
      editionId: editionId ?? this.editionId,
      id: id ?? this.id,
      kind: kind ?? this.kind,
      page: page ?? this.page,
      path: path ?? this.path,
      sha256: sha256 ?? this.sha256,
      byteSize: byteSize ?? this.byteSize,
      sourceName: sourceName ?? this.sourceName,
      rightsStatus: rightsStatus ?? this.rightsStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (rightsStatus.present) {
      map['rights_status'] = Variable<String>(rightsStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafAssetCompanion(')
          ..write('editionId: $editionId, ')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('page: $page, ')
          ..write('path: $path, ')
          ..write('sha256: $sha256, ')
          ..write('byteSize: $byteSize, ')
          ..write('sourceName: $sourceName, ')
          ..write('rightsStatus: $rightsStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MushafPage extends Table with TableInfo<MushafPage, MushafPageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MushafPage(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES mushaf_edition(id)',
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
  static const VerificationMeta _fontAssetIdMeta = const VerificationMeta(
    'fontAssetId',
  );
  late final GeneratedColumn<String> fontAssetId = GeneratedColumn<String>(
    'font_asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lineCountMeta = const VerificationMeta(
    'lineCount',
  );
  late final GeneratedColumn<int> lineCount = GeneratedColumn<int>(
    'line_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    editionId,
    page,
    fontAssetId,
    lineCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_page';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafPageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editionIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('font_asset_id')) {
      context.handle(
        _fontAssetIdMeta,
        fontAssetId.isAcceptableOrUnknown(
          data['font_asset_id']!,
          _fontAssetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fontAssetIdMeta);
    }
    if (data.containsKey('line_count')) {
      context.handle(
        _lineCountMeta,
        lineCount.isAcceptableOrUnknown(data['line_count']!, _lineCountMeta),
      );
    } else if (isInserting) {
      context.missing(_lineCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {editionId, page};
  @override
  MushafPageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafPageData(
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      fontAssetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}font_asset_id'],
      )!,
      lineCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_count'],
      )!,
    );
  }

  @override
  MushafPage createAlias(String alias) {
    return MushafPage(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(edition_id, page)',
    'FOREIGN KEY(edition_id, font_asset_id)REFERENCES mushaf_asset(edition_id, id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MushafPageData extends DataClass implements Insertable<MushafPageData> {
  final String editionId;
  final int page;
  final String fontAssetId;
  final int lineCount;
  const MushafPageData({
    required this.editionId,
    required this.page,
    required this.fontAssetId,
    required this.lineCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition_id'] = Variable<String>(editionId);
    map['page'] = Variable<int>(page);
    map['font_asset_id'] = Variable<String>(fontAssetId);
    map['line_count'] = Variable<int>(lineCount);
    return map;
  }

  MushafPageCompanion toCompanion(bool nullToAbsent) {
    return MushafPageCompanion(
      editionId: Value(editionId),
      page: Value(page),
      fontAssetId: Value(fontAssetId),
      lineCount: Value(lineCount),
    );
  }

  factory MushafPageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafPageData(
      editionId: serializer.fromJson<String>(json['edition_id']),
      page: serializer.fromJson<int>(json['page']),
      fontAssetId: serializer.fromJson<String>(json['font_asset_id']),
      lineCount: serializer.fromJson<int>(json['line_count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'edition_id': serializer.toJson<String>(editionId),
      'page': serializer.toJson<int>(page),
      'font_asset_id': serializer.toJson<String>(fontAssetId),
      'line_count': serializer.toJson<int>(lineCount),
    };
  }

  MushafPageData copyWith({
    String? editionId,
    int? page,
    String? fontAssetId,
    int? lineCount,
  }) => MushafPageData(
    editionId: editionId ?? this.editionId,
    page: page ?? this.page,
    fontAssetId: fontAssetId ?? this.fontAssetId,
    lineCount: lineCount ?? this.lineCount,
  );
  MushafPageData copyWithCompanion(MushafPageCompanion data) {
    return MushafPageData(
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      page: data.page.present ? data.page.value : this.page,
      fontAssetId: data.fontAssetId.present
          ? data.fontAssetId.value
          : this.fontAssetId,
      lineCount: data.lineCount.present ? data.lineCount.value : this.lineCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafPageData(')
          ..write('editionId: $editionId, ')
          ..write('page: $page, ')
          ..write('fontAssetId: $fontAssetId, ')
          ..write('lineCount: $lineCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(editionId, page, fontAssetId, lineCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafPageData &&
          other.editionId == this.editionId &&
          other.page == this.page &&
          other.fontAssetId == this.fontAssetId &&
          other.lineCount == this.lineCount);
}

class MushafPageCompanion extends UpdateCompanion<MushafPageData> {
  final Value<String> editionId;
  final Value<int> page;
  final Value<String> fontAssetId;
  final Value<int> lineCount;
  final Value<int> rowid;
  const MushafPageCompanion({
    this.editionId = const Value.absent(),
    this.page = const Value.absent(),
    this.fontAssetId = const Value.absent(),
    this.lineCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafPageCompanion.insert({
    required String editionId,
    required int page,
    required String fontAssetId,
    required int lineCount,
    this.rowid = const Value.absent(),
  }) : editionId = Value(editionId),
       page = Value(page),
       fontAssetId = Value(fontAssetId),
       lineCount = Value(lineCount);
  static Insertable<MushafPageData> custom({
    Expression<String>? editionId,
    Expression<int>? page,
    Expression<String>? fontAssetId,
    Expression<int>? lineCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (editionId != null) 'edition_id': editionId,
      if (page != null) 'page': page,
      if (fontAssetId != null) 'font_asset_id': fontAssetId,
      if (lineCount != null) 'line_count': lineCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafPageCompanion copyWith({
    Value<String>? editionId,
    Value<int>? page,
    Value<String>? fontAssetId,
    Value<int>? lineCount,
    Value<int>? rowid,
  }) {
    return MushafPageCompanion(
      editionId: editionId ?? this.editionId,
      page: page ?? this.page,
      fontAssetId: fontAssetId ?? this.fontAssetId,
      lineCount: lineCount ?? this.lineCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (fontAssetId.present) {
      map['font_asset_id'] = Variable<String>(fontAssetId.value);
    }
    if (lineCount.present) {
      map['line_count'] = Variable<int>(lineCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafPageCompanion(')
          ..write('editionId: $editionId, ')
          ..write('page: $page, ')
          ..write('fontAssetId: $fontAssetId, ')
          ..write('lineCount: $lineCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MushafLine extends Table with TableInfo<MushafLine, MushafLineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MushafLine(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _lineMeta = const VerificationMeta('line');
  late final GeneratedColumn<int> line = GeneratedColumn<int>(
    'line',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _centeredMeta = const VerificationMeta(
    'centered',
  );
  late final GeneratedColumn<int> centered = GeneratedColumn<int>(
    'centered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
    'surah',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _firstWordIdMeta = const VerificationMeta(
    'firstWordId',
  );
  late final GeneratedColumn<int> firstWordId = GeneratedColumn<int>(
    'first_word_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastWordIdMeta = const VerificationMeta(
    'lastWordId',
  );
  late final GeneratedColumn<int> lastWordId = GeneratedColumn<int>(
    'last_word_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    editionId,
    page,
    line,
    kind,
    centered,
    surah,
    firstWordId,
    lastWordId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_line';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafLineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editionIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('line')) {
      context.handle(
        _lineMeta,
        line.isAcceptableOrUnknown(data['line']!, _lineMeta),
      );
    } else if (isInserting) {
      context.missing(_lineMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('centered')) {
      context.handle(
        _centeredMeta,
        centered.isAcceptableOrUnknown(data['centered']!, _centeredMeta),
      );
    } else if (isInserting) {
      context.missing(_centeredMeta);
    }
    if (data.containsKey('surah')) {
      context.handle(
        _surahMeta,
        surah.isAcceptableOrUnknown(data['surah']!, _surahMeta),
      );
    }
    if (data.containsKey('first_word_id')) {
      context.handle(
        _firstWordIdMeta,
        firstWordId.isAcceptableOrUnknown(
          data['first_word_id']!,
          _firstWordIdMeta,
        ),
      );
    }
    if (data.containsKey('last_word_id')) {
      context.handle(
        _lastWordIdMeta,
        lastWordId.isAcceptableOrUnknown(
          data['last_word_id']!,
          _lastWordIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {editionId, page, line};
  @override
  MushafLineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafLineData(
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      line: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      centered: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}centered'],
      )!,
      surah: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah'],
      ),
      firstWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_word_id'],
      ),
      lastWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_word_id'],
      ),
    );
  }

  @override
  MushafLine createAlias(String alias) {
    return MushafLine(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(edition_id, page, line)',
    'FOREIGN KEY(edition_id, page)REFERENCES mushaf_page(edition_id, page)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MushafLineData extends DataClass implements Insertable<MushafLineData> {
  final String editionId;
  final int page;
  final int line;
  final String kind;
  final int centered;
  final int? surah;
  final int? firstWordId;
  final int? lastWordId;
  const MushafLineData({
    required this.editionId,
    required this.page,
    required this.line,
    required this.kind,
    required this.centered,
    this.surah,
    this.firstWordId,
    this.lastWordId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition_id'] = Variable<String>(editionId);
    map['page'] = Variable<int>(page);
    map['line'] = Variable<int>(line);
    map['kind'] = Variable<String>(kind);
    map['centered'] = Variable<int>(centered);
    if (!nullToAbsent || surah != null) {
      map['surah'] = Variable<int>(surah);
    }
    if (!nullToAbsent || firstWordId != null) {
      map['first_word_id'] = Variable<int>(firstWordId);
    }
    if (!nullToAbsent || lastWordId != null) {
      map['last_word_id'] = Variable<int>(lastWordId);
    }
    return map;
  }

  MushafLineCompanion toCompanion(bool nullToAbsent) {
    return MushafLineCompanion(
      editionId: Value(editionId),
      page: Value(page),
      line: Value(line),
      kind: Value(kind),
      centered: Value(centered),
      surah: surah == null && nullToAbsent
          ? const Value.absent()
          : Value(surah),
      firstWordId: firstWordId == null && nullToAbsent
          ? const Value.absent()
          : Value(firstWordId),
      lastWordId: lastWordId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWordId),
    );
  }

  factory MushafLineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafLineData(
      editionId: serializer.fromJson<String>(json['edition_id']),
      page: serializer.fromJson<int>(json['page']),
      line: serializer.fromJson<int>(json['line']),
      kind: serializer.fromJson<String>(json['kind']),
      centered: serializer.fromJson<int>(json['centered']),
      surah: serializer.fromJson<int?>(json['surah']),
      firstWordId: serializer.fromJson<int?>(json['first_word_id']),
      lastWordId: serializer.fromJson<int?>(json['last_word_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'edition_id': serializer.toJson<String>(editionId),
      'page': serializer.toJson<int>(page),
      'line': serializer.toJson<int>(line),
      'kind': serializer.toJson<String>(kind),
      'centered': serializer.toJson<int>(centered),
      'surah': serializer.toJson<int?>(surah),
      'first_word_id': serializer.toJson<int?>(firstWordId),
      'last_word_id': serializer.toJson<int?>(lastWordId),
    };
  }

  MushafLineData copyWith({
    String? editionId,
    int? page,
    int? line,
    String? kind,
    int? centered,
    Value<int?> surah = const Value.absent(),
    Value<int?> firstWordId = const Value.absent(),
    Value<int?> lastWordId = const Value.absent(),
  }) => MushafLineData(
    editionId: editionId ?? this.editionId,
    page: page ?? this.page,
    line: line ?? this.line,
    kind: kind ?? this.kind,
    centered: centered ?? this.centered,
    surah: surah.present ? surah.value : this.surah,
    firstWordId: firstWordId.present ? firstWordId.value : this.firstWordId,
    lastWordId: lastWordId.present ? lastWordId.value : this.lastWordId,
  );
  MushafLineData copyWithCompanion(MushafLineCompanion data) {
    return MushafLineData(
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      page: data.page.present ? data.page.value : this.page,
      line: data.line.present ? data.line.value : this.line,
      kind: data.kind.present ? data.kind.value : this.kind,
      centered: data.centered.present ? data.centered.value : this.centered,
      surah: data.surah.present ? data.surah.value : this.surah,
      firstWordId: data.firstWordId.present
          ? data.firstWordId.value
          : this.firstWordId,
      lastWordId: data.lastWordId.present
          ? data.lastWordId.value
          : this.lastWordId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafLineData(')
          ..write('editionId: $editionId, ')
          ..write('page: $page, ')
          ..write('line: $line, ')
          ..write('kind: $kind, ')
          ..write('centered: $centered, ')
          ..write('surah: $surah, ')
          ..write('firstWordId: $firstWordId, ')
          ..write('lastWordId: $lastWordId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    editionId,
    page,
    line,
    kind,
    centered,
    surah,
    firstWordId,
    lastWordId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafLineData &&
          other.editionId == this.editionId &&
          other.page == this.page &&
          other.line == this.line &&
          other.kind == this.kind &&
          other.centered == this.centered &&
          other.surah == this.surah &&
          other.firstWordId == this.firstWordId &&
          other.lastWordId == this.lastWordId);
}

class MushafLineCompanion extends UpdateCompanion<MushafLineData> {
  final Value<String> editionId;
  final Value<int> page;
  final Value<int> line;
  final Value<String> kind;
  final Value<int> centered;
  final Value<int?> surah;
  final Value<int?> firstWordId;
  final Value<int?> lastWordId;
  final Value<int> rowid;
  const MushafLineCompanion({
    this.editionId = const Value.absent(),
    this.page = const Value.absent(),
    this.line = const Value.absent(),
    this.kind = const Value.absent(),
    this.centered = const Value.absent(),
    this.surah = const Value.absent(),
    this.firstWordId = const Value.absent(),
    this.lastWordId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafLineCompanion.insert({
    required String editionId,
    required int page,
    required int line,
    required String kind,
    required int centered,
    this.surah = const Value.absent(),
    this.firstWordId = const Value.absent(),
    this.lastWordId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : editionId = Value(editionId),
       page = Value(page),
       line = Value(line),
       kind = Value(kind),
       centered = Value(centered);
  static Insertable<MushafLineData> custom({
    Expression<String>? editionId,
    Expression<int>? page,
    Expression<int>? line,
    Expression<String>? kind,
    Expression<int>? centered,
    Expression<int>? surah,
    Expression<int>? firstWordId,
    Expression<int>? lastWordId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (editionId != null) 'edition_id': editionId,
      if (page != null) 'page': page,
      if (line != null) 'line': line,
      if (kind != null) 'kind': kind,
      if (centered != null) 'centered': centered,
      if (surah != null) 'surah': surah,
      if (firstWordId != null) 'first_word_id': firstWordId,
      if (lastWordId != null) 'last_word_id': lastWordId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafLineCompanion copyWith({
    Value<String>? editionId,
    Value<int>? page,
    Value<int>? line,
    Value<String>? kind,
    Value<int>? centered,
    Value<int?>? surah,
    Value<int?>? firstWordId,
    Value<int?>? lastWordId,
    Value<int>? rowid,
  }) {
    return MushafLineCompanion(
      editionId: editionId ?? this.editionId,
      page: page ?? this.page,
      line: line ?? this.line,
      kind: kind ?? this.kind,
      centered: centered ?? this.centered,
      surah: surah ?? this.surah,
      firstWordId: firstWordId ?? this.firstWordId,
      lastWordId: lastWordId ?? this.lastWordId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (line.present) {
      map['line'] = Variable<int>(line.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (centered.present) {
      map['centered'] = Variable<int>(centered.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (firstWordId.present) {
      map['first_word_id'] = Variable<int>(firstWordId.value);
    }
    if (lastWordId.present) {
      map['last_word_id'] = Variable<int>(lastWordId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafLineCompanion(')
          ..write('editionId: $editionId, ')
          ..write('page: $page, ')
          ..write('line: $line, ')
          ..write('kind: $kind, ')
          ..write('centered: $centered, ')
          ..write('surah: $surah, ')
          ..write('firstWordId: $firstWordId, ')
          ..write('lastWordId: $lastWordId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MushafWord extends Table with TableInfo<MushafWord, MushafWordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MushafWord(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES ayah(id)',
  );
  static const VerificationMeta _wordKeyMeta = const VerificationMeta(
    'wordKey',
  );
  late final GeneratedColumn<String> wordKey = GeneratedColumn<String>(
    'word_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _glyphMeta = const VerificationMeta('glyph');
  late final GeneratedColumn<String> glyph = GeneratedColumn<String>(
    'glyph',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _lineMeta = const VerificationMeta('line');
  late final GeneratedColumn<int> line = GeneratedColumn<int>(
    'line',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    editionId,
    id,
    ayahId,
    wordKey,
    glyph,
    page,
    line,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_word';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafWordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editionIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(
        _ayahIdMeta,
        ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('word_key')) {
      context.handle(
        _wordKeyMeta,
        wordKey.isAcceptableOrUnknown(data['word_key']!, _wordKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_wordKeyMeta);
    }
    if (data.containsKey('glyph')) {
      context.handle(
        _glyphMeta,
        glyph.isAcceptableOrUnknown(data['glyph']!, _glyphMeta),
      );
    } else if (isInserting) {
      context.missing(_glyphMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('line')) {
      context.handle(
        _lineMeta,
        line.isAcceptableOrUnknown(data['line']!, _lineMeta),
      );
    } else if (isInserting) {
      context.missing(_lineMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {editionId, id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {editionId, wordKey},
  ];
  @override
  MushafWordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafWordData(
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      wordKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_key'],
      )!,
      glyph: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}glyph'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      line: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  MushafWord createAlias(String alias) {
    return MushafWord(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(edition_id, id)',
    'UNIQUE(edition_id, word_key)',
    'FOREIGN KEY(edition_id, page, line)REFERENCES mushaf_line(edition_id, page, line)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MushafWordData extends DataClass implements Insertable<MushafWordData> {
  final String editionId;
  final int id;
  final int ayahId;
  final String wordKey;
  final String glyph;
  final int page;
  final int line;
  final int position;
  const MushafWordData({
    required this.editionId,
    required this.id,
    required this.ayahId,
    required this.wordKey,
    required this.glyph,
    required this.page,
    required this.line,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition_id'] = Variable<String>(editionId);
    map['id'] = Variable<int>(id);
    map['ayah_id'] = Variable<int>(ayahId);
    map['word_key'] = Variable<String>(wordKey);
    map['glyph'] = Variable<String>(glyph);
    map['page'] = Variable<int>(page);
    map['line'] = Variable<int>(line);
    map['position'] = Variable<int>(position);
    return map;
  }

  MushafWordCompanion toCompanion(bool nullToAbsent) {
    return MushafWordCompanion(
      editionId: Value(editionId),
      id: Value(id),
      ayahId: Value(ayahId),
      wordKey: Value(wordKey),
      glyph: Value(glyph),
      page: Value(page),
      line: Value(line),
      position: Value(position),
    );
  }

  factory MushafWordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafWordData(
      editionId: serializer.fromJson<String>(json['edition_id']),
      id: serializer.fromJson<int>(json['id']),
      ayahId: serializer.fromJson<int>(json['ayah_id']),
      wordKey: serializer.fromJson<String>(json['word_key']),
      glyph: serializer.fromJson<String>(json['glyph']),
      page: serializer.fromJson<int>(json['page']),
      line: serializer.fromJson<int>(json['line']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'edition_id': serializer.toJson<String>(editionId),
      'id': serializer.toJson<int>(id),
      'ayah_id': serializer.toJson<int>(ayahId),
      'word_key': serializer.toJson<String>(wordKey),
      'glyph': serializer.toJson<String>(glyph),
      'page': serializer.toJson<int>(page),
      'line': serializer.toJson<int>(line),
      'position': serializer.toJson<int>(position),
    };
  }

  MushafWordData copyWith({
    String? editionId,
    int? id,
    int? ayahId,
    String? wordKey,
    String? glyph,
    int? page,
    int? line,
    int? position,
  }) => MushafWordData(
    editionId: editionId ?? this.editionId,
    id: id ?? this.id,
    ayahId: ayahId ?? this.ayahId,
    wordKey: wordKey ?? this.wordKey,
    glyph: glyph ?? this.glyph,
    page: page ?? this.page,
    line: line ?? this.line,
    position: position ?? this.position,
  );
  MushafWordData copyWithCompanion(MushafWordCompanion data) {
    return MushafWordData(
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      id: data.id.present ? data.id.value : this.id,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      wordKey: data.wordKey.present ? data.wordKey.value : this.wordKey,
      glyph: data.glyph.present ? data.glyph.value : this.glyph,
      page: data.page.present ? data.page.value : this.page,
      line: data.line.present ? data.line.value : this.line,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafWordData(')
          ..write('editionId: $editionId, ')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('wordKey: $wordKey, ')
          ..write('glyph: $glyph, ')
          ..write('page: $page, ')
          ..write('line: $line, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(editionId, id, ayahId, wordKey, glyph, page, line, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafWordData &&
          other.editionId == this.editionId &&
          other.id == this.id &&
          other.ayahId == this.ayahId &&
          other.wordKey == this.wordKey &&
          other.glyph == this.glyph &&
          other.page == this.page &&
          other.line == this.line &&
          other.position == this.position);
}

class MushafWordCompanion extends UpdateCompanion<MushafWordData> {
  final Value<String> editionId;
  final Value<int> id;
  final Value<int> ayahId;
  final Value<String> wordKey;
  final Value<String> glyph;
  final Value<int> page;
  final Value<int> line;
  final Value<int> position;
  final Value<int> rowid;
  const MushafWordCompanion({
    this.editionId = const Value.absent(),
    this.id = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.wordKey = const Value.absent(),
    this.glyph = const Value.absent(),
    this.page = const Value.absent(),
    this.line = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafWordCompanion.insert({
    required String editionId,
    required int id,
    required int ayahId,
    required String wordKey,
    required String glyph,
    required int page,
    required int line,
    required int position,
    this.rowid = const Value.absent(),
  }) : editionId = Value(editionId),
       id = Value(id),
       ayahId = Value(ayahId),
       wordKey = Value(wordKey),
       glyph = Value(glyph),
       page = Value(page),
       line = Value(line),
       position = Value(position);
  static Insertable<MushafWordData> custom({
    Expression<String>? editionId,
    Expression<int>? id,
    Expression<int>? ayahId,
    Expression<String>? wordKey,
    Expression<String>? glyph,
    Expression<int>? page,
    Expression<int>? line,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (editionId != null) 'edition_id': editionId,
      if (id != null) 'id': id,
      if (ayahId != null) 'ayah_id': ayahId,
      if (wordKey != null) 'word_key': wordKey,
      if (glyph != null) 'glyph': glyph,
      if (page != null) 'page': page,
      if (line != null) 'line': line,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafWordCompanion copyWith({
    Value<String>? editionId,
    Value<int>? id,
    Value<int>? ayahId,
    Value<String>? wordKey,
    Value<String>? glyph,
    Value<int>? page,
    Value<int>? line,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return MushafWordCompanion(
      editionId: editionId ?? this.editionId,
      id: id ?? this.id,
      ayahId: ayahId ?? this.ayahId,
      wordKey: wordKey ?? this.wordKey,
      glyph: glyph ?? this.glyph,
      page: page ?? this.page,
      line: line ?? this.line,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (wordKey.present) {
      map['word_key'] = Variable<String>(wordKey.value);
    }
    if (glyph.present) {
      map['glyph'] = Variable<String>(glyph.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (line.present) {
      map['line'] = Variable<int>(line.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafWordCompanion(')
          ..write('editionId: $editionId, ')
          ..write('id: $id, ')
          ..write('ayahId: $ayahId, ')
          ..write('wordKey: $wordKey, ')
          ..write('glyph: $glyph, ')
          ..write('page: $page, ')
          ..write('line: $line, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MushafAyahPage extends Table
    with TableInfo<MushafAyahPage, MushafAyahPageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MushafAyahPage(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _editionIdMeta = const VerificationMeta(
    'editionId',
  );
  late final GeneratedColumn<String> editionId = GeneratedColumn<String>(
    'edition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  late final GeneratedColumn<int> ayahId = GeneratedColumn<int>(
    'ayah_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES ayah(id)',
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
  static const VerificationMeta _firstLineMeta = const VerificationMeta(
    'firstLine',
  );
  late final GeneratedColumn<int> firstLine = GeneratedColumn<int>(
    'first_line',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastLineMeta = const VerificationMeta(
    'lastLine',
  );
  late final GeneratedColumn<int> lastLine = GeneratedColumn<int>(
    'last_line',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstWordIdMeta = const VerificationMeta(
    'firstWordId',
  );
  late final GeneratedColumn<int> firstWordId = GeneratedColumn<int>(
    'first_word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastWordIdMeta = const VerificationMeta(
    'lastWordId',
  );
  late final GeneratedColumn<int> lastWordId = GeneratedColumn<int>(
    'last_word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    editionId,
    ayahId,
    page,
    firstLine,
    lastLine,
    firstWordId,
    lastWordId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf_ayah_page';
  @override
  VerificationContext validateIntegrity(
    Insertable<MushafAyahPageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('edition_id')) {
      context.handle(
        _editionIdMeta,
        editionId.isAcceptableOrUnknown(data['edition_id']!, _editionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_editionIdMeta);
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
    if (data.containsKey('first_line')) {
      context.handle(
        _firstLineMeta,
        firstLine.isAcceptableOrUnknown(data['first_line']!, _firstLineMeta),
      );
    } else if (isInserting) {
      context.missing(_firstLineMeta);
    }
    if (data.containsKey('last_line')) {
      context.handle(
        _lastLineMeta,
        lastLine.isAcceptableOrUnknown(data['last_line']!, _lastLineMeta),
      );
    } else if (isInserting) {
      context.missing(_lastLineMeta);
    }
    if (data.containsKey('first_word_id')) {
      context.handle(
        _firstWordIdMeta,
        firstWordId.isAcceptableOrUnknown(
          data['first_word_id']!,
          _firstWordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstWordIdMeta);
    }
    if (data.containsKey('last_word_id')) {
      context.handle(
        _lastWordIdMeta,
        lastWordId.isAcceptableOrUnknown(
          data['last_word_id']!,
          _lastWordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastWordIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {editionId, ayahId, page};
  @override
  MushafAyahPageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafAyahPageData(
      editionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition_id'],
      )!,
      ayahId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      firstLine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_line'],
      )!,
      lastLine: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_line'],
      )!,
      firstWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_word_id'],
      )!,
      lastWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_word_id'],
      )!,
    );
  }

  @override
  MushafAyahPage createAlias(String alias) {
    return MushafAyahPage(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(edition_id, ayah_id, page)',
    'FOREIGN KEY(edition_id, page)REFERENCES mushaf_page(edition_id, page)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class MushafAyahPageData extends DataClass
    implements Insertable<MushafAyahPageData> {
  final String editionId;
  final int ayahId;
  final int page;
  final int firstLine;
  final int lastLine;
  final int firstWordId;
  final int lastWordId;
  const MushafAyahPageData({
    required this.editionId,
    required this.ayahId,
    required this.page,
    required this.firstLine,
    required this.lastLine,
    required this.firstWordId,
    required this.lastWordId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['edition_id'] = Variable<String>(editionId);
    map['ayah_id'] = Variable<int>(ayahId);
    map['page'] = Variable<int>(page);
    map['first_line'] = Variable<int>(firstLine);
    map['last_line'] = Variable<int>(lastLine);
    map['first_word_id'] = Variable<int>(firstWordId);
    map['last_word_id'] = Variable<int>(lastWordId);
    return map;
  }

  MushafAyahPageCompanion toCompanion(bool nullToAbsent) {
    return MushafAyahPageCompanion(
      editionId: Value(editionId),
      ayahId: Value(ayahId),
      page: Value(page),
      firstLine: Value(firstLine),
      lastLine: Value(lastLine),
      firstWordId: Value(firstWordId),
      lastWordId: Value(lastWordId),
    );
  }

  factory MushafAyahPageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafAyahPageData(
      editionId: serializer.fromJson<String>(json['edition_id']),
      ayahId: serializer.fromJson<int>(json['ayah_id']),
      page: serializer.fromJson<int>(json['page']),
      firstLine: serializer.fromJson<int>(json['first_line']),
      lastLine: serializer.fromJson<int>(json['last_line']),
      firstWordId: serializer.fromJson<int>(json['first_word_id']),
      lastWordId: serializer.fromJson<int>(json['last_word_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'edition_id': serializer.toJson<String>(editionId),
      'ayah_id': serializer.toJson<int>(ayahId),
      'page': serializer.toJson<int>(page),
      'first_line': serializer.toJson<int>(firstLine),
      'last_line': serializer.toJson<int>(lastLine),
      'first_word_id': serializer.toJson<int>(firstWordId),
      'last_word_id': serializer.toJson<int>(lastWordId),
    };
  }

  MushafAyahPageData copyWith({
    String? editionId,
    int? ayahId,
    int? page,
    int? firstLine,
    int? lastLine,
    int? firstWordId,
    int? lastWordId,
  }) => MushafAyahPageData(
    editionId: editionId ?? this.editionId,
    ayahId: ayahId ?? this.ayahId,
    page: page ?? this.page,
    firstLine: firstLine ?? this.firstLine,
    lastLine: lastLine ?? this.lastLine,
    firstWordId: firstWordId ?? this.firstWordId,
    lastWordId: lastWordId ?? this.lastWordId,
  );
  MushafAyahPageData copyWithCompanion(MushafAyahPageCompanion data) {
    return MushafAyahPageData(
      editionId: data.editionId.present ? data.editionId.value : this.editionId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      page: data.page.present ? data.page.value : this.page,
      firstLine: data.firstLine.present ? data.firstLine.value : this.firstLine,
      lastLine: data.lastLine.present ? data.lastLine.value : this.lastLine,
      firstWordId: data.firstWordId.present
          ? data.firstWordId.value
          : this.firstWordId,
      lastWordId: data.lastWordId.present
          ? data.lastWordId.value
          : this.lastWordId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafAyahPageData(')
          ..write('editionId: $editionId, ')
          ..write('ayahId: $ayahId, ')
          ..write('page: $page, ')
          ..write('firstLine: $firstLine, ')
          ..write('lastLine: $lastLine, ')
          ..write('firstWordId: $firstWordId, ')
          ..write('lastWordId: $lastWordId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    editionId,
    ayahId,
    page,
    firstLine,
    lastLine,
    firstWordId,
    lastWordId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafAyahPageData &&
          other.editionId == this.editionId &&
          other.ayahId == this.ayahId &&
          other.page == this.page &&
          other.firstLine == this.firstLine &&
          other.lastLine == this.lastLine &&
          other.firstWordId == this.firstWordId &&
          other.lastWordId == this.lastWordId);
}

class MushafAyahPageCompanion extends UpdateCompanion<MushafAyahPageData> {
  final Value<String> editionId;
  final Value<int> ayahId;
  final Value<int> page;
  final Value<int> firstLine;
  final Value<int> lastLine;
  final Value<int> firstWordId;
  final Value<int> lastWordId;
  final Value<int> rowid;
  const MushafAyahPageCompanion({
    this.editionId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.page = const Value.absent(),
    this.firstLine = const Value.absent(),
    this.lastLine = const Value.absent(),
    this.firstWordId = const Value.absent(),
    this.lastWordId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafAyahPageCompanion.insert({
    required String editionId,
    required int ayahId,
    required int page,
    required int firstLine,
    required int lastLine,
    required int firstWordId,
    required int lastWordId,
    this.rowid = const Value.absent(),
  }) : editionId = Value(editionId),
       ayahId = Value(ayahId),
       page = Value(page),
       firstLine = Value(firstLine),
       lastLine = Value(lastLine),
       firstWordId = Value(firstWordId),
       lastWordId = Value(lastWordId);
  static Insertable<MushafAyahPageData> custom({
    Expression<String>? editionId,
    Expression<int>? ayahId,
    Expression<int>? page,
    Expression<int>? firstLine,
    Expression<int>? lastLine,
    Expression<int>? firstWordId,
    Expression<int>? lastWordId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (editionId != null) 'edition_id': editionId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (page != null) 'page': page,
      if (firstLine != null) 'first_line': firstLine,
      if (lastLine != null) 'last_line': lastLine,
      if (firstWordId != null) 'first_word_id': firstWordId,
      if (lastWordId != null) 'last_word_id': lastWordId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafAyahPageCompanion copyWith({
    Value<String>? editionId,
    Value<int>? ayahId,
    Value<int>? page,
    Value<int>? firstLine,
    Value<int>? lastLine,
    Value<int>? firstWordId,
    Value<int>? lastWordId,
    Value<int>? rowid,
  }) {
    return MushafAyahPageCompanion(
      editionId: editionId ?? this.editionId,
      ayahId: ayahId ?? this.ayahId,
      page: page ?? this.page,
      firstLine: firstLine ?? this.firstLine,
      lastLine: lastLine ?? this.lastLine,
      firstWordId: firstWordId ?? this.firstWordId,
      lastWordId: lastWordId ?? this.lastWordId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (editionId.present) {
      map['edition_id'] = Variable<String>(editionId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<int>(ayahId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (firstLine.present) {
      map['first_line'] = Variable<int>(firstLine.value);
    }
    if (lastLine.present) {
      map['last_line'] = Variable<int>(lastLine.value);
    }
    if (firstWordId.present) {
      map['first_word_id'] = Variable<int>(firstWordId.value);
    }
    if (lastWordId.present) {
      map['last_word_id'] = Variable<int>(lastWordId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafAyahPageCompanion(')
          ..write('editionId: $editionId, ')
          ..write('ayahId: $ayahId, ')
          ..write('page: $page, ')
          ..write('firstLine: $firstLine, ')
          ..write('lastLine: $lastLine, ')
          ..write('firstWordId: $firstWordId, ')
          ..write('lastWordId: $lastWordId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$QuranDatabase extends GeneratedDatabase {
  _$QuranDatabase(QueryExecutor e) : super(e);
  $QuranDatabaseManager get managers => $QuranDatabaseManager(this);
  late final Meta meta = Meta(this);
  late final Surah surah = Surah(this);
  late final Ayah ayah = Ayah(this);
  late final Index ixAyahPage = Index(
    'ix_ayah_page',
    'CREATE INDEX ix_ayah_page ON ayah (page)',
  );
  late final Index ixAyahJuz = Index(
    'ix_ayah_juz',
    'CREATE INDEX ix_ayah_juz ON ayah (juz)',
  );
  late final Tafsir tafsir = Tafsir(this);
  late final Page page = Page(this);
  late final Juz juz = Juz(this);
  late final Hizb hizb = Hizb(this);
  late final AyahFts ayahFts = AyahFts(this);
  late final Doa doa = Doa(this);
  late final AsmaulHusna asmaulHusna = AsmaulHusna(this);
  late final PrayerLocation prayerLocation = PrayerLocation(this);
  late final MushafEdition mushafEdition = MushafEdition(this);
  late final MushafAsset mushafAsset = MushafAsset(this);
  late final MushafPage mushafPage = MushafPage(this);
  late final MushafLine mushafLine = MushafLine(this);
  late final MushafWord mushafWord = MushafWord(this);
  late final Index ixMushafWordPageLine = Index(
    'ix_mushaf_word_page_line',
    'CREATE INDEX ix_mushaf_word_page_line ON mushaf_word (edition_id, page, line, position)',
  );
  late final MushafAyahPage mushafAyahPage = MushafAyahPage(this);
  late final Index ixMushafAyahPagePage = Index(
    'ix_mushaf_ayah_page_page',
    'CREATE INDEX ix_mushaf_ayah_page_page ON mushaf_ayah_page (edition_id, page, ayah_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    meta,
    surah,
    ayah,
    ixAyahPage,
    ixAyahJuz,
    tafsir,
    page,
    juz,
    hizb,
    ayahFts,
    doa,
    asmaulHusna,
    prayerLocation,
    mushafEdition,
    mushafAsset,
    mushafPage,
    mushafLine,
    mushafWord,
    ixMushafWordPageLine,
    mushafAyahPage,
    ixMushafAyahPagePage,
  ];
}

typedef $MetaCreateCompanionBuilder =
    MetaCompanion Function({
      Value<String?> key,
      required String value,
      Value<int> rowid,
    });
typedef $MetaUpdateCompanionBuilder =
    MetaCompanion Function({
      Value<String?> key,
      Value<String> value,
      Value<int> rowid,
    });

class $MetaFilterComposer extends Composer<_$QuranDatabase, Meta> {
  $MetaFilterComposer({
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

class $MetaOrderingComposer extends Composer<_$QuranDatabase, Meta> {
  $MetaOrderingComposer({
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

class $MetaAnnotationComposer extends Composer<_$QuranDatabase, Meta> {
  $MetaAnnotationComposer({
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

class $MetaTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Meta,
          MetaData,
          $MetaFilterComposer,
          $MetaOrderingComposer,
          $MetaAnnotationComposer,
          $MetaCreateCompanionBuilder,
          $MetaUpdateCompanionBuilder,
          (MetaData, BaseReferences<_$QuranDatabase, Meta, MetaData>),
          MetaData,
          PrefetchHooks Function()
        > {
  $MetaTableManager(_$QuranDatabase db, Meta table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MetaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MetaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MetaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                Value<String?> key = const Value.absent(),
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Meta, MetaData>(table),
                  BaseReferences<_$QuranDatabase, Meta, MetaData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MetaProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Meta,
      MetaData,
      $MetaFilterComposer,
      $MetaOrderingComposer,
      $MetaAnnotationComposer,
      $MetaCreateCompanionBuilder,
      $MetaUpdateCompanionBuilder,
      (MetaData, BaseReferences<_$QuranDatabase, Meta, MetaData>),
      MetaData,
      PrefetchHooks Function()
    >;
typedef $SurahCreateCompanionBuilder =
    SurahCompanion Function({
      Value<int> number,
      required String nameArabic,
      required String nameLatin,
      Value<String?> translationId,
      Value<String?> translationEn,
      required int ayahCount,
      required String revelationPlace,
      Value<int?> revelationOrder,
      required int firstPage,
      Value<int> bismillahPre,
    });
typedef $SurahUpdateCompanionBuilder =
    SurahCompanion Function({
      Value<int> number,
      Value<String> nameArabic,
      Value<String> nameLatin,
      Value<String?> translationId,
      Value<String?> translationEn,
      Value<int> ayahCount,
      Value<String> revelationPlace,
      Value<int?> revelationOrder,
      Value<int> firstPage,
      Value<int> bismillahPre,
    });

final class $SurahReferences
    extends BaseReferences<_$QuranDatabase, Surah, SurahData> {
  $SurahReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Ayah, List<AyahData>> _ayahRefsTable(
    _$QuranDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ayah,
    aliasName: 'surah__number__ayah__surah',
  );

  $AyahProcessedTableManager get ayahRefs {
    final manager = $AyahTableManager(
      $_db,
      $_db.ayah,
    ).filter((f) => f.surah.number.sqlEquals($_itemColumn<int>('number')!));

    final cache = $_typedResult.readTableOrNull(_ayahRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SurahFilterComposer extends Composer<_$QuranDatabase, Surah> {
  $SurahFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameLatin => $composableBuilder(
    column: $table.nameLatin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstPage => $composableBuilder(
    column: $table.firstPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ayahRefs(
    Expression<bool> Function($AyahFilterComposer f) f,
  ) {
    final $AyahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.number,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.surah,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahFilterComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SurahOrderingComposer extends Composer<_$QuranDatabase, Surah> {
  $SurahOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameLatin => $composableBuilder(
    column: $table.nameLatin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahCount => $composableBuilder(
    column: $table.ayahCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstPage => $composableBuilder(
    column: $table.firstPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SurahAnnotationComposer extends Composer<_$QuranDatabase, Surah> {
  $SurahAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameLatin =>
      $composableBuilder(column: $table.nameLatin, builder: (column) => column);

  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstPage =>
      $composableBuilder(column: $table.firstPage, builder: (column) => column);

  GeneratedColumn<int> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => column,
  );

  Expression<T> ayahRefs<T extends Object>(
    Expression<T> Function($AyahAnnotationComposer a) f,
  ) {
    final $AyahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.number,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.surah,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahAnnotationComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SurahTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Surah,
          SurahData,
          $SurahFilterComposer,
          $SurahOrderingComposer,
          $SurahAnnotationComposer,
          $SurahCreateCompanionBuilder,
          $SurahUpdateCompanionBuilder,
          (SurahData, $SurahReferences),
          SurahData,
          PrefetchHooks Function({bool ayahRefs})
        > {
  $SurahTableManager(_$QuranDatabase db, Surah table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SurahFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SurahOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SurahAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameLatin = const Value.absent(),
                Value<String?> translationId = const Value.absent(),
                Value<String?> translationEn = const Value.absent(),
                Value<int> ayahCount = const Value.absent(),
                Value<String> revelationPlace = const Value.absent(),
                Value<int?> revelationOrder = const Value.absent(),
                Value<int> firstPage = const Value.absent(),
                Value<int> bismillahPre = const Value.absent(),
              }) => SurahCompanion(
                number: number,
                nameArabic: nameArabic,
                nameLatin: nameLatin,
                translationId: translationId,
                translationEn: translationEn,
                ayahCount: ayahCount,
                revelationPlace: revelationPlace,
                revelationOrder: revelationOrder,
                firstPage: firstPage,
                bismillahPre: bismillahPre,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required String nameArabic,
                required String nameLatin,
                Value<String?> translationId = const Value.absent(),
                Value<String?> translationEn = const Value.absent(),
                required int ayahCount,
                required String revelationPlace,
                Value<int?> revelationOrder = const Value.absent(),
                required int firstPage,
                Value<int> bismillahPre = const Value.absent(),
              }) => SurahCompanion.insert(
                number: number,
                nameArabic: nameArabic,
                nameLatin: nameLatin,
                translationId: translationId,
                translationEn: translationEn,
                ayahCount: ayahCount,
                revelationPlace: revelationPlace,
                revelationOrder: revelationOrder,
                firstPage: firstPage,
                bismillahPre: bismillahPre,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Surah, SurahData>(table),
                  $SurahReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ayahRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (ayahRefs) db.ayah],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ayahRefs)
                    await $_getPrefetchedData<SurahData, Surah, AyahData>(
                      currentTable: table,
                      referencedTable: $SurahReferences._ayahRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $SurahReferences(db, table, p0).ayahRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.surah == item.number),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $SurahProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Surah,
      SurahData,
      $SurahFilterComposer,
      $SurahOrderingComposer,
      $SurahAnnotationComposer,
      $SurahCreateCompanionBuilder,
      $SurahUpdateCompanionBuilder,
      (SurahData, $SurahReferences),
      SurahData,
      PrefetchHooks Function({bool ayahRefs})
    >;
typedef $AyahCreateCompanionBuilder =
    AyahCompanion Function({
      Value<int> id,
      required int surah,
      required int ayah,
      required int page,
      required int juz,
      Value<int?> hizbQuarter,
      Value<int?> ruku,
      Value<int?> manzil,
      Value<int> sajda,
      required String textUthmani,
      required String textSimple,
      required String textNorm,
      Value<String?> textLatin,
      required String translationId,
      Value<String?> translationEn,
      required int hizb,
    });
typedef $AyahUpdateCompanionBuilder =
    AyahCompanion Function({
      Value<int> id,
      Value<int> surah,
      Value<int> ayah,
      Value<int> page,
      Value<int> juz,
      Value<int?> hizbQuarter,
      Value<int?> ruku,
      Value<int?> manzil,
      Value<int> sajda,
      Value<String> textUthmani,
      Value<String> textSimple,
      Value<String> textNorm,
      Value<String?> textLatin,
      Value<String> translationId,
      Value<String?> translationEn,
      Value<int> hizb,
    });

final class $AyahReferences
    extends BaseReferences<_$QuranDatabase, Ayah, AyahData> {
  $AyahReferences(super.$_db, super.$_table, super.$_typedResult);

  static Surah _surahTable(_$QuranDatabase db) =>
      db.surah.createAlias('ayah__surah__surah__number');

  $SurahProcessedTableManager get surah {
    final $_column = $_itemColumn<int>('surah')!;

    final manager = $SurahTableManager(
      $_db,
      $_db.surah,
    ).filter((f) => f.number.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Tafsir, List<TafsirData>> _tafsirRefsTable(
    _$QuranDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tafsir,
    aliasName: 'ayah__id__tafsir__ayah_id',
  );

  $TafsirProcessedTableManager get tafsirRefs {
    final manager = $TafsirTableManager(
      $_db,
      $_db.tafsir,
    ).filter((f) => f.ayahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tafsirRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MushafWord, List<MushafWordData>>
  _mushafWordRefsTable(_$QuranDatabase db) => MultiTypedResultKey.fromTable(
    db.mushafWord,
    aliasName: 'ayah__id__mushaf_word__ayah_id',
  );

  $MushafWordProcessedTableManager get mushafWordRefs {
    final manager = $MushafWordTableManager(
      $_db,
      $_db.mushafWord,
    ).filter((f) => f.ayahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mushafWordRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MushafAyahPage, List<MushafAyahPageData>>
  _mushafAyahPageRefsTable(_$QuranDatabase db) => MultiTypedResultKey.fromTable(
    db.mushafAyahPage,
    aliasName: 'ayah__id__mushaf_ayah_page__ayah_id',
  );

  $MushafAyahPageProcessedTableManager get mushafAyahPageRefs {
    final manager = $MushafAyahPageTableManager(
      $_db,
      $_db.mushafAyahPage,
    ).filter((f) => f.ayahId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mushafAyahPageRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $AyahFilterComposer extends Composer<_$QuranDatabase, Ayah> {
  $AyahFilterComposer({
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

  ColumnFilters<int> get ayah => $composableBuilder(
    column: $table.ayah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizbQuarter => $composableBuilder(
    column: $table.hizbQuarter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ruku => $composableBuilder(
    column: $table.ruku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manzil => $composableBuilder(
    column: $table.manzil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textSimple => $composableBuilder(
    column: $table.textSimple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textNorm => $composableBuilder(
    column: $table.textNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textLatin => $composableBuilder(
    column: $table.textLatin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizb => $composableBuilder(
    column: $table.hizb,
    builder: (column) => ColumnFilters(column),
  );

  $SurahFilterComposer get surah {
    final $SurahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surah,
      referencedTable: $db.surah,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SurahFilterComposer(
            $db: $db,
            $table: $db.surah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tafsirRefs(
    Expression<bool> Function($TafsirFilterComposer f) f,
  ) {
    final $TafsirFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tafsir,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TafsirFilterComposer(
            $db: $db,
            $table: $db.tafsir,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mushafWordRefs(
    Expression<bool> Function($MushafWordFilterComposer f) f,
  ) {
    final $MushafWordFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafWord,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafWordFilterComposer(
            $db: $db,
            $table: $db.mushafWord,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mushafAyahPageRefs(
    Expression<bool> Function($MushafAyahPageFilterComposer f) f,
  ) {
    final $MushafAyahPageFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafAyahPage,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafAyahPageFilterComposer(
            $db: $db,
            $table: $db.mushafAyahPage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AyahOrderingComposer extends Composer<_$QuranDatabase, Ayah> {
  $AyahOrderingComposer({
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

  ColumnOrderings<int> get ayah => $composableBuilder(
    column: $table.ayah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizbQuarter => $composableBuilder(
    column: $table.hizbQuarter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ruku => $composableBuilder(
    column: $table.ruku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manzil => $composableBuilder(
    column: $table.manzil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sajda => $composableBuilder(
    column: $table.sajda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textSimple => $composableBuilder(
    column: $table.textSimple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textNorm => $composableBuilder(
    column: $table.textNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textLatin => $composableBuilder(
    column: $table.textLatin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizb => $composableBuilder(
    column: $table.hizb,
    builder: (column) => ColumnOrderings(column),
  );

  $SurahOrderingComposer get surah {
    final $SurahOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surah,
      referencedTable: $db.surah,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SurahOrderingComposer(
            $db: $db,
            $table: $db.surah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AyahAnnotationComposer extends Composer<_$QuranDatabase, Ayah> {
  $AyahAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ayah =>
      $composableBuilder(column: $table.ayah, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get hizbQuarter => $composableBuilder(
    column: $table.hizbQuarter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ruku =>
      $composableBuilder(column: $table.ruku, builder: (column) => column);

  GeneratedColumn<int> get manzil =>
      $composableBuilder(column: $table.manzil, builder: (column) => column);

  GeneratedColumn<int> get sajda =>
      $composableBuilder(column: $table.sajda, builder: (column) => column);

  GeneratedColumn<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textSimple => $composableBuilder(
    column: $table.textSimple,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textNorm =>
      $composableBuilder(column: $table.textNorm, builder: (column) => column);

  GeneratedColumn<String> get textLatin =>
      $composableBuilder(column: $table.textLatin, builder: (column) => column);

  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hizb =>
      $composableBuilder(column: $table.hizb, builder: (column) => column);

  $SurahAnnotationComposer get surah {
    final $SurahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.surah,
      referencedTable: $db.surah,
      getReferencedColumn: (t) => t.number,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SurahAnnotationComposer(
            $db: $db,
            $table: $db.surah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tafsirRefs<T extends Object>(
    Expression<T> Function($TafsirAnnotationComposer a) f,
  ) {
    final $TafsirAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tafsir,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TafsirAnnotationComposer(
            $db: $db,
            $table: $db.tafsir,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mushafWordRefs<T extends Object>(
    Expression<T> Function($MushafWordAnnotationComposer a) f,
  ) {
    final $MushafWordAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafWord,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafWordAnnotationComposer(
            $db: $db,
            $table: $db.mushafWord,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mushafAyahPageRefs<T extends Object>(
    Expression<T> Function($MushafAyahPageAnnotationComposer a) f,
  ) {
    final $MushafAyahPageAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafAyahPage,
      getReferencedColumn: (t) => t.ayahId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafAyahPageAnnotationComposer(
            $db: $db,
            $table: $db.mushafAyahPage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AyahTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Ayah,
          AyahData,
          $AyahFilterComposer,
          $AyahOrderingComposer,
          $AyahAnnotationComposer,
          $AyahCreateCompanionBuilder,
          $AyahUpdateCompanionBuilder,
          (AyahData, $AyahReferences),
          AyahData,
          PrefetchHooks Function({
            bool surah,
            bool tafsirRefs,
            bool mushafWordRefs,
            bool mushafAyahPageRefs,
          })
        > {
  $AyahTableManager(_$QuranDatabase db, Ayah table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AyahFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AyahOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AyahAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> surah = const Value.absent(),
                Value<int> ayah = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> juz = const Value.absent(),
                Value<int?> hizbQuarter = const Value.absent(),
                Value<int?> ruku = const Value.absent(),
                Value<int?> manzil = const Value.absent(),
                Value<int> sajda = const Value.absent(),
                Value<String> textUthmani = const Value.absent(),
                Value<String> textSimple = const Value.absent(),
                Value<String> textNorm = const Value.absent(),
                Value<String?> textLatin = const Value.absent(),
                Value<String> translationId = const Value.absent(),
                Value<String?> translationEn = const Value.absent(),
                Value<int> hizb = const Value.absent(),
              }) => AyahCompanion(
                id: id,
                surah: surah,
                ayah: ayah,
                page: page,
                juz: juz,
                hizbQuarter: hizbQuarter,
                ruku: ruku,
                manzil: manzil,
                sajda: sajda,
                textUthmani: textUthmani,
                textSimple: textSimple,
                textNorm: textNorm,
                textLatin: textLatin,
                translationId: translationId,
                translationEn: translationEn,
                hizb: hizb,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int surah,
                required int ayah,
                required int page,
                required int juz,
                Value<int?> hizbQuarter = const Value.absent(),
                Value<int?> ruku = const Value.absent(),
                Value<int?> manzil = const Value.absent(),
                Value<int> sajda = const Value.absent(),
                required String textUthmani,
                required String textSimple,
                required String textNorm,
                Value<String?> textLatin = const Value.absent(),
                required String translationId,
                Value<String?> translationEn = const Value.absent(),
                required int hizb,
              }) => AyahCompanion.insert(
                id: id,
                surah: surah,
                ayah: ayah,
                page: page,
                juz: juz,
                hizbQuarter: hizbQuarter,
                ruku: ruku,
                manzil: manzil,
                sajda: sajda,
                textUthmani: textUthmani,
                textSimple: textSimple,
                textNorm: textNorm,
                textLatin: textLatin,
                translationId: translationId,
                translationEn: translationEn,
                hizb: hizb,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Ayah, AyahData>(table),
                  $AyahReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                surah = false,
                tafsirRefs = false,
                mushafWordRefs = false,
                mushafAyahPageRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tafsirRefs) db.tafsir,
                    if (mushafWordRefs) db.mushafWord,
                    if (mushafAyahPageRefs) db.mushafAyahPage,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (surah) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.surah,
                                    referencedTable: $AyahReferences
                                        ._surahTable(db),
                                    referencedColumn: $AyahReferences
                                        ._surahTable(db)
                                        .number,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tafsirRefs)
                        await $_getPrefetchedData<AyahData, Ayah, TafsirData>(
                          currentTable: table,
                          referencedTable: $AyahReferences._tafsirRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $AyahReferences(db, table, p0).tafsirRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ayahId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mushafWordRefs)
                        await $_getPrefetchedData<
                          AyahData,
                          Ayah,
                          MushafWordData
                        >(
                          currentTable: table,
                          referencedTable: $AyahReferences._mushafWordRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $AyahReferences(db, table, p0).mushafWordRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ayahId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mushafAyahPageRefs)
                        await $_getPrefetchedData<
                          AyahData,
                          Ayah,
                          MushafAyahPageData
                        >(
                          currentTable: table,
                          referencedTable: $AyahReferences
                              ._mushafAyahPageRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $AyahReferences(db, table, p0).mushafAyahPageRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ayahId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $AyahProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Ayah,
      AyahData,
      $AyahFilterComposer,
      $AyahOrderingComposer,
      $AyahAnnotationComposer,
      $AyahCreateCompanionBuilder,
      $AyahUpdateCompanionBuilder,
      (AyahData, $AyahReferences),
      AyahData,
      PrefetchHooks Function({
        bool surah,
        bool tafsirRefs,
        bool mushafWordRefs,
        bool mushafAyahPageRefs,
      })
    >;
typedef $TafsirCreateCompanionBuilder =
    TafsirCompanion Function({
      required int ayahId,
      required String source,
      required String tafsirText,
      Value<int> rowid,
    });
typedef $TafsirUpdateCompanionBuilder =
    TafsirCompanion Function({
      Value<int> ayahId,
      Value<String> source,
      Value<String> tafsirText,
      Value<int> rowid,
    });

final class $TafsirReferences
    extends BaseReferences<_$QuranDatabase, Tafsir, TafsirData> {
  $TafsirReferences(super.$_db, super.$_table, super.$_typedResult);

  static Ayah _ayahIdTable(_$QuranDatabase db) =>
      db.ayah.createAlias('tafsir__ayah_id__ayah__id');

  $AyahProcessedTableManager get ayahId {
    final $_column = $_itemColumn<int>('ayah_id')!;

    final manager = $AyahTableManager(
      $_db,
      $_db.ayah,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TafsirFilterComposer extends Composer<_$QuranDatabase, Tafsir> {
  $TafsirFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tafsirText => $composableBuilder(
    column: $table.tafsirText,
    builder: (column) => ColumnFilters(column),
  );

  $AyahFilterComposer get ayahId {
    final $AyahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahFilterComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TafsirOrderingComposer extends Composer<_$QuranDatabase, Tafsir> {
  $TafsirOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tafsirText => $composableBuilder(
    column: $table.tafsirText,
    builder: (column) => ColumnOrderings(column),
  );

  $AyahOrderingComposer get ayahId {
    final $AyahOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahOrderingComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TafsirAnnotationComposer extends Composer<_$QuranDatabase, Tafsir> {
  $TafsirAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get tafsirText => $composableBuilder(
    column: $table.tafsirText,
    builder: (column) => column,
  );

  $AyahAnnotationComposer get ayahId {
    final $AyahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahAnnotationComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TafsirTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Tafsir,
          TafsirData,
          $TafsirFilterComposer,
          $TafsirOrderingComposer,
          $TafsirAnnotationComposer,
          $TafsirCreateCompanionBuilder,
          $TafsirUpdateCompanionBuilder,
          (TafsirData, $TafsirReferences),
          TafsirData,
          PrefetchHooks Function({bool ayahId})
        > {
  $TafsirTableManager(_$QuranDatabase db, Tafsir table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TafsirFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TafsirOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TafsirAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> ayahId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> tafsirText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TafsirCompanion(
                ayahId: ayahId,
                source: source,
                tafsirText: tafsirText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int ayahId,
                required String source,
                required String tafsirText,
                Value<int> rowid = const Value.absent(),
              }) => TafsirCompanion.insert(
                ayahId: ayahId,
                source: source,
                tafsirText: tafsirText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Tafsir, TafsirData>(table),
                  $TafsirReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ayahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ayahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ayahId,
                                referencedTable: $TafsirReferences._ayahIdTable(
                                  db,
                                ),
                                referencedColumn: $TafsirReferences
                                    ._ayahIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $TafsirProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Tafsir,
      TafsirData,
      $TafsirFilterComposer,
      $TafsirOrderingComposer,
      $TafsirAnnotationComposer,
      $TafsirCreateCompanionBuilder,
      $TafsirUpdateCompanionBuilder,
      (TafsirData, $TafsirReferences),
      TafsirData,
      PrefetchHooks Function({bool ayahId})
    >;
typedef $PageCreateCompanionBuilder =
    PageCompanion Function({
      Value<int> number,
      required int firstAyah,
      required int lastAyah,
      required int juz,
    });
typedef $PageUpdateCompanionBuilder =
    PageCompanion Function({
      Value<int> number,
      Value<int> firstAyah,
      Value<int> lastAyah,
      Value<int> juz,
    });

final class $PageReferences
    extends BaseReferences<_$QuranDatabase, Page, PageData> {
  $PageReferences(super.$_db, super.$_table, super.$_typedResult);

  static Ayah _firstAyahTable(_$QuranDatabase db) =>
      db.ayah.createAlias('page__first_ayah__ayah__id');

  $AyahProcessedTableManager get firstAyah {
    final $_column = $_itemColumn<int>('first_ayah')!;

    final manager = $AyahTableManager(
      $_db,
      $_db.ayah,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_firstAyahTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Ayah _lastAyahTable(_$QuranDatabase db) =>
      db.ayah.createAlias('page__last_ayah__ayah__id');

  $AyahProcessedTableManager get lastAyah {
    final $_column = $_itemColumn<int>('last_ayah')!;

    final manager = $AyahTableManager(
      $_db,
      $_db.ayah,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastAyahTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $PageFilterComposer extends Composer<_$QuranDatabase, Page> {
  $PageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnFilters(column),
  );

  $AyahFilterComposer get firstAyah {
    final $AyahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstAyah,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahFilterComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AyahFilterComposer get lastAyah {
    final $AyahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastAyah,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahFilterComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PageOrderingComposer extends Composer<_$QuranDatabase, Page> {
  $PageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juz => $composableBuilder(
    column: $table.juz,
    builder: (column) => ColumnOrderings(column),
  );

  $AyahOrderingComposer get firstAyah {
    final $AyahOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstAyah,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahOrderingComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AyahOrderingComposer get lastAyah {
    final $AyahOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastAyah,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahOrderingComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PageAnnotationComposer extends Composer<_$QuranDatabase, Page> {
  $PageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  $AyahAnnotationComposer get firstAyah {
    final $AyahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstAyah,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahAnnotationComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AyahAnnotationComposer get lastAyah {
    final $AyahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastAyah,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahAnnotationComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $PageTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Page,
          PageData,
          $PageFilterComposer,
          $PageOrderingComposer,
          $PageAnnotationComposer,
          $PageCreateCompanionBuilder,
          $PageUpdateCompanionBuilder,
          (PageData, $PageReferences),
          PageData,
          PrefetchHooks Function({bool firstAyah, bool lastAyah})
        > {
  $PageTableManager(_$QuranDatabase db, Page table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<int> firstAyah = const Value.absent(),
                Value<int> lastAyah = const Value.absent(),
                Value<int> juz = const Value.absent(),
              }) => PageCompanion(
                number: number,
                firstAyah: firstAyah,
                lastAyah: lastAyah,
                juz: juz,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required int firstAyah,
                required int lastAyah,
                required int juz,
              }) => PageCompanion.insert(
                number: number,
                firstAyah: firstAyah,
                lastAyah: lastAyah,
                juz: juz,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Page, PageData>(table),
                  $PageReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({firstAyah = false, lastAyah = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (firstAyah) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.firstAyah,
                                referencedTable: $PageReferences
                                    ._firstAyahTable(db),
                                referencedColumn: $PageReferences
                                    ._firstAyahTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (lastAyah) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.lastAyah,
                                referencedTable: $PageReferences._lastAyahTable(
                                  db,
                                ),
                                referencedColumn: $PageReferences
                                    ._lastAyahTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $PageProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Page,
      PageData,
      $PageFilterComposer,
      $PageOrderingComposer,
      $PageAnnotationComposer,
      $PageCreateCompanionBuilder,
      $PageUpdateCompanionBuilder,
      (PageData, $PageReferences),
      PageData,
      PrefetchHooks Function({bool firstAyah, bool lastAyah})
    >;
typedef $JuzCreateCompanionBuilder =
    JuzCompanion Function({
      Value<int> number,
      required int firstAyah,
      required int lastAyah,
    });
typedef $JuzUpdateCompanionBuilder =
    JuzCompanion Function({
      Value<int> number,
      Value<int> firstAyah,
      Value<int> lastAyah,
    });

class $JuzFilterComposer extends Composer<_$QuranDatabase, Juz> {
  $JuzFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstAyah => $composableBuilder(
    column: $table.firstAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAyah => $composableBuilder(
    column: $table.lastAyah,
    builder: (column) => ColumnFilters(column),
  );
}

class $JuzOrderingComposer extends Composer<_$QuranDatabase, Juz> {
  $JuzOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstAyah => $composableBuilder(
    column: $table.firstAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAyah => $composableBuilder(
    column: $table.lastAyah,
    builder: (column) => ColumnOrderings(column),
  );
}

class $JuzAnnotationComposer extends Composer<_$QuranDatabase, Juz> {
  $JuzAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get firstAyah =>
      $composableBuilder(column: $table.firstAyah, builder: (column) => column);

  GeneratedColumn<int> get lastAyah =>
      $composableBuilder(column: $table.lastAyah, builder: (column) => column);
}

class $JuzTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Juz,
          JuzData,
          $JuzFilterComposer,
          $JuzOrderingComposer,
          $JuzAnnotationComposer,
          $JuzCreateCompanionBuilder,
          $JuzUpdateCompanionBuilder,
          (JuzData, BaseReferences<_$QuranDatabase, Juz, JuzData>),
          JuzData,
          PrefetchHooks Function()
        > {
  $JuzTableManager(_$QuranDatabase db, Juz table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $JuzFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $JuzOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $JuzAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<int> firstAyah = const Value.absent(),
                Value<int> lastAyah = const Value.absent(),
              }) => JuzCompanion(
                number: number,
                firstAyah: firstAyah,
                lastAyah: lastAyah,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required int firstAyah,
                required int lastAyah,
              }) => JuzCompanion.insert(
                number: number,
                firstAyah: firstAyah,
                lastAyah: lastAyah,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Juz, JuzData>(table),
                  BaseReferences<_$QuranDatabase, Juz, JuzData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $JuzProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Juz,
      JuzData,
      $JuzFilterComposer,
      $JuzOrderingComposer,
      $JuzAnnotationComposer,
      $JuzCreateCompanionBuilder,
      $JuzUpdateCompanionBuilder,
      (JuzData, BaseReferences<_$QuranDatabase, Juz, JuzData>),
      JuzData,
      PrefetchHooks Function()
    >;
typedef $HizbCreateCompanionBuilder =
    HizbCompanion Function({
      Value<int> number,
      required int firstAyah,
      required int lastAyah,
    });
typedef $HizbUpdateCompanionBuilder =
    HizbCompanion Function({
      Value<int> number,
      Value<int> firstAyah,
      Value<int> lastAyah,
    });

class $HizbFilterComposer extends Composer<_$QuranDatabase, Hizb> {
  $HizbFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstAyah => $composableBuilder(
    column: $table.firstAyah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAyah => $composableBuilder(
    column: $table.lastAyah,
    builder: (column) => ColumnFilters(column),
  );
}

class $HizbOrderingComposer extends Composer<_$QuranDatabase, Hizb> {
  $HizbOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstAyah => $composableBuilder(
    column: $table.firstAyah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAyah => $composableBuilder(
    column: $table.lastAyah,
    builder: (column) => ColumnOrderings(column),
  );
}

class $HizbAnnotationComposer extends Composer<_$QuranDatabase, Hizb> {
  $HizbAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get firstAyah =>
      $composableBuilder(column: $table.firstAyah, builder: (column) => column);

  GeneratedColumn<int> get lastAyah =>
      $composableBuilder(column: $table.lastAyah, builder: (column) => column);
}

class $HizbTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Hizb,
          HizbData,
          $HizbFilterComposer,
          $HizbOrderingComposer,
          $HizbAnnotationComposer,
          $HizbCreateCompanionBuilder,
          $HizbUpdateCompanionBuilder,
          (HizbData, BaseReferences<_$QuranDatabase, Hizb, HizbData>),
          HizbData,
          PrefetchHooks Function()
        > {
  $HizbTableManager(_$QuranDatabase db, Hizb table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $HizbFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $HizbOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $HizbAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<int> firstAyah = const Value.absent(),
                Value<int> lastAyah = const Value.absent(),
              }) => HizbCompanion(
                number: number,
                firstAyah: firstAyah,
                lastAyah: lastAyah,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                required int firstAyah,
                required int lastAyah,
              }) => HizbCompanion.insert(
                number: number,
                firstAyah: firstAyah,
                lastAyah: lastAyah,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Hizb, HizbData>(table),
                  BaseReferences<_$QuranDatabase, Hizb, HizbData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $HizbProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Hizb,
      HizbData,
      $HizbFilterComposer,
      $HizbOrderingComposer,
      $HizbAnnotationComposer,
      $HizbCreateCompanionBuilder,
      $HizbUpdateCompanionBuilder,
      (HizbData, BaseReferences<_$QuranDatabase, Hizb, HizbData>),
      HizbData,
      PrefetchHooks Function()
    >;
typedef $AyahFtsCreateCompanionBuilder =
    AyahFtsCompanion Function({
      required String textNorm,
      required String translationId,
      required String translationEn,
      Value<int> rowid,
    });
typedef $AyahFtsUpdateCompanionBuilder =
    AyahFtsCompanion Function({
      Value<String> textNorm,
      Value<String> translationId,
      Value<String> translationEn,
      Value<int> rowid,
    });

class $AyahFtsFilterComposer extends Composer<_$QuranDatabase, AyahFts> {
  $AyahFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get textNorm => $composableBuilder(
    column: $table.textNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $AyahFtsOrderingComposer extends Composer<_$QuranDatabase, AyahFts> {
  $AyahFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get textNorm => $composableBuilder(
    column: $table.textNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AyahFtsAnnotationComposer extends Composer<_$QuranDatabase, AyahFts> {
  $AyahFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get textNorm =>
      $composableBuilder(column: $table.textNorm, builder: (column) => column);

  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationEn => $composableBuilder(
    column: $table.translationEn,
    builder: (column) => column,
  );
}

class $AyahFtsTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          AyahFts,
          AyahFt,
          $AyahFtsFilterComposer,
          $AyahFtsOrderingComposer,
          $AyahFtsAnnotationComposer,
          $AyahFtsCreateCompanionBuilder,
          $AyahFtsUpdateCompanionBuilder,
          (AyahFt, BaseReferences<_$QuranDatabase, AyahFts, AyahFt>),
          AyahFt,
          PrefetchHooks Function()
        > {
  $AyahFtsTableManager(_$QuranDatabase db, AyahFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AyahFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AyahFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AyahFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> textNorm = const Value.absent(),
                Value<String> translationId = const Value.absent(),
                Value<String> translationEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AyahFtsCompanion(
                textNorm: textNorm,
                translationId: translationId,
                translationEn: translationEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String textNorm,
                required String translationId,
                required String translationEn,
                Value<int> rowid = const Value.absent(),
              }) => AyahFtsCompanion.insert(
                textNorm: textNorm,
                translationId: translationId,
                translationEn: translationEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AyahFts, AyahFt>(table),
                  BaseReferences<_$QuranDatabase, AyahFts, AyahFt>(
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

typedef $AyahFtsProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      AyahFts,
      AyahFt,
      $AyahFtsFilterComposer,
      $AyahFtsOrderingComposer,
      $AyahFtsAnnotationComposer,
      $AyahFtsCreateCompanionBuilder,
      $AyahFtsUpdateCompanionBuilder,
      (AyahFt, BaseReferences<_$QuranDatabase, AyahFts, AyahFt>),
      AyahFt,
      PrefetchHooks Function()
    >;
typedef $DoaCreateCompanionBuilder =
    DoaCompanion Function({
      Value<int> id,
      Value<String?> grup,
      Value<String?> nama,
      Value<String?> ar,
      Value<String?> tr,
      Value<String?> idn,
      Value<String?> tentang,
      Value<String?> tags,
    });
typedef $DoaUpdateCompanionBuilder =
    DoaCompanion Function({
      Value<int> id,
      Value<String?> grup,
      Value<String?> nama,
      Value<String?> ar,
      Value<String?> tr,
      Value<String?> idn,
      Value<String?> tentang,
      Value<String?> tags,
    });

class $DoaFilterComposer extends Composer<_$QuranDatabase, Doa> {
  $DoaFilterComposer({
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

  ColumnFilters<String> get grup => $composableBuilder(
    column: $table.grup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ar => $composableBuilder(
    column: $table.ar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tr => $composableBuilder(
    column: $table.tr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idn => $composableBuilder(
    column: $table.idn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tentang => $composableBuilder(
    column: $table.tentang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );
}

class $DoaOrderingComposer extends Composer<_$QuranDatabase, Doa> {
  $DoaOrderingComposer({
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

  ColumnOrderings<String> get grup => $composableBuilder(
    column: $table.grup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nama => $composableBuilder(
    column: $table.nama,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ar => $composableBuilder(
    column: $table.ar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tr => $composableBuilder(
    column: $table.tr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idn => $composableBuilder(
    column: $table.idn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tentang => $composableBuilder(
    column: $table.tentang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DoaAnnotationComposer extends Composer<_$QuranDatabase, Doa> {
  $DoaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get grup =>
      $composableBuilder(column: $table.grup, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get ar =>
      $composableBuilder(column: $table.ar, builder: (column) => column);

  GeneratedColumn<String> get tr =>
      $composableBuilder(column: $table.tr, builder: (column) => column);

  GeneratedColumn<String> get idn =>
      $composableBuilder(column: $table.idn, builder: (column) => column);

  GeneratedColumn<String> get tentang =>
      $composableBuilder(column: $table.tentang, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $DoaTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          Doa,
          DoaData,
          $DoaFilterComposer,
          $DoaOrderingComposer,
          $DoaAnnotationComposer,
          $DoaCreateCompanionBuilder,
          $DoaUpdateCompanionBuilder,
          (DoaData, BaseReferences<_$QuranDatabase, Doa, DoaData>),
          DoaData,
          PrefetchHooks Function()
        > {
  $DoaTableManager(_$QuranDatabase db, Doa table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DoaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DoaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DoaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> grup = const Value.absent(),
                Value<String?> nama = const Value.absent(),
                Value<String?> ar = const Value.absent(),
                Value<String?> tr = const Value.absent(),
                Value<String?> idn = const Value.absent(),
                Value<String?> tentang = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => DoaCompanion(
                id: id,
                grup: grup,
                nama: nama,
                ar: ar,
                tr: tr,
                idn: idn,
                tentang: tentang,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> grup = const Value.absent(),
                Value<String?> nama = const Value.absent(),
                Value<String?> ar = const Value.absent(),
                Value<String?> tr = const Value.absent(),
                Value<String?> idn = const Value.absent(),
                Value<String?> tentang = const Value.absent(),
                Value<String?> tags = const Value.absent(),
              }) => DoaCompanion.insert(
                id: id,
                grup: grup,
                nama: nama,
                ar: ar,
                tr: tr,
                idn: idn,
                tentang: tentang,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Doa, DoaData>(table),
                  BaseReferences<_$QuranDatabase, Doa, DoaData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DoaProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      Doa,
      DoaData,
      $DoaFilterComposer,
      $DoaOrderingComposer,
      $DoaAnnotationComposer,
      $DoaCreateCompanionBuilder,
      $DoaUpdateCompanionBuilder,
      (DoaData, BaseReferences<_$QuranDatabase, Doa, DoaData>),
      DoaData,
      PrefetchHooks Function()
    >;
typedef $AsmaulHusnaCreateCompanionBuilder =
    AsmaulHusnaCompanion Function({
      Value<int> number,
      Value<String?> arabic,
      Value<String?> latin,
      Value<String?> meaningId,
      Value<String?> meaningEn,
    });
typedef $AsmaulHusnaUpdateCompanionBuilder =
    AsmaulHusnaCompanion Function({
      Value<int> number,
      Value<String?> arabic,
      Value<String?> latin,
      Value<String?> meaningId,
      Value<String?> meaningEn,
    });

class $AsmaulHusnaFilterComposer
    extends Composer<_$QuranDatabase, AsmaulHusna> {
  $AsmaulHusnaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latin => $composableBuilder(
    column: $table.latin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningId => $composableBuilder(
    column: $table.meaningId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $AsmaulHusnaOrderingComposer
    extends Composer<_$QuranDatabase, AsmaulHusna> {
  $AsmaulHusnaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabic => $composableBuilder(
    column: $table.arabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latin => $composableBuilder(
    column: $table.latin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningId => $composableBuilder(
    column: $table.meaningId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningEn => $composableBuilder(
    column: $table.meaningEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AsmaulHusnaAnnotationComposer
    extends Composer<_$QuranDatabase, AsmaulHusna> {
  $AsmaulHusnaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get arabic =>
      $composableBuilder(column: $table.arabic, builder: (column) => column);

  GeneratedColumn<String> get latin =>
      $composableBuilder(column: $table.latin, builder: (column) => column);

  GeneratedColumn<String> get meaningId =>
      $composableBuilder(column: $table.meaningId, builder: (column) => column);

  GeneratedColumn<String> get meaningEn =>
      $composableBuilder(column: $table.meaningEn, builder: (column) => column);
}

class $AsmaulHusnaTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          AsmaulHusna,
          AsmaulHusnaData,
          $AsmaulHusnaFilterComposer,
          $AsmaulHusnaOrderingComposer,
          $AsmaulHusnaAnnotationComposer,
          $AsmaulHusnaCreateCompanionBuilder,
          $AsmaulHusnaUpdateCompanionBuilder,
          (
            AsmaulHusnaData,
            BaseReferences<_$QuranDatabase, AsmaulHusna, AsmaulHusnaData>,
          ),
          AsmaulHusnaData,
          PrefetchHooks Function()
        > {
  $AsmaulHusnaTableManager(_$QuranDatabase db, AsmaulHusna table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AsmaulHusnaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AsmaulHusnaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AsmaulHusnaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String?> arabic = const Value.absent(),
                Value<String?> latin = const Value.absent(),
                Value<String?> meaningId = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
              }) => AsmaulHusnaCompanion(
                number: number,
                arabic: arabic,
                latin: latin,
                meaningId: meaningId,
                meaningEn: meaningEn,
              ),
          createCompanionCallback:
              ({
                Value<int> number = const Value.absent(),
                Value<String?> arabic = const Value.absent(),
                Value<String?> latin = const Value.absent(),
                Value<String?> meaningId = const Value.absent(),
                Value<String?> meaningEn = const Value.absent(),
              }) => AsmaulHusnaCompanion.insert(
                number: number,
                arabic: arabic,
                latin: latin,
                meaningId: meaningId,
                meaningEn: meaningEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AsmaulHusna, AsmaulHusnaData>(table),
                  BaseReferences<_$QuranDatabase, AsmaulHusna, AsmaulHusnaData>(
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

typedef $AsmaulHusnaProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      AsmaulHusna,
      AsmaulHusnaData,
      $AsmaulHusnaFilterComposer,
      $AsmaulHusnaOrderingComposer,
      $AsmaulHusnaAnnotationComposer,
      $AsmaulHusnaCreateCompanionBuilder,
      $AsmaulHusnaUpdateCompanionBuilder,
      (
        AsmaulHusnaData,
        BaseReferences<_$QuranDatabase, AsmaulHusna, AsmaulHusnaData>,
      ),
      AsmaulHusnaData,
      PrefetchHooks Function()
    >;
typedef $PrayerLocationCreateCompanionBuilder =
    PrayerLocationCompanion Function({
      Value<String?> id,
      required String name,
      required String province,
      required double lat,
      required double lng,
      required String tz,
      Value<String?> myquranId,
      Value<int> rowid,
    });
typedef $PrayerLocationUpdateCompanionBuilder =
    PrayerLocationCompanion Function({
      Value<String?> id,
      Value<String> name,
      Value<String> province,
      Value<double> lat,
      Value<double> lng,
      Value<String> tz,
      Value<String?> myquranId,
      Value<int> rowid,
    });

class $PrayerLocationFilterComposer
    extends Composer<_$QuranDatabase, PrayerLocation> {
  $PrayerLocationFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tz => $composableBuilder(
    column: $table.tz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get myquranId => $composableBuilder(
    column: $table.myquranId,
    builder: (column) => ColumnFilters(column),
  );
}

class $PrayerLocationOrderingComposer
    extends Composer<_$QuranDatabase, PrayerLocation> {
  $PrayerLocationOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tz => $composableBuilder(
    column: $table.tz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get myquranId => $composableBuilder(
    column: $table.myquranId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $PrayerLocationAnnotationComposer
    extends Composer<_$QuranDatabase, PrayerLocation> {
  $PrayerLocationAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get tz =>
      $composableBuilder(column: $table.tz, builder: (column) => column);

  GeneratedColumn<String> get myquranId =>
      $composableBuilder(column: $table.myquranId, builder: (column) => column);
}

class $PrayerLocationTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          PrayerLocation,
          PrayerLocationData,
          $PrayerLocationFilterComposer,
          $PrayerLocationOrderingComposer,
          $PrayerLocationAnnotationComposer,
          $PrayerLocationCreateCompanionBuilder,
          $PrayerLocationUpdateCompanionBuilder,
          (
            PrayerLocationData,
            BaseReferences<_$QuranDatabase, PrayerLocation, PrayerLocationData>,
          ),
          PrayerLocationData,
          PrefetchHooks Function()
        > {
  $PrayerLocationTableManager(_$QuranDatabase db, PrayerLocation table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PrayerLocationFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PrayerLocationOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PrayerLocationAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> province = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String> tz = const Value.absent(),
                Value<String?> myquranId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerLocationCompanion(
                id: id,
                name: name,
                province: province,
                lat: lat,
                lng: lng,
                tz: tz,
                myquranId: myquranId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                required String name,
                required String province,
                required double lat,
                required double lng,
                required String tz,
                Value<String?> myquranId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerLocationCompanion.insert(
                id: id,
                name: name,
                province: province,
                lat: lat,
                lng: lng,
                tz: tz,
                myquranId: myquranId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<PrayerLocation, PrayerLocationData>(table),
                  BaseReferences<
                    _$QuranDatabase,
                    PrayerLocation,
                    PrayerLocationData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $PrayerLocationProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      PrayerLocation,
      PrayerLocationData,
      $PrayerLocationFilterComposer,
      $PrayerLocationOrderingComposer,
      $PrayerLocationAnnotationComposer,
      $PrayerLocationCreateCompanionBuilder,
      $PrayerLocationUpdateCompanionBuilder,
      (
        PrayerLocationData,
        BaseReferences<_$QuranDatabase, PrayerLocation, PrayerLocationData>,
      ),
      PrayerLocationData,
      PrefetchHooks Function()
    >;
typedef $MushafEditionCreateCompanionBuilder =
    MushafEditionCompanion Function({
      Value<String?> id,
      required int packVersion,
      required int pageCount,
      required String sourceSha256,
      required String manifestSha256,
      required double designWidth,
      required double wordFontSize,
      Value<int> rowid,
    });
typedef $MushafEditionUpdateCompanionBuilder =
    MushafEditionCompanion Function({
      Value<String?> id,
      Value<int> packVersion,
      Value<int> pageCount,
      Value<String> sourceSha256,
      Value<String> manifestSha256,
      Value<double> designWidth,
      Value<double> wordFontSize,
      Value<int> rowid,
    });

final class $MushafEditionReferences
    extends BaseReferences<_$QuranDatabase, MushafEdition, MushafEditionData> {
  $MushafEditionReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<MushafAsset, List<MushafAssetData>>
  _mushafAssetRefsTable(_$QuranDatabase db) => MultiTypedResultKey.fromTable(
    db.mushafAsset,
    aliasName: 'mushaf_edition__id__mushaf_asset__edition_id',
  );

  $MushafAssetProcessedTableManager get mushafAssetRefs {
    final manager = $MushafAssetTableManager(
      $_db,
      $_db.mushafAsset,
    ).filter((f) => f.editionId.id.sqlEquals($_itemColumn<String>('id')));

    final cache = $_typedResult.readTableOrNull(_mushafAssetRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<MushafPage, List<MushafPageData>>
  _mushafPageRefsTable(_$QuranDatabase db) => MultiTypedResultKey.fromTable(
    db.mushafPage,
    aliasName: 'mushaf_edition__id__mushaf_page__edition_id',
  );

  $MushafPageProcessedTableManager get mushafPageRefs {
    final manager = $MushafPageTableManager(
      $_db,
      $_db.mushafPage,
    ).filter((f) => f.editionId.id.sqlEquals($_itemColumn<String>('id')));

    final cache = $_typedResult.readTableOrNull(_mushafPageRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $MushafEditionFilterComposer
    extends Composer<_$QuranDatabase, MushafEdition> {
  $MushafEditionFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestSha256 => $composableBuilder(
    column: $table.manifestSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get designWidth => $composableBuilder(
    column: $table.designWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get wordFontSize => $composableBuilder(
    column: $table.wordFontSize,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mushafAssetRefs(
    Expression<bool> Function($MushafAssetFilterComposer f) f,
  ) {
    final $MushafAssetFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafAsset,
      getReferencedColumn: (t) => t.editionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafAssetFilterComposer(
            $db: $db,
            $table: $db.mushafAsset,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mushafPageRefs(
    Expression<bool> Function($MushafPageFilterComposer f) f,
  ) {
    final $MushafPageFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafPage,
      getReferencedColumn: (t) => t.editionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafPageFilterComposer(
            $db: $db,
            $table: $db.mushafPage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $MushafEditionOrderingComposer
    extends Composer<_$QuranDatabase, MushafEdition> {
  $MushafEditionOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestSha256 => $composableBuilder(
    column: $table.manifestSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get designWidth => $composableBuilder(
    column: $table.designWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get wordFontSize => $composableBuilder(
    column: $table.wordFontSize,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MushafEditionAnnotationComposer
    extends Composer<_$QuranDatabase, MushafEdition> {
  $MushafEditionAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get packVersion => $composableBuilder(
    column: $table.packVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get sourceSha256 => $composableBuilder(
    column: $table.sourceSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manifestSha256 => $composableBuilder(
    column: $table.manifestSha256,
    builder: (column) => column,
  );

  GeneratedColumn<double> get designWidth => $composableBuilder(
    column: $table.designWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get wordFontSize => $composableBuilder(
    column: $table.wordFontSize,
    builder: (column) => column,
  );

  Expression<T> mushafAssetRefs<T extends Object>(
    Expression<T> Function($MushafAssetAnnotationComposer a) f,
  ) {
    final $MushafAssetAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafAsset,
      getReferencedColumn: (t) => t.editionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafAssetAnnotationComposer(
            $db: $db,
            $table: $db.mushafAsset,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mushafPageRefs<T extends Object>(
    Expression<T> Function($MushafPageAnnotationComposer a) f,
  ) {
    final $MushafPageAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mushafPage,
      getReferencedColumn: (t) => t.editionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafPageAnnotationComposer(
            $db: $db,
            $table: $db.mushafPage,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $MushafEditionTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          MushafEdition,
          MushafEditionData,
          $MushafEditionFilterComposer,
          $MushafEditionOrderingComposer,
          $MushafEditionAnnotationComposer,
          $MushafEditionCreateCompanionBuilder,
          $MushafEditionUpdateCompanionBuilder,
          (MushafEditionData, $MushafEditionReferences),
          MushafEditionData,
          PrefetchHooks Function({bool mushafAssetRefs, bool mushafPageRefs})
        > {
  $MushafEditionTableManager(_$QuranDatabase db, MushafEdition table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MushafEditionFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MushafEditionOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MushafEditionAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<int> packVersion = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<String> sourceSha256 = const Value.absent(),
                Value<String> manifestSha256 = const Value.absent(),
                Value<double> designWidth = const Value.absent(),
                Value<double> wordFontSize = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafEditionCompanion(
                id: id,
                packVersion: packVersion,
                pageCount: pageCount,
                sourceSha256: sourceSha256,
                manifestSha256: manifestSha256,
                designWidth: designWidth,
                wordFontSize: wordFontSize,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                required int packVersion,
                required int pageCount,
                required String sourceSha256,
                required String manifestSha256,
                required double designWidth,
                required double wordFontSize,
                Value<int> rowid = const Value.absent(),
              }) => MushafEditionCompanion.insert(
                id: id,
                packVersion: packVersion,
                pageCount: pageCount,
                sourceSha256: sourceSha256,
                manifestSha256: manifestSha256,
                designWidth: designWidth,
                wordFontSize: wordFontSize,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MushafEdition, MushafEditionData>(table),
                  $MushafEditionReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mushafAssetRefs = false, mushafPageRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mushafAssetRefs) db.mushafAsset,
                    if (mushafPageRefs) db.mushafPage,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mushafAssetRefs)
                        await $_getPrefetchedData<
                          MushafEditionData,
                          MushafEdition,
                          MushafAssetData
                        >(
                          currentTable: table,
                          referencedTable: $MushafEditionReferences
                              ._mushafAssetRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $MushafEditionReferences(
                                db,
                                table,
                                p0,
                              ).mushafAssetRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.editionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mushafPageRefs)
                        await $_getPrefetchedData<
                          MushafEditionData,
                          MushafEdition,
                          MushafPageData
                        >(
                          currentTable: table,
                          referencedTable: $MushafEditionReferences
                              ._mushafPageRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $MushafEditionReferences(
                                db,
                                table,
                                p0,
                              ).mushafPageRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.editionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $MushafEditionProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      MushafEdition,
      MushafEditionData,
      $MushafEditionFilterComposer,
      $MushafEditionOrderingComposer,
      $MushafEditionAnnotationComposer,
      $MushafEditionCreateCompanionBuilder,
      $MushafEditionUpdateCompanionBuilder,
      (MushafEditionData, $MushafEditionReferences),
      MushafEditionData,
      PrefetchHooks Function({bool mushafAssetRefs, bool mushafPageRefs})
    >;
typedef $MushafAssetCreateCompanionBuilder =
    MushafAssetCompanion Function({
      required String editionId,
      required String id,
      required String kind,
      Value<int?> page,
      required String path,
      required String sha256,
      required int byteSize,
      required String sourceName,
      required String rightsStatus,
      Value<int> rowid,
    });
typedef $MushafAssetUpdateCompanionBuilder =
    MushafAssetCompanion Function({
      Value<String> editionId,
      Value<String> id,
      Value<String> kind,
      Value<int?> page,
      Value<String> path,
      Value<String> sha256,
      Value<int> byteSize,
      Value<String> sourceName,
      Value<String> rightsStatus,
      Value<int> rowid,
    });

final class $MushafAssetReferences
    extends BaseReferences<_$QuranDatabase, MushafAsset, MushafAssetData> {
  $MushafAssetReferences(super.$_db, super.$_table, super.$_typedResult);

  static MushafEdition _editionIdTable(_$QuranDatabase db) => db.mushafEdition
      .createAlias('mushaf_asset__edition_id__mushaf_edition__id');

  $MushafEditionProcessedTableManager get editionId {
    final $_column = $_itemColumn<String>('edition_id')!;

    final manager = $MushafEditionTableManager(
      $_db,
      $_db.mushafEdition,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_editionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $MushafAssetFilterComposer
    extends Composer<_$QuranDatabase, MushafAsset> {
  $MushafAssetFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rightsStatus => $composableBuilder(
    column: $table.rightsStatus,
    builder: (column) => ColumnFilters(column),
  );

  $MushafEditionFilterComposer get editionId {
    final $MushafEditionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.editionId,
      referencedTable: $db.mushafEdition,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafEditionFilterComposer(
            $db: $db,
            $table: $db.mushafEdition,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafAssetOrderingComposer
    extends Composer<_$QuranDatabase, MushafAsset> {
  $MushafAssetOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rightsStatus => $composableBuilder(
    column: $table.rightsStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $MushafEditionOrderingComposer get editionId {
    final $MushafEditionOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.editionId,
      referencedTable: $db.mushafEdition,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafEditionOrderingComposer(
            $db: $db,
            $table: $db.mushafEdition,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafAssetAnnotationComposer
    extends Composer<_$QuranDatabase, MushafAsset> {
  $MushafAssetAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rightsStatus => $composableBuilder(
    column: $table.rightsStatus,
    builder: (column) => column,
  );

  $MushafEditionAnnotationComposer get editionId {
    final $MushafEditionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.editionId,
      referencedTable: $db.mushafEdition,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafEditionAnnotationComposer(
            $db: $db,
            $table: $db.mushafEdition,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafAssetTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          MushafAsset,
          MushafAssetData,
          $MushafAssetFilterComposer,
          $MushafAssetOrderingComposer,
          $MushafAssetAnnotationComposer,
          $MushafAssetCreateCompanionBuilder,
          $MushafAssetUpdateCompanionBuilder,
          (MushafAssetData, $MushafAssetReferences),
          MushafAssetData,
          PrefetchHooks Function({bool editionId})
        > {
  $MushafAssetTableManager(_$QuranDatabase db, MushafAsset table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MushafAssetFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MushafAssetOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MushafAssetAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> editionId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<String> rightsStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafAssetCompanion(
                editionId: editionId,
                id: id,
                kind: kind,
                page: page,
                path: path,
                sha256: sha256,
                byteSize: byteSize,
                sourceName: sourceName,
                rightsStatus: rightsStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String editionId,
                required String id,
                required String kind,
                Value<int?> page = const Value.absent(),
                required String path,
                required String sha256,
                required int byteSize,
                required String sourceName,
                required String rightsStatus,
                Value<int> rowid = const Value.absent(),
              }) => MushafAssetCompanion.insert(
                editionId: editionId,
                id: id,
                kind: kind,
                page: page,
                path: path,
                sha256: sha256,
                byteSize: byteSize,
                sourceName: sourceName,
                rightsStatus: rightsStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MushafAsset, MushafAssetData>(table),
                  $MushafAssetReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({editionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (editionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.editionId,
                                referencedTable: $MushafAssetReferences
                                    ._editionIdTable(db),
                                referencedColumn: $MushafAssetReferences
                                    ._editionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $MushafAssetProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      MushafAsset,
      MushafAssetData,
      $MushafAssetFilterComposer,
      $MushafAssetOrderingComposer,
      $MushafAssetAnnotationComposer,
      $MushafAssetCreateCompanionBuilder,
      $MushafAssetUpdateCompanionBuilder,
      (MushafAssetData, $MushafAssetReferences),
      MushafAssetData,
      PrefetchHooks Function({bool editionId})
    >;
typedef $MushafPageCreateCompanionBuilder =
    MushafPageCompanion Function({
      required String editionId,
      required int page,
      required String fontAssetId,
      required int lineCount,
      Value<int> rowid,
    });
typedef $MushafPageUpdateCompanionBuilder =
    MushafPageCompanion Function({
      Value<String> editionId,
      Value<int> page,
      Value<String> fontAssetId,
      Value<int> lineCount,
      Value<int> rowid,
    });

final class $MushafPageReferences
    extends BaseReferences<_$QuranDatabase, MushafPage, MushafPageData> {
  $MushafPageReferences(super.$_db, super.$_table, super.$_typedResult);

  static MushafEdition _editionIdTable(_$QuranDatabase db) => db.mushafEdition
      .createAlias('mushaf_page__edition_id__mushaf_edition__id');

  $MushafEditionProcessedTableManager get editionId {
    final $_column = $_itemColumn<String>('edition_id')!;

    final manager = $MushafEditionTableManager(
      $_db,
      $_db.mushafEdition,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_editionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $MushafPageFilterComposer extends Composer<_$QuranDatabase, MushafPage> {
  $MushafPageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontAssetId => $composableBuilder(
    column: $table.fontAssetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineCount => $composableBuilder(
    column: $table.lineCount,
    builder: (column) => ColumnFilters(column),
  );

  $MushafEditionFilterComposer get editionId {
    final $MushafEditionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.editionId,
      referencedTable: $db.mushafEdition,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafEditionFilterComposer(
            $db: $db,
            $table: $db.mushafEdition,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafPageOrderingComposer
    extends Composer<_$QuranDatabase, MushafPage> {
  $MushafPageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontAssetId => $composableBuilder(
    column: $table.fontAssetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineCount => $composableBuilder(
    column: $table.lineCount,
    builder: (column) => ColumnOrderings(column),
  );

  $MushafEditionOrderingComposer get editionId {
    final $MushafEditionOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.editionId,
      referencedTable: $db.mushafEdition,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafEditionOrderingComposer(
            $db: $db,
            $table: $db.mushafEdition,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafPageAnnotationComposer
    extends Composer<_$QuranDatabase, MushafPage> {
  $MushafPageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<String> get fontAssetId => $composableBuilder(
    column: $table.fontAssetId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineCount =>
      $composableBuilder(column: $table.lineCount, builder: (column) => column);

  $MushafEditionAnnotationComposer get editionId {
    final $MushafEditionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.editionId,
      referencedTable: $db.mushafEdition,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $MushafEditionAnnotationComposer(
            $db: $db,
            $table: $db.mushafEdition,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafPageTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          MushafPage,
          MushafPageData,
          $MushafPageFilterComposer,
          $MushafPageOrderingComposer,
          $MushafPageAnnotationComposer,
          $MushafPageCreateCompanionBuilder,
          $MushafPageUpdateCompanionBuilder,
          (MushafPageData, $MushafPageReferences),
          MushafPageData,
          PrefetchHooks Function({bool editionId})
        > {
  $MushafPageTableManager(_$QuranDatabase db, MushafPage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MushafPageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MushafPageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MushafPageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> editionId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<String> fontAssetId = const Value.absent(),
                Value<int> lineCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafPageCompanion(
                editionId: editionId,
                page: page,
                fontAssetId: fontAssetId,
                lineCount: lineCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String editionId,
                required int page,
                required String fontAssetId,
                required int lineCount,
                Value<int> rowid = const Value.absent(),
              }) => MushafPageCompanion.insert(
                editionId: editionId,
                page: page,
                fontAssetId: fontAssetId,
                lineCount: lineCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MushafPage, MushafPageData>(table),
                  $MushafPageReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({editionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (editionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.editionId,
                                referencedTable: $MushafPageReferences
                                    ._editionIdTable(db),
                                referencedColumn: $MushafPageReferences
                                    ._editionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $MushafPageProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      MushafPage,
      MushafPageData,
      $MushafPageFilterComposer,
      $MushafPageOrderingComposer,
      $MushafPageAnnotationComposer,
      $MushafPageCreateCompanionBuilder,
      $MushafPageUpdateCompanionBuilder,
      (MushafPageData, $MushafPageReferences),
      MushafPageData,
      PrefetchHooks Function({bool editionId})
    >;
typedef $MushafLineCreateCompanionBuilder =
    MushafLineCompanion Function({
      required String editionId,
      required int page,
      required int line,
      required String kind,
      required int centered,
      Value<int?> surah,
      Value<int?> firstWordId,
      Value<int?> lastWordId,
      Value<int> rowid,
    });
typedef $MushafLineUpdateCompanionBuilder =
    MushafLineCompanion Function({
      Value<String> editionId,
      Value<int> page,
      Value<int> line,
      Value<String> kind,
      Value<int> centered,
      Value<int?> surah,
      Value<int?> firstWordId,
      Value<int?> lastWordId,
      Value<int> rowid,
    });

class $MushafLineFilterComposer extends Composer<_$QuranDatabase, MushafLine> {
  $MushafLineFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get line => $composableBuilder(
    column: $table.line,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get centered => $composableBuilder(
    column: $table.centered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstWordId => $composableBuilder(
    column: $table.firstWordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWordId => $composableBuilder(
    column: $table.lastWordId,
    builder: (column) => ColumnFilters(column),
  );
}

class $MushafLineOrderingComposer
    extends Composer<_$QuranDatabase, MushafLine> {
  $MushafLineOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get line => $composableBuilder(
    column: $table.line,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get centered => $composableBuilder(
    column: $table.centered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstWordId => $composableBuilder(
    column: $table.firstWordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWordId => $composableBuilder(
    column: $table.lastWordId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MushafLineAnnotationComposer
    extends Composer<_$QuranDatabase, MushafLine> {
  $MushafLineAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get line =>
      $composableBuilder(column: $table.line, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get centered =>
      $composableBuilder(column: $table.centered, builder: (column) => column);

  GeneratedColumn<int> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumn<int> get firstWordId => $composableBuilder(
    column: $table.firstWordId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastWordId => $composableBuilder(
    column: $table.lastWordId,
    builder: (column) => column,
  );
}

class $MushafLineTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          MushafLine,
          MushafLineData,
          $MushafLineFilterComposer,
          $MushafLineOrderingComposer,
          $MushafLineAnnotationComposer,
          $MushafLineCreateCompanionBuilder,
          $MushafLineUpdateCompanionBuilder,
          (
            MushafLineData,
            BaseReferences<_$QuranDatabase, MushafLine, MushafLineData>,
          ),
          MushafLineData,
          PrefetchHooks Function()
        > {
  $MushafLineTableManager(_$QuranDatabase db, MushafLine table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MushafLineFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MushafLineOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MushafLineAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> editionId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> line = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> centered = const Value.absent(),
                Value<int?> surah = const Value.absent(),
                Value<int?> firstWordId = const Value.absent(),
                Value<int?> lastWordId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafLineCompanion(
                editionId: editionId,
                page: page,
                line: line,
                kind: kind,
                centered: centered,
                surah: surah,
                firstWordId: firstWordId,
                lastWordId: lastWordId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String editionId,
                required int page,
                required int line,
                required String kind,
                required int centered,
                Value<int?> surah = const Value.absent(),
                Value<int?> firstWordId = const Value.absent(),
                Value<int?> lastWordId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafLineCompanion.insert(
                editionId: editionId,
                page: page,
                line: line,
                kind: kind,
                centered: centered,
                surah: surah,
                firstWordId: firstWordId,
                lastWordId: lastWordId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MushafLine, MushafLineData>(table),
                  BaseReferences<_$QuranDatabase, MushafLine, MushafLineData>(
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

typedef $MushafLineProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      MushafLine,
      MushafLineData,
      $MushafLineFilterComposer,
      $MushafLineOrderingComposer,
      $MushafLineAnnotationComposer,
      $MushafLineCreateCompanionBuilder,
      $MushafLineUpdateCompanionBuilder,
      (
        MushafLineData,
        BaseReferences<_$QuranDatabase, MushafLine, MushafLineData>,
      ),
      MushafLineData,
      PrefetchHooks Function()
    >;
typedef $MushafWordCreateCompanionBuilder =
    MushafWordCompanion Function({
      required String editionId,
      required int id,
      required int ayahId,
      required String wordKey,
      required String glyph,
      required int page,
      required int line,
      required int position,
      Value<int> rowid,
    });
typedef $MushafWordUpdateCompanionBuilder =
    MushafWordCompanion Function({
      Value<String> editionId,
      Value<int> id,
      Value<int> ayahId,
      Value<String> wordKey,
      Value<String> glyph,
      Value<int> page,
      Value<int> line,
      Value<int> position,
      Value<int> rowid,
    });

final class $MushafWordReferences
    extends BaseReferences<_$QuranDatabase, MushafWord, MushafWordData> {
  $MushafWordReferences(super.$_db, super.$_table, super.$_typedResult);

  static Ayah _ayahIdTable(_$QuranDatabase db) =>
      db.ayah.createAlias('mushaf_word__ayah_id__ayah__id');

  $AyahProcessedTableManager get ayahId {
    final $_column = $_itemColumn<int>('ayah_id')!;

    final manager = $AyahTableManager(
      $_db,
      $_db.ayah,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $MushafWordFilterComposer extends Composer<_$QuranDatabase, MushafWord> {
  $MushafWordFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wordKey => $composableBuilder(
    column: $table.wordKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get glyph => $composableBuilder(
    column: $table.glyph,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get line => $composableBuilder(
    column: $table.line,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $AyahFilterComposer get ayahId {
    final $AyahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahFilterComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafWordOrderingComposer
    extends Composer<_$QuranDatabase, MushafWord> {
  $MushafWordOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wordKey => $composableBuilder(
    column: $table.wordKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get glyph => $composableBuilder(
    column: $table.glyph,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get line => $composableBuilder(
    column: $table.line,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $AyahOrderingComposer get ayahId {
    final $AyahOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahOrderingComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafWordAnnotationComposer
    extends Composer<_$QuranDatabase, MushafWord> {
  $MushafWordAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wordKey =>
      $composableBuilder(column: $table.wordKey, builder: (column) => column);

  GeneratedColumn<String> get glyph =>
      $composableBuilder(column: $table.glyph, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get line =>
      $composableBuilder(column: $table.line, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $AyahAnnotationComposer get ayahId {
    final $AyahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahAnnotationComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafWordTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          MushafWord,
          MushafWordData,
          $MushafWordFilterComposer,
          $MushafWordOrderingComposer,
          $MushafWordAnnotationComposer,
          $MushafWordCreateCompanionBuilder,
          $MushafWordUpdateCompanionBuilder,
          (MushafWordData, $MushafWordReferences),
          MushafWordData,
          PrefetchHooks Function({bool ayahId})
        > {
  $MushafWordTableManager(_$QuranDatabase db, MushafWord table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MushafWordFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MushafWordOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MushafWordAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> editionId = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<String> wordKey = const Value.absent(),
                Value<String> glyph = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> line = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafWordCompanion(
                editionId: editionId,
                id: id,
                ayahId: ayahId,
                wordKey: wordKey,
                glyph: glyph,
                page: page,
                line: line,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String editionId,
                required int id,
                required int ayahId,
                required String wordKey,
                required String glyph,
                required int page,
                required int line,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => MushafWordCompanion.insert(
                editionId: editionId,
                id: id,
                ayahId: ayahId,
                wordKey: wordKey,
                glyph: glyph,
                page: page,
                line: line,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MushafWord, MushafWordData>(table),
                  $MushafWordReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ayahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ayahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ayahId,
                                referencedTable: $MushafWordReferences
                                    ._ayahIdTable(db),
                                referencedColumn: $MushafWordReferences
                                    ._ayahIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $MushafWordProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      MushafWord,
      MushafWordData,
      $MushafWordFilterComposer,
      $MushafWordOrderingComposer,
      $MushafWordAnnotationComposer,
      $MushafWordCreateCompanionBuilder,
      $MushafWordUpdateCompanionBuilder,
      (MushafWordData, $MushafWordReferences),
      MushafWordData,
      PrefetchHooks Function({bool ayahId})
    >;
typedef $MushafAyahPageCreateCompanionBuilder =
    MushafAyahPageCompanion Function({
      required String editionId,
      required int ayahId,
      required int page,
      required int firstLine,
      required int lastLine,
      required int firstWordId,
      required int lastWordId,
      Value<int> rowid,
    });
typedef $MushafAyahPageUpdateCompanionBuilder =
    MushafAyahPageCompanion Function({
      Value<String> editionId,
      Value<int> ayahId,
      Value<int> page,
      Value<int> firstLine,
      Value<int> lastLine,
      Value<int> firstWordId,
      Value<int> lastWordId,
      Value<int> rowid,
    });

final class $MushafAyahPageReferences
    extends
        BaseReferences<_$QuranDatabase, MushafAyahPage, MushafAyahPageData> {
  $MushafAyahPageReferences(super.$_db, super.$_table, super.$_typedResult);

  static Ayah _ayahIdTable(_$QuranDatabase db) =>
      db.ayah.createAlias('mushaf_ayah_page__ayah_id__ayah__id');

  $AyahProcessedTableManager get ayahId {
    final $_column = $_itemColumn<int>('ayah_id')!;

    final manager = $AyahTableManager(
      $_db,
      $_db.ayah,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $MushafAyahPageFilterComposer
    extends Composer<_$QuranDatabase, MushafAyahPage> {
  $MushafAyahPageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstLine => $composableBuilder(
    column: $table.firstLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastLine => $composableBuilder(
    column: $table.lastLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstWordId => $composableBuilder(
    column: $table.firstWordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWordId => $composableBuilder(
    column: $table.lastWordId,
    builder: (column) => ColumnFilters(column),
  );

  $AyahFilterComposer get ayahId {
    final $AyahFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahFilterComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafAyahPageOrderingComposer
    extends Composer<_$QuranDatabase, MushafAyahPage> {
  $MushafAyahPageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get editionId => $composableBuilder(
    column: $table.editionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstLine => $composableBuilder(
    column: $table.firstLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastLine => $composableBuilder(
    column: $table.lastLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstWordId => $composableBuilder(
    column: $table.firstWordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWordId => $composableBuilder(
    column: $table.lastWordId,
    builder: (column) => ColumnOrderings(column),
  );

  $AyahOrderingComposer get ayahId {
    final $AyahOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahOrderingComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafAyahPageAnnotationComposer
    extends Composer<_$QuranDatabase, MushafAyahPage> {
  $MushafAyahPageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get editionId =>
      $composableBuilder(column: $table.editionId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get firstLine =>
      $composableBuilder(column: $table.firstLine, builder: (column) => column);

  GeneratedColumn<int> get lastLine =>
      $composableBuilder(column: $table.lastLine, builder: (column) => column);

  GeneratedColumn<int> get firstWordId => $composableBuilder(
    column: $table.firstWordId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastWordId => $composableBuilder(
    column: $table.lastWordId,
    builder: (column) => column,
  );

  $AyahAnnotationComposer get ayahId {
    final $AyahAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ayahId,
      referencedTable: $db.ayah,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AyahAnnotationComposer(
            $db: $db,
            $table: $db.ayah,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $MushafAyahPageTableManager
    extends
        RootTableManager<
          _$QuranDatabase,
          MushafAyahPage,
          MushafAyahPageData,
          $MushafAyahPageFilterComposer,
          $MushafAyahPageOrderingComposer,
          $MushafAyahPageAnnotationComposer,
          $MushafAyahPageCreateCompanionBuilder,
          $MushafAyahPageUpdateCompanionBuilder,
          (MushafAyahPageData, $MushafAyahPageReferences),
          MushafAyahPageData,
          PrefetchHooks Function({bool ayahId})
        > {
  $MushafAyahPageTableManager(_$QuranDatabase db, MushafAyahPage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MushafAyahPageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MushafAyahPageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MushafAyahPageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> editionId = const Value.absent(),
                Value<int> ayahId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> firstLine = const Value.absent(),
                Value<int> lastLine = const Value.absent(),
                Value<int> firstWordId = const Value.absent(),
                Value<int> lastWordId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MushafAyahPageCompanion(
                editionId: editionId,
                ayahId: ayahId,
                page: page,
                firstLine: firstLine,
                lastLine: lastLine,
                firstWordId: firstWordId,
                lastWordId: lastWordId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String editionId,
                required int ayahId,
                required int page,
                required int firstLine,
                required int lastLine,
                required int firstWordId,
                required int lastWordId,
                Value<int> rowid = const Value.absent(),
              }) => MushafAyahPageCompanion.insert(
                editionId: editionId,
                ayahId: ayahId,
                page: page,
                firstLine: firstLine,
                lastLine: lastLine,
                firstWordId: firstWordId,
                lastWordId: lastWordId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<MushafAyahPage, MushafAyahPageData>(table),
                  $MushafAyahPageReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ayahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ayahId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ayahId,
                                referencedTable: $MushafAyahPageReferences
                                    ._ayahIdTable(db),
                                referencedColumn: $MushafAyahPageReferences
                                    ._ayahIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $MushafAyahPageProcessedTableManager =
    ProcessedTableManager<
      _$QuranDatabase,
      MushafAyahPage,
      MushafAyahPageData,
      $MushafAyahPageFilterComposer,
      $MushafAyahPageOrderingComposer,
      $MushafAyahPageAnnotationComposer,
      $MushafAyahPageCreateCompanionBuilder,
      $MushafAyahPageUpdateCompanionBuilder,
      (MushafAyahPageData, $MushafAyahPageReferences),
      MushafAyahPageData,
      PrefetchHooks Function({bool ayahId})
    >;

class $QuranDatabaseManager {
  final _$QuranDatabase _db;
  $QuranDatabaseManager(this._db);
  $MetaTableManager get meta => $MetaTableManager(_db, _db.meta);
  $SurahTableManager get surah => $SurahTableManager(_db, _db.surah);
  $AyahTableManager get ayah => $AyahTableManager(_db, _db.ayah);
  $TafsirTableManager get tafsir => $TafsirTableManager(_db, _db.tafsir);
  $PageTableManager get page => $PageTableManager(_db, _db.page);
  $JuzTableManager get juz => $JuzTableManager(_db, _db.juz);
  $HizbTableManager get hizb => $HizbTableManager(_db, _db.hizb);
  $AyahFtsTableManager get ayahFts => $AyahFtsTableManager(_db, _db.ayahFts);
  $DoaTableManager get doa => $DoaTableManager(_db, _db.doa);
  $AsmaulHusnaTableManager get asmaulHusna =>
      $AsmaulHusnaTableManager(_db, _db.asmaulHusna);
  $PrayerLocationTableManager get prayerLocation =>
      $PrayerLocationTableManager(_db, _db.prayerLocation);
  $MushafEditionTableManager get mushafEdition =>
      $MushafEditionTableManager(_db, _db.mushafEdition);
  $MushafAssetTableManager get mushafAsset =>
      $MushafAssetTableManager(_db, _db.mushafAsset);
  $MushafPageTableManager get mushafPage =>
      $MushafPageTableManager(_db, _db.mushafPage);
  $MushafLineTableManager get mushafLine =>
      $MushafLineTableManager(_db, _db.mushafLine);
  $MushafWordTableManager get mushafWord =>
      $MushafWordTableManager(_db, _db.mushafWord);
  $MushafAyahPageTableManager get mushafAyahPage =>
      $MushafAyahPageTableManager(_db, _db.mushafAyahPage);
}
