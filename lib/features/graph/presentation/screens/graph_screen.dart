import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/data/palace_repository.dart';
import '../widgets/graph_canvas.dart';

class GraphScreen extends ConsumerWidget {
  final int? palaceId;
  const GraphScreen({super.key, this.palaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(palaceRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(palaceId == null ? 'Global Knowledge Graph' : 'Session Neural Pathway'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder(
        future: Future.wait([
          repo.getAllNodes(),
          repo.getAllEdges(),
          repo.getAllPalaces() // Fetch all sessions for the dropdown filter
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return GraphCanvas(
            nodes: snapshot.data![0], 
            edges: snapshot.data![1], 
            palaces: snapshot.data![2],
            initialPalaceId: palaceId,
          );
        },
      ),
    );
  }
}
