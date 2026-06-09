import 'dart:math';
import '../../core/logging/logger.dart';
import 'i_mempalace_adapter.dart';

class MockMemPalaceAdapter implements IMemPalaceAdapter {
  final int _targetNodeCount;
  final List<Map<String, dynamic>> _nodes = [];
  final List<Map<String, dynamic>> _edges = [];
  final List<Map<String, dynamic>> _palaces = [];
  bool _isInitialized = false;

  MockMemPalaceAdapter({int targetNodeCount = 50000}) : _targetNodeCount = targetNodeCount;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    Log.i('Initializing MockMemPalaceAdapter with $_targetNodeCount nodes...');
    
    final random = Random(42); 
    
    // Generate Nodes
    for (int i = 0; i < _targetNodeCount; i++) {
      _nodes.add({
        'id': 'node_$i',
        'label': 'Memory Concept $i',
        'tags': ['mock', 'concept', if (i % 5 == 0) 'important'],
        'metadata': {'complexity': random.nextDouble()},
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    // Generate Edges
    for (int i = 1; i < _targetNodeCount; i++) {
      int target = random.nextInt(i); 
      _edges.add({
        'id': 'edge_$i',
        'sourceId': 'node_$i',
        'targetId': 'node_$target',
        'relation': 'relates_to',
        'weight': random.nextDouble(),
      });
    }

    // Generate Default Palace
    _palaces.add({
      'id': 'palace_1',
      'name': 'Primary Mind Palace',
      'description': 'Main entry point for mapped memories.',
      'rooms': [
        {
          'id': 'room_1',
          'name': 'Foyer',
          'width': 2000.0,
          'height': 2000.0,
          'placedNodes': [
            {'id': 'pn_1', 'nodeId': 'node_0', 'dx': 1000.0, 'dy': 1000.0},
            {'id': 'pn_2', 'nodeId': 'node_1', 'dx': 1200.0, 'dy': 900.0},
          ]
        }
      ]
    });

    _isInitialized = true;
    Log.i('MockMemPalaceAdapter initialized. Nodes: ${_nodes.length}, Edges: ${_edges.length}');
  }

  @override
  Future<void> dispose() async {
    _nodes.clear();
    _edges.clear();
    _palaces.clear();
    _isInitialized = false;
    Log.i('MockMemPalaceAdapter disposed.');
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNodes({int limit = 1000, int offset = 0}) async {
    if (offset >= _nodes.length) return [];
    final end = (offset + limit < _nodes.length) ? offset + limit : _nodes.length;
    return _nodes.sublist(offset, end);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEdges({int limit = 1000, int offset = 0}) async {
    if (offset >= _edges.length) return [];
    final end = (offset + limit < _edges.length) ? offset + limit : _edges.length;
    return _edges.sublist(offset, end);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPalaces() async {
    return _palaces;
  }

  @override
  Future<void> savePalace(Map<String, dynamic> palaceData) async {
    final index = _palaces.indexWhere((p) => p['id'] == palaceData['id']);
    if (index >= 0) {
      _palaces[index] = palaceData;
    } else {
      _palaces.add(palaceData);
    }
    Log.i('Palace saved: ${palaceData['name']}');
  }

  @override
  Future<Map<String, dynamic>> executeQuery(String query) async {
     return {'status': 'success', 'mocked': true, 'query': query};
  }
}
