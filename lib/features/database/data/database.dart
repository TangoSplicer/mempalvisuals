import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Palaces, ChatMessages, Nodes, Edges])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // Bumped schema version for new table

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'sovereign_mempalace_db');
  }
}
