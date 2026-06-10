import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Nodes extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  TextColumn get tags => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Nodes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'mempalace_db'));

  @override
  int get schemaVersion => 1;
}
