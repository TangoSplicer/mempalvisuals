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

  // Vault Management
  Future<List<Palace>> getAllPalaces() => _db.select(_db.palaces).get();
  Future<int> createRoom(String title) async {
    return await _db
        .into(_db.palaces)
        .insert(PalacesCompanion.insert(title: title));
  }

  // Chat History
  Future<List<ChatMessage>> getMessagesForPalace(int palaceId) {
    return (_db.select(_db.chatMessages)
          ..where((t) => t.palaceId.equals(palaceId)))
        .get();
  }

  Future<void> saveMessage(int palaceId, String text, bool isUser) async {
    await _db.into(_db.chatMessages).insert(
          ChatMessagesCompanion.insert(
              palaceId: palaceId, messageText: text, isUser: isUser),
        );
  }

  // Knowledge Graph Extraction
  Future<void> saveGraphData(
      int palaceId, Map<String, dynamic> graphData) async {
    await _db.transaction(() async {
      final nodes = graphData['nodes'] as List<dynamic>? ?? [];
      final edges = graphData['edges'] as List<dynamic>? ?? [];

      for (final n in nodes) {
        final id = n['id'].toString();
        final label = n['label']?.toString() ?? id;
        await _db.into(_db.nodes).insertOnConflictUpdate(
            NodesCompanion.insert(id: id, label: label));
      }

      for (final e in edges) {
        await _db.into(_db.edges).insert(EdgesCompanion.insert(
              sourceId: e['source'].toString(),
              targetId: e['target'].toString(),
              label: e['label']?.toString() ?? '',
              palaceId: palaceId,
            ));
      }
    });
  }

  // Session Filtering Queries
  Future<List<Edge>> getEdgesForPalace(int palaceId) {
    return (_db.select(_db.edges)..where((t) => t.palaceId.equals(palaceId)))
        .get();
  }

  Future<List<Node>> getNodesForPalace(int palaceId) async {
    final edges = await getEdgesForPalace(palaceId);
    if (edges.isEmpty) return [];
    final nodeIds =
        edges.expand((e) => [e.sourceId, e.targetId]).toSet().toList();
    return (_db.select(_db.nodes)..where((t) => t.id.isIn(nodeIds))).get();
  }

  // Kill-Switch Editor Methods
  Future<List<Node>> getAllNodes() => _db.select(_db.nodes).get();
  Future<List<Edge>> getAllEdges() => _db.select(_db.edges).get();
  Future<void> deleteNode(String id) =>
      (_db.delete(_db.nodes)..where((t) => t.id.equals(id))).go();
  Future<void> deleteEdge(int id) =>
      (_db.delete(_db.edges)..where((t) => t.id.equals(id))).go();
  Future<void> updateNode(String id, String newLabel) async {
    await (_db.update(_db.nodes)..where((t) => t.id.equals(id)))
        .write(NodesCompanion(label: Value(newLabel)));
  }

  Future<void> updateEdge(int id, String newLabel) async {
    await (_db.update(_db.edges)..where((t) => t.id.equals(id)))
        .write(EdgesCompanion(label: Value(newLabel)));
  }
}
