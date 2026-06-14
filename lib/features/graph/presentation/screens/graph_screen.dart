import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/graph_canvas.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: Restore your specific Riverpod data watch here
    // final data = ref.watch(yourGraphProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Graph'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Safely pops the software/hardware back button
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Return to Home',
            onPressed: () => context.go('/'), // Clears stack and goes home
          ),
        ],
      ),
      body: const SafeArea(
        // Note: Restore your data.nodes and data.edges here
        child: GraphCanvas(nodes: [], edges: []),
      ),
    );
  }
}
