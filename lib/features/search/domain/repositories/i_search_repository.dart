import '../../../graph/domain/entities/node.dart';

abstract interface class ISearchRepository {
  Future<List<Node>> searchNodes(String query);
}
