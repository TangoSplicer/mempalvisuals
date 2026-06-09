import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/node.dart';
import '../../domain/entities/edge.dart';
import '../../../../bootstrap/providers.dart';

part 'graph_provider.g.dart';

typedef GraphData = ({List<Node> nodes, List<Edge> edges});

@riverpod
class GraphState extends _$GraphState {
  @override
  FutureOr<GraphData> build() async {
    final repository = ref.watch(graphRepositoryProvider);
    
    // Fetching initial batch concurrently
    final results = await Future.wait([
      repository.getNodes(limit: 1000, offset: 0),
      repository.getEdges(limit: 1000, offset: 0),
    ]);

    return (
      nodes: results[0] as List<Node>,
      edges: results[1] as List<Edge>,
    );
  }
}
