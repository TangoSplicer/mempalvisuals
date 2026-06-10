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
EOFcat > lib/adapters/mempalace/drift_mempalace_adapter.dart <<'EOF'
import '../../core/storage/database.dart';
import 'i_mempalace_adapter.dart';

class DriftMemPalaceAdapter implements IMemPalaceAdapter {
  final AppDatabase _db;

  DriftMemPalaceAdapter(this._db);

  @override
  Future<void> initialize() async {
    // Migration logic would go here
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNodes({int limit = 1000, int offset = 0}) async {
    final query = _db.select(_db.nodes)..limit(limit, offset: offset);
    final results = await query.get();
    return results.map((row) => row.toJson()).toList();
  }

  // Implementation of remaining required methods...
  @override Future<void> dispose() async {}
  @override Future<List<Map<String, dynamic>>> fetchEdges({int limit = 1000, int offset = 0}) async => [];
  @override Future<List<Map<String, dynamic>>> fetchPalaces() async => [];
  @override Future<void> savePalace(Map<String, dynamic> data) async {}
  @override Future<List<Map<String, dynamic>>> fetchTimelineEvents({int limit = 500, int offset = 0}) async => [];
  @override Future<List<Map<String, dynamic>>> searchNodes(String query) async => [];
  @override Future<Map<String, dynamic>> executeQuery(String query) async => {};
}
