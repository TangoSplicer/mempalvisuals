import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../adapters/mempalace/i_mempalace_adapter.dart';
import '../adapters/mempalace/drift_mempalace_adapter.dart';
import '../core/storage/database.dart';
import '../features/graph/domain/repositories/i_graph_repository.dart';
import '../features/graph/data/repositories/graph_repository_impl.dart';
import '../features/palace/domain/repositories/i_palace_repository.dart';
import '../features/palace/data/repositories/palace_repository_impl.dart';
import '../features/timeline/domain/repositories/i_timeline_repository.dart';
import '../features/timeline/data/repositories/timeline_repository_impl.dart';
import '../features/search/domain/repositories/i_search_repository.dart';
import '../features/search/data/repositories/search_repository_impl.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
IMemPalaceAdapter memPalaceAdapter(MemPalaceAdapterRef ref) {
  final db = AppDatabase();
  return DriftMemPalaceAdapter(db);
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

@Riverpod(keepAlive: true)
ITimelineRepository timelineRepository(TimelineRepositoryRef ref) {
  final adapter = ref.watch(memPalaceAdapterProvider);
  return TimelineRepositoryImpl(adapter);
}

@Riverpod(keepAlive: true)
ISearchRepository searchRepository(SearchRepositoryRef ref) {
  final adapter = ref.watch(memPalaceAdapterProvider);
  return SearchRepositoryImpl(adapter);
}
