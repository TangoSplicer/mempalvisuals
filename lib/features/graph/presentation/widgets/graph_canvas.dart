import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../../database/data/database.dart' as db;

class GraphCanvas extends StatefulWidget {
  final List<db.Node> nodes;
  final List<db.Edge> edges;

  const GraphCanvas({super.key, required this.nodes, required this.edges});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  final Graph graph = Graph();
  late FruchtermanReingoldAlgorithm algorithm;

  @override
  void initState() {
    super.initState();
    // This physics algorithm mimics magnetic repulsion and spring tension to build the web
    algorithm = FruchtermanReingoldAlgorithm(iterations: 1000);

    final Map<String, Node> gNodes = {};
    for (final n in widget.nodes) {
      final node = Node.Id(n);
      gNodes[n.id] = node;
      graph.addNode(node);
    }

    for (final e in widget.edges) {
      if (gNodes.containsKey(e.sourceId) && gNodes.containsKey(e.targetId)) {
        graph.addEdge(gNodes[e.sourceId]!, gNodes[e.targetId]!,
            paint: Paint()
              ..color = Colors.grey.shade500
              ..strokeWidth = 2);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty)
      return const Center(child: Text('No neural pathways found.'));

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(
          double.infinity), // FIXED: Prevents losing nodes out of bounds
      minScale: 0.05,
      maxScale: 5.0,
      child: Padding(
        padding:
            const EdgeInsets.all(2000.0), // Start with a massive spatial buffer
        child: GraphView(
          graph: graph,
          algorithm: algorithm,
          paint: Paint()
            ..color = Colors.grey.shade500
            ..strokeWidth = 2,
          builder: (Node node) {
            final dbNode = node.key!.value as db.Node;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2))
                ],
              ),
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                dbNode.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
