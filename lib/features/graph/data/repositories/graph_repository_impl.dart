import '../../../../core/logging/logger.dart';
import '../../../../adapters/mempalace/i_mempalace_adapter.dart';
import '../../domain/entities/node.dart';
import '../../domain/entities/edge.dart';
import '../../domain/repositories/i_graph_repository.dart';

class GraphRepositoryImpl implements IGraphRepository {
  final IMemPalaceAdapter _adapter;

  GraphRepositoryImpl(this._adapter);

  @override
  Future<List<Node>> getNodes({int limit = 1000, int offset = 0}) async {
    try {
      final rawNodes = await _adapter.fetchNodes(limit: limit, offset: offset);
      return rawNodes.map((json) => Node.fromJson(json)).toList();
    } catch (e, stackTrace) {
      Log.e('Failed to fetch nodes', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Edge>> getEdges({int limit = 1000, int offset = 0}) async {
    try {
      final rawEdges = await _adapter.fetchEdges(limit: limit, offset: offset);
      return rawEdges.map((json) => Edge.fromJson(json)).toList();
    } catch (e, stackTrace) {
      Log.e('Failed to fetch edges', e, stackTrace);
      rethrow;
    }
  }
}
