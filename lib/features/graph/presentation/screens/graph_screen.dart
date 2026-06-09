import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/graph_provider.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphState = ref.watch(graphStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Graph'),
        elevation: 0,
      ),
      body: graphState.when(
        data: (data) => _buildGraphCanvas(data.nodes.length, data.edges.length),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading graph: $error')),
      ),
    );
  }

  Widget _buildGraphCanvas(int nodeCount, int edgeCount) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub, size: 64, color: Colors.deepPurple),
          const SizedBox(height: 16),
          Text(
            'Graph Canvas Placeholder\nNodes: $nodeCount | Edges: $edgeCount',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text('2D spatial rendering engine pending.'),
        ],
      ),
    );
  }
}
