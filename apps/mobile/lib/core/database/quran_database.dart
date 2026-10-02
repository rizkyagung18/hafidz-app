import 'package:drift/drift.dart';

part 'quran_database.g.dart';

/// Drift view of the independently built, immutable Quran database.
@DriftDatabase(include: {'quran_schema.drift'})
class QuranDatabase extends _$QuranDatabase {
  QuranDatabase(super.executor);

  @override
  int get schemaVersion => 3;
}
