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
  final TransformationController _transformationController = TransformationController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    algorithm = FruchtermanReingoldAlgorithm(FruchtermanReingoldConfiguration(iterations: 1000));
    
    final Map<String, Node> gNodes = {};
    for (final n in widget.nodes) {
      final node = Node.Id(n);
      gNodes[n.id] = node;
      graph.addNode(node);
    }
    
    for (final e in widget.edges) {
      if (gNodes.containsKey(e.sourceId) && gNodes.containsKey(e.targetId)) {
        graph.addEdge(
          gNodes[e.sourceId]!, 
          gNodes[e.targetId]!, 
          paint: Paint()..color = Colors.grey.shade500..strokeWidth = 2
        );
      }
    }

    // Teleport camera to the center of the graph padding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      // Account for the 2000 padding + half screen width to center the web
      final dx = 2000.0 - (screenSize.width / 2);
      final dy = 2000.0 - (screenSize.height / 2);
      _transformationController.value = Matrix4.identity()..translate(-dx, -dy);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) return const Center(child: Text('No neural pathways found.'));
    
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transformationController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.05,
          maxScale: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(2000.0),
            child: GraphView(
              graph: graph,
              algorithm: algorithm,
              paint: Paint()..color = Colors.grey.shade500..strokeWidth = 2,
              builder: (Node node) {
                final dbNode = node.key!.value as db.Node;
                // Highlight logic based on live search query
                final isMatch = _searchQuery.isNotEmpty && 
                                dbNode.label.toLowerCase().contains(_searchQuery.toLowerCase());

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMatch ? Colors.amber.shade700 : Colors.teal.shade700,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isMatch) BoxShadow(color: Colors.amber.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)
                      else BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(2, 2))
                    ],
                  ),
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Text(
                    dbNode.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isMatch ? Colors.black : Colors.white, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Search Overlay
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Interrogate knowledge graph...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
