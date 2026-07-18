import 'dart:math';
import 'package:flutter/material.dart';
import '../../../database/data/database.dart' as db;

class GraphCanvas extends StatefulWidget {
  final List<db.Node> nodes;
  final List<db.Edge> edges;
  final List<db.Palace> palaces;
  final int? initialPalaceId;

  const GraphCanvas({super.key, required this.nodes, required this.edges, required this.palaces, this.initialPalaceId});

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  final Map<String, Offset> _positions = {};
  final double _canvasSize = 40000.0; // MASSIVE canvas expansion to solve clipping
  final TransformationController _transformationController = TransformationController();
  
  String _searchQuery = '';
  int? _selectedPalaceId;
  String? _focusedNodeId;
  int _lineageDepth = 1; // Multi-tier selector state

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

    for (var node in widget.nodes) {
      _positions[node.id] = center + Offset(random.nextDouble() * 800 - 400, random.nextDouble() * 800 - 400);
    }

    double k = min(1000.0, 300.0 + (widget.nodes.length * 2.5)); 
    double temp = 1000.0; 
    int iterations = 350;
    
    for (int i = 0; i < iterations; i++) {
      Map<String, Offset> displacements = { for (var n in widget.nodes) n.id: Offset.zero };

      for (int a = 0; a < widget.nodes.length; a++) {
        for (int b = a + 1; b < widget.nodes.length; b++) {
          var idA = widget.nodes[a].id;
          var idB = widget.nodes[b].id;
          var delta = _positions[idA]! - _positions[idB]!;
          var dist = delta.distance;
          
          if (dist < 0.1) {
            delta = Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
            dist = delta.distance;
          }
          
          var force = (k * k) / dist;
          var disp = (delta / dist) * force;
          displacements[idA] = displacements[idA]! + disp;
          displacements[idB] = displacements[idB]! - disp;
        }
      }

      for (var edge in widget.edges) {
        if (_positions.containsKey(edge.sourceId) && _positions.containsKey(edge.targetId)) {
          var delta = _positions[edge.sourceId]! - _positions[edge.targetId]!;
          var dist = delta.distance;
          
          if (dist < 0.1) {
             delta = Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1);
             dist = delta.distance;
          }
          
          var force = (dist * dist) / k;
          var disp = (delta / dist) * force;
          displacements[edge.sourceId] = displacements[edge.sourceId]! - disp;
          displacements[edge.targetId] = displacements[edge.targetId]! + disp;
        }
      }

      for (var node in widget.nodes) {
        var gravityDisp = center - _positions[node.id]!;
        var dist = gravityDisp.distance;
        if (dist > 0) {
          displacements[node.id] = displacements[node.id]! + (gravityDisp / dist) * (dist * 0.015);
        }
      }

      for (var node in widget.nodes) {
        var disp = displacements[node.id]!;
        var dist = disp.distance;
        if (dist > 0) {
          var limitedDisp = (disp / dist) * min(dist, temp);
          _positions[node.id] = _positions[node.id]! + limitedDisp;
        }
      }

      temp *= 0.95; 
    }
  }

  // Breadth-First Search to dynamically highlight N-tier connections
  Set<String> _getLineage(String rootId, List<db.Edge> edges, int maxDepth) {
    Set<String> visited = {rootId};
    Set<String> currentLevel = {rootId};

    for (int i = 0; i < maxDepth; i++) {
      Set<String> nextLevel = {};
      for (var edge in edges) {
        if (currentLevel.contains(edge.sourceId) && !visited.contains(edge.targetId)) {
          nextLevel.add(edge.targetId);
        }
        if (currentLevel.contains(edge.targetId) && !visited.contains(edge.sourceId)) {
          nextLevel.add(edge.sourceId);
        }
      }
      if (nextLevel.isEmpty) break;
      visited.addAll(nextLevel);
      currentLevel = nextLevel;
    }
    return visited;
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

    Set<String> lineageNodeIds = _focusedNodeId != null ? _getLineage(_focusedNodeId!, activeEdges, _lineageDepth) : {};

    return Stack(
      children: [
        if (activeNodes.isEmpty)
          const Center(child: Text('No neural pathways found for this view.', style: TextStyle(color: Colors.white))),
        
        if (activeNodes.isNotEmpty)
          GestureDetector(
            onTap: () => setState(() {
              _focusedNodeId = null;
              _lineageDepth = 1; // Reset depth when clearing focus
            }),
            child: InteractiveViewer(
              transformationController: _transformationController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(20000), // Massive margin to accommodate the 40000 canvas
              minScale: 0.01,
              maxScale: 5.0,
              child: SizedBox(
                width: _canvasSize,
                height: _canvasSize,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(_canvasSize, _canvasSize),
                      painter: _EdgePainter(activeEdges, _positions, _focusedNodeId, lineageNodeIds),
                    ),
                    
                    ...activeNodes.map((node) {
                      final pos = _positions[node.id] ?? const Offset(0, 0);
                      final isMatch = _searchQuery.isNotEmpty && node.label.toLowerCase().contains(_searchQuery.toLowerCase());
                      final isFocused = _focusedNodeId == null || lineageNodeIds.contains(node.id);

                      return Positioned(
                        left: pos.dx - 75,
                        top: pos.dy - 20,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _focusedNodeId = node.id;
                            _lineageDepth = 1; // Reset depth on new node selection
                          }),
                          onPanUpdate: (details) {
                            setState(() {
                              final scale = _transformationController.value.getMaxScaleOnAxis();
                              _positions[node.id] = _positions[node.id]! + (details.delta / scale);
                            });
                          },
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isFocused ? 1.0 : 0.15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: _focusedNodeId == node.id ? Colors.deepPurple.shade600 : (isMatch ? Colors.amber.shade700 : Colors.teal.shade700),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  if (isMatch || _focusedNodeId == node.id) BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                                  else BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(2, 2))
                                ],
                              ),
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                node.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isMatch ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        
        // Top Search & Filter UI
        Positioned(
          top: 16, left: 16, right: 16,
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                        icon: const Icon(Icons.filter_list, color: Colors.black),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Global Grid (All Sessions)')),
                          ...widget.palaces.map((p) => DropdownMenuItem(value: p.id, child: Text(p.title))),
                        ],
                        onChanged: (val) => setState(() {
                          _selectedPalaceId = val;
                          _focusedNodeId = null; 
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom Multi-Tier Lineage Slider
        if (_focusedNodeId != null)
          Positioned(
            bottom: 32, left: 16, right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Text('Depth:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: _lineageDepth.toDouble(),
                        min: 1, max: 4, divisions: 3,
                        activeColor: Colors.deepPurple,
                        inactiveColor: Colors.grey.shade300,
                        onChanged: (val) => setState(() => _lineageDepth = val.toInt()),
                      ),
                    ),
                    Text('$_lineageDepth', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => setState(() {
                        _focusedNodeId = null;
                        _lineageDepth = 1;
                      }),
                    )
                  ],
                ),
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
  final String? focusedNodeId;
  final Set<String> lineageNodeIds;

  _EdgePainter(this.edges, this.positions, this.focusedNodeId, this.lineageNodeIds);

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      if (positions.containsKey(edge.sourceId) && positions.containsKey(edge.targetId)) {
        bool isFocusedEdge = focusedNodeId == null || (lineageNodeIds.contains(edge.sourceId) && lineageNodeIds.contains(edge.targetId));
        
        final paintEdge = Paint()
          ..color = isFocusedEdge ? Colors.grey.shade400 : Colors.grey.shade800.withOpacity(0.15)
          ..strokeWidth = isFocusedEdge && focusedNodeId != null ? 3.0 : 1.5;

        final p1 = positions[edge.sourceId]!;
        final p2 = positions[edge.targetId]!;
        canvas.drawLine(p1, p2, paintEdge);

        if (focusedNodeId != null && isFocusedEdge) {
          final textSpan = TextSpan(
            text: edge.label,
            style: const TextStyle(color: Colors.yellowAccent, fontSize: 10, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
          );
          final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
          textPainter.layout();
          
          final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
          textPainter.paint(canvas, midPoint - Offset(textPainter.width / 2, textPainter.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
