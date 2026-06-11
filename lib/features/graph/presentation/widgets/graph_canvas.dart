import 'package:flutter/material.dart';
import '../../domain/entities/node.dart';
import '../../domain/entities/edge.dart';
import '../../application/physics_engine.dart';

class GraphCanvas extends StatefulWidget {
  final List<Node> nodes;
  final List<Edge> edges;

  const GraphCanvas({super.key, required this.nodes, required this.edges});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _physicsTicker;
  late PhysicsEngine _engine;
  
  final Size _virtualCanvasSize = const Size(10000, 10000);

  @override
  void initState() {
    super.initState();
    _engine = PhysicsEngine(nodes: widget.nodes, edges: widget.edges, canvasSize: _virtualCanvasSize);
    _physicsTicker = AnimationController(vsync: this, duration: const Duration(days: 365))
      ..addListener(() {
        _engine.tick();
        setState(() {});
      });
    _physicsTicker.forward();
  }

  @override
  void dispose() {
    _physicsTicker.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.05,
      maxScale: 10.0,
      child: CustomPaint(
        size: _virtualCanvasSize, 
        painter: _VirtualizingGraphPainter(
          widget.nodes, 
          widget.edges, 
          _engine.positions,
          _transformationController,
        ),
      ),
    );
  }
}

class _VirtualizingGraphPainter extends CustomPainter {
  final List<Node> nodes;
  final List<Edge> edges;
  final Map<String, Offset> positions;
  final TransformationController controller;

  _VirtualizingGraphPainter(this.nodes, this.edges, this.positions, this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = controller.value;
    final viewport = Rect.fromLTWH(
      -matrix.getTranslation().x / matrix.getMaxScaleOnAxis(),
      -matrix.getTranslation().y / matrix.getMaxScaleOnAxis(),
      size.width / matrix.getMaxScaleOnAxis(),
      size.height / matrix.getMaxScaleOnAxis(),
    );

    final nodePaint = Paint()..color = Colors.deepPurpleAccent;
    final edgePaint = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1.0;

    for (final node in nodes) {
      final pos = positions[node.id];
      if (pos != null && viewport.contains(pos)) {
        canvas.drawCircle(pos, 6.0, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VirtualizingGraphPainter oldDelegate) => true;
}
