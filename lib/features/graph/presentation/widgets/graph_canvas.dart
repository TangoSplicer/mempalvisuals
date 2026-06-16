import 'dart:math';
import 'package:flutter/material.dart';
import '../../../database/data/database.dart';

class GraphCanvas extends StatelessWidget {
  final List<Node> nodes;
  final List<Edge> edges;
  const GraphCanvas({super.key, required this.nodes, required this.edges});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GraphPainter(nodes, edges),
      child: Container(),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<Node> nodes;
  final List<Edge> edges;
  _GraphPainter(this.nodes, this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.5;
    final paintNode = Paint()..color = Colors.teal;
    final paintEdge = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    Map<String, Offset> positions = {};
    for (int i = 0; i < nodes.length; i++) {
      final angle = (i * 2 * pi) / nodes.length;
      positions[nodes[i].id] = Offset(
          center.dx + radius * cos(angle), center.dy + radius * sin(angle));
    }

    for (final edge in edges) {
      if (positions.containsKey(edge.sourceId) &&
          positions.containsKey(edge.targetId)) {
        canvas.drawLine(
            positions[edge.sourceId]!, positions[edge.targetId]!, paintEdge);
      }
    }

    for (final node in nodes) {
      final pos = positions[node.id]!;
      canvas.drawCircle(pos, 20, paintNode);
      final tp = TextPainter(
        text: TextSpan(
            text: node.label,
            style: const TextStyle(color: Colors.white, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
