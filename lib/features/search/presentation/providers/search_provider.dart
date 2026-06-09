import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../graph/domain/entities/node.dart';
import '../../../../bootstrap/providers.dart';

part 'search_provider.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
Future<List<Node>> searchResults(SearchResultsRef ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];

  final repository = ref.watch(searchRepositoryProvider);
  return await repository.searchNodes(query);
}
