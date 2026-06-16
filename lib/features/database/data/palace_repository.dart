import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import '../application/database_provider.dart';

final palaceRepositoryProvider = Provider<PalaceRepository>((ref) {
  return PalaceRepository(ref.read(databaseProvider));
});

class PalaceRepository {
  final AppDatabase _db;
  PalaceRepository(this._db);

  Future<int> createRoom(String title) async {
    return await _db.into(_db.palaces).insert(
      PalacesCompanion.insert(title: title),
    );
  }

  Future<void> saveGraphData(int palaceId, Map<String, dynamic> graphData) async {
    // Execute as a single transaction for data integrity
    await _db.transaction(() async {
      final nodes = graphData['nodes'] as List<dynamic>? ?? [];
      final edges = graphData['edges'] as List<dynamic>? ?? [];

      // Insert Nodes (Upsert pattern to avoid duplicates across Palaces)
      for (final n in nodes) {
        final id = n['id'].toString();
        final label = n['label']?.toString() ?? id;
        await _db.into(_db.nodes).insertOnConflictUpdate(
          NodesCompanion.insert(id: id, label: label),
        );
      }

      // Insert Edges with the relational Palace ID
      for (final e in edges) {
        final source = e['source'].toString();
        final target = e['target'].toString();
        final label = e['label']?.toString() ?? '';
        await _db.into(_db.edges).insert(
          EdgesCompanion.insert(
            sourceId: source,
            targetId: target,
            label: label,
            palaceId: palaceId,
          ),
        );
      }
    });
  }
}
