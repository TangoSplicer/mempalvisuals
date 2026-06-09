import 'dart:math';
import '../../core/logging/logger.dart';
import 'i_mempalace_adapter.dart';

class MockMemPalaceAdapter implements IMemPalaceAdapter {
  final int _targetNodeCount;
  final List<Map<String, dynamic>> _nodes = [];
  final List<Map<String, dynamic>> _edges = [];
  bool _isInitialized = false;

  MockMemPalaceAdapter({int targetNodeCount = 50000}) : _targetNodeCount = targetNodeCount;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    Log.i('Initializing MockMemPalaceAdapter with $_targetNodeCount nodes...');
    
    // Deterministic seed ensures consistent graph layout for testing
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

    // Generate Edges (Simulating natural clustering)
    for (int i = 1; i < _targetNodeCount; i++) {
      int target = random.nextInt(i); // Connect to a previously created node
      _edges.add({
        'id': 'edge_$i',
        'sourceId': 'node_$i',
        'targetId': 'node_$target',
        'relation': 'relates_to',
        'weight': random.nextDouble(),
      });
      
      // Add secondary links to create dense clusters
      if (i % 10 == 0) {
         int secondaryTarget = random.nextInt(i);
         _edges.add({
          'id': 'edge_${i}_sec',
          'sourceId': 'node_$i',
          'targetId': 'node_$secondaryTarget',
          'relation': 'references',
          'weight': random.nextDouble(),
        });
      }
    }

    _isInitialized = true;
    Log.i('MockMemPalaceAdapter initialized. Nodes: ${_nodes.length}, Edges: ${_edges.length}');
  }

  @override
  Future<void> dispose() async {
    _nodes.clear();
    _edges.clear();
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
  Future<Map<String, dynamic>> executeQuery(String query) async {
     Log.d('Mock executing query: $query');
     return {'status': 'success', 'mocked': true, 'query': query};
  }
}
