import 'dart:math';
import 'package:flutter/material.dart';
import '../../../database/data/database.dart';

class GraphCanvas extends StatefulWidget {
  final List<Node> nodes;
  final List<Edge> edges;

  const GraphCanvas({super.key, required this.nodes, required this.edges});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  final Map<String, Offset> _positions = {};
  final double _canvasSize = 4000.0;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _initializePositions();

    // Teleport the camera to the center of the 4000x4000 canvas once the UI builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final dx = (_canvasSize / 2) - (screenSize.width / 2);
      final dy = (_canvasSize / 2) - (screenSize.height / 2);
      _transformationController.value = Matrix4.identity()..translate(-dx, -dy);
    });
  }

  void _initializePositions() {
    if (widget.nodes.isEmpty) return;
    final center = Offset(_canvasSize / 2, _canvasSize / 2);
    final radius =
        250.0; // Fixed radius to prevent nodes from spawning too far apart

    for (int i = 0; i < widget.nodes.length; i++) {
      final angle = (i * 2 * pi) / widget.nodes.length;
      _positions[widget.nodes[i].id] = Offset(
          center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.1,
      maxScale: 5.0,
      child: SizedBox(
        width: _canvasSize,
        height: _canvasSize,
        child: Stack(
          children: [
            // Layer 1: Edges
            CustomPaint(
              size: Size(_canvasSize, _canvasSize),
              painter: _EdgePainter(widget.edges, _positions),
            ),
            // Layer 2: Draggable Nodes
            ...widget.nodes.map((node) {
              final pos = _positions[node.id] ?? const Offset(0, 0);
              return Positioned(
                left: pos.dx - 60,
                top: pos.dy - 20,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      // Adjust node position based on zoom scale to keep dragging smooth
                      final scale =
                          _transformationController.value.getMaxScaleOnAxis();
                      _positions[node.id] =
                          _positions[node.id]! + (details.delta / scale);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                      node.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  final List<Edge> edges;
  final Map<String, Offset> positions;

  _EdgePainter(this.edges, this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    final paintEdge = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 2.0;

    for (final edge in edges) {
      if (positions.containsKey(edge.sourceId) &&
          positions.containsKey(edge.targetId)) {
        canvas.drawLine(
            positions[edge.sourceId]!, positions[edge.targetId]!, paintEdge);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
