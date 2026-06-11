import '../../../../core/logging/logger.dart';
import '../../../../adapters/mempalace/i_mempalace_adapter.dart';
import '../../../graph/domain/entities/node.dart';
import '../../domain/repositories/i_search_repository.dart';

class SearchRepositoryImpl implements ISearchRepository {
  final IMemPalaceAdapter _adapter;

  SearchRepositoryImpl(this._adapter);

  @override
  Future<List<Node>> searchNodes(String query) async {
    try {
      final rawResults = await _adapter.searchNodes(query);
      return rawResults.map((json) => Node.fromJson(json)).toList();
    } catch (e, stackTrace) {
      Log.e('Failed to execute search for query: $query', e, stackTrace);
      return [];
    }
  }
}
