import 'dart:math';
import 'package:flutter/material.dart';
import '../../../database/data/database.dart' as db;

class GraphCanvas extends StatefulWidget {
  final List<db.Node> nodes;
  final List<db.Edge> edges;
  final List<db.Palace> palaces;
  final int? initialPalaceId;

  const GraphCanvas(
      {super.key,
      required this.nodes,
      required this.edges,
      required this.palaces,
      this.initialPalaceId});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  final Map<String, Offset> _positions = {};
  final double _canvasSize = 8000.0;
  final TransformationController _transformationController =
      TransformationController();

  String _searchQuery = '';
  int? _selectedPalaceId;

  @override
  void initState() {
    super.initState();
    _selectedPalaceId = widget.initialPalaceId;
    _runPhysicsSimulation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final dx = (_canvasSize / 2) - (screenSize.width / 2);
      final dy = (_canvasSize / 2) - (screenSize.height / 2);
      _transformationController.value = Matrix4.identity()..translate(-dx, -dy);
    });
  }

  void _runPhysicsSimulation() {
    if (widget.nodes.isEmpty) return;
    final random = Random(42);
    final center = Offset(_canvasSize / 2, _canvasSize / 2);

    // Initial random spawn tightly around the center
    for (var node in widget.nodes) {
      _positions[node.id] = center +
          Offset(
              random.nextDouble() * 200 - 100, random.nextDouble() * 200 - 100);
    }

    double k = 200.0; // Optimal distance between nodes
    double temp =
        300.0; // MAXIMUM speed limit per iteration to prevent explosion

    // Run 150 iterations to untangle the web
    for (int i = 0; i < 150; i++) {
      Map<String, Offset> displacements = {
        for (var n in widget.nodes) n.id: Offset.zero
      };

      // 1. Repulsion
      for (int a = 0; a < widget.nodes.length; a++) {
        for (int b = a + 1; b < widget.nodes.length; b++) {
          var idA = widget.nodes[a].id;
          var idB = widget.nodes[b].id;
          var delta = _positions[idA]! - _positions[idB]!;
          var dist = delta.distance;

          // Prevent division by zero if nodes spawn on exact same pixel
          if (dist < 0.1) {
            delta = Offset(
                random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
            dist = delta.distance;
          }

          var force = (k * k) / dist;
          var disp = (delta / dist) * force;
          displacements[idA] = displacements[idA]! + disp;
          displacements[idB] = displacements[idB]! - disp;
        }
      }

      // 2. Attraction
      for (var edge in widget.edges) {
        if (_positions.containsKey(edge.sourceId) &&
            _positions.containsKey(edge.targetId)) {
          var delta = _positions[edge.sourceId]! - _positions[edge.targetId]!;
          var dist = delta.distance;

          if (dist < 0.1) {
            delta = Offset(
                random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
            dist = delta.distance;
          }

          var force = (dist * dist) / k;
          var disp = (delta / dist) * force;
          displacements[edge.sourceId] = displacements[edge.sourceId]! - disp;
          displacements[edge.targetId] = displacements[edge.targetId]! + disp;
        }
      }

      // 3. Gravity (Gentle pull to absolute center)
      for (var node in widget.nodes) {
        var gravityDisp = center - _positions[node.id]!;
        var dist = gravityDisp.distance;
        if (dist > 0) {
          displacements[node.id] =
              displacements[node.id]! + (gravityDisp / dist) * (dist * 0.05);
        }
      }

      // 4. Apply displacement with STRICT Temperature Clamp
      for (var node in widget.nodes) {
        var disp = displacements[node.id]!;
        var dist = disp.distance;
        if (dist > 0) {
          // Limit the movement to the current temperature
          var limitedDisp = (disp / dist) * min(dist, temp);
          _positions[node.id] = _positions[node.id]! + limitedDisp;
        }
      }

      // Cool down the system by 5% each iteration so nodes settle into place
      temp *= 0.95;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<db.Edge> activeEdges = _selectedPalaceId == null
        ? widget.edges
        : widget.edges.where((e) => e.palaceId == _selectedPalaceId).toList();

    Set<String> activeNodeIds = {};
    if (_selectedPalaceId != null) {
      for (var e in activeEdges) {
        activeNodeIds.add(e.sourceId);
        activeNodeIds.add(e.targetId);
      }
    }

    List<db.Node> activeNodes = _selectedPalaceId == null
        ? widget.nodes
        : widget.nodes.where((n) => activeNodeIds.contains(n.id)).toList();

    return Stack(
      children: [
        if (activeNodes.isEmpty)
          const Center(
              child: Text('No neural pathways found for this view.',
                  style: TextStyle(color: Colors.white))),
        if (activeNodes.isNotEmpty)
          InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(4000),
            minScale: 0.05,
            maxScale: 5.0,
            child: SizedBox(
              width: _canvasSize,
              height: _canvasSize,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(_canvasSize, _canvasSize),
                    painter: _EdgePainter(activeEdges, _positions),
                  ),
                  ...activeNodes.map((node) {
                    final pos = _positions[node.id] ?? const Offset(0, 0);
                    final isMatch = _searchQuery.isNotEmpty &&
                        node.label
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());

                    return Positioned(
                      left: pos.dx - 75,
                      top: pos.dy - 20,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            final scale = _transformationController.value
                                .getMaxScaleOnAxis();
                            _positions[node.id] =
                                _positions[node.id]! + (details.delta / scale);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMatch
                                ? Colors.amber.shade700
                                : Colors.teal.shade700,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (isMatch)
                                BoxShadow(
                                    color: Colors.amber.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              else
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
                            style: TextStyle(
                                color: isMatch ? Colors.black : Colors.white,
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
          ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Interrogate neural pathways...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.95),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.palaces.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _selectedPalaceId,
                        isExpanded: true,
                        icon:
                            const Icon(Icons.filter_list, color: Colors.black),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Global Grid (All Sessions)')),
                          ...widget.palaces.map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.title))),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedPalaceId = val),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EdgePainter extends CustomPainter {
  final List<db.Edge> edges;
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
