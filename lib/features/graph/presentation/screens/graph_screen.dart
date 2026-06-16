import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/data/palace_repository.dart';
import '../widgets/graph_canvas.dart';

class GraphScreen extends ConsumerWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(palaceRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Graph')),
      body: FutureBuilder(
        future: Future.wait([repo.getAllNodes(), repo.getAllEdges()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return GraphCanvas(
              nodes: snapshot.data![0], edges: snapshot.data![1]);
        },
      ),
    );
  }
}
