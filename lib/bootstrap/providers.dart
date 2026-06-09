import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../adapters/mempalace/i_mempalace_adapter.dart';
import '../adapters/mempalace/mock_mempalace_adapter.dart';
import '../features/graph/domain/repositories/i_graph_repository.dart';
import '../features/graph/data/repositories/graph_repository_impl.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
IMemPalaceAdapter memPalaceAdapter(MemPalaceAdapterRef ref) {
  // Starting with 1,000 nodes for initial UI iteration. Will scale to 50k+ for stress testing.
  return MockMemPalaceAdapter(targetNodeCount: 1000); 
}

@Riverpod(keepAlive: true)
IGraphRepository graphRepository(GraphRepositoryRef ref) {
  final adapter = ref.watch(memPalaceAdapterProvider);
  return GraphRepositoryImpl(adapter);
}
