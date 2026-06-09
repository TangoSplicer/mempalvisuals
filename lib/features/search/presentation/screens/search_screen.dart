import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final searchState = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search memories, tags, or concepts...',
            border: InputBorder.none,
          ),
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).updateQuery(val),
        ),
        elevation: 0,
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                ref.read(searchQueryProvider.notifier).updateQuery('');
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Begin typing to explore the knowledge graph.'),
                ],
              ),
            )
          : searchState.when(
              data: (nodes) {
                if (nodes.isEmpty) {
                  return const Center(child: Text('No matching nodes found.'));
                }
                return ListView.builder(
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    return ListTile(
                      leading: const Icon(Icons.hub),
                      title: Text(node.label),
                      subtitle: Text('Tags: ${node.tags.join(', ')}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Future: Navigate to Node Details or Center Graph on Node
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected: ${node.label}')),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Search error: $e')),
            ),
    );
  }
}
