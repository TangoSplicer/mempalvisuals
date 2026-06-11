import '../../core/storage/database.dart';
import 'i_mempalace_adapter.dart';

class DriftMemPalaceAdapter implements IMemPalaceAdapter {
  final AppDatabase _db;

  DriftMemPalaceAdapter(this._db);

  @override
  Future<void> initialize() async {
    // Migration logic
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNodes(
      {int limit = 1000, int offset = 0}) async {
    final query = _db.select(_db.nodes)..limit(limit, offset: offset);
    final results = await query.get();
    return results.map((row) => row.toJson()).toList();
  }

  @override
  Future<void> dispose() async {}
  @override
  Future<List<Map<String, dynamic>>> fetchEdges(
          {int limit = 1000, int offset = 0}) async =>
      [];
  @override
  Future<List<Map<String, dynamic>>> fetchPalaces() async => [];
  @override
  Future<void> savePalace(Map<String, dynamic> data) async {}
  @override
  Future<List<Map<String, dynamic>>> fetchTimelineEvents(
          {int limit = 500, int offset = 0}) async =>
      [];
  @override
  Future<List<Map<String, dynamic>>> searchNodes(String query) async => [];
  @override
  Future<Map<String, dynamic>> executeQuery(String query) async => {};
}
