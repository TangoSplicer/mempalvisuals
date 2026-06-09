import '../entities/node.dart';
import '../entities/edge.dart';

abstract interface class IGraphRepository {
  Future<List<Node>> getNodes({int limit = 1000, int offset = 0});
  Future<List<Edge>> getEdges({int limit = 1000, int offset = 0});
}
