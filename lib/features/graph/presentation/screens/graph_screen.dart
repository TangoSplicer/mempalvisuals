import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/graph_provider.dart';
import '../widgets/graph_canvas.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphState = ref.watch(graphStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Graph'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
            tooltip: 'Search Knowledge Graph',
          ),
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () => context.go('/palace'),
            tooltip: 'Memory Palace Builder',
          ),
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () => context.go('/timeline'),
            tooltip: 'Timeline Explorer',
          ),
        ],
      ),
      body: graphState.when(
        data: (data) => Stack(
          children: [
            Positioned.fill(
              child: GraphCanvas(nodes: data.nodes, edges: data.edges),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading graph: $error')),
      ),
    );
  }
}
