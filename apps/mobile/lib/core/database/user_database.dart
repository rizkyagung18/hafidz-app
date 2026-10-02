import 'package:drift/drift.dart';

part 'user_database.g.dart';

/// Mutable local data, separate from the replaceable Quran asset.
@DriftDatabase(include: {'user_schema.drift'})
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
