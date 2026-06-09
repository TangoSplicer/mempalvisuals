import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../adapters/mempalace/i_mempalace_adapter.dart';
import '../adapters/mempalace/mock_mempalace_adapter.dart';
import '../features/graph/domain/repositories/i_graph_repository.dart';
import '../features/graph/data/repositories/graph_repository_impl.dart';
import '../features/palace/domain/repositories/i_palace_repository.dart';
import '../features/palace/data/repositories/palace_repository_impl.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
IMemPalaceAdapter memPalaceAdapter(MemPalaceAdapterRef ref) {
  return MockMemPalaceAdapter(targetNodeCount: 1000);
}

@Riverpod(keepAlive: true)
IGraphRepository graphRepository(GraphRepositoryRef ref) {
  final adapter = ref.watch(memPalaceAdapterProvider);
  return GraphRepositoryImpl(adapter);
}

@Riverpod(keepAlive: true)
IPalaceRepository palaceRepository(PalaceRepositoryRef ref) {
  final adapter = ref.watch(memPalaceAdapterProvider);
  return PalaceRepositoryImpl(adapter);
}
