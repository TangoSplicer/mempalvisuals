import 'dart:math';
import '../../core/logging/logger.dart';
import 'i_mempalace_adapter.dart';

class MockMemPalaceAdapter implements IMemPalaceAdapter {
  final int _targetNodeCount;
  final List<Map<String, dynamic>> _nodes = [];
  final List<Map<String, dynamic>> _edges = [];
  final List<Map<String, dynamic>> _palaces = [];
  final List<Map<String, dynamic>> _timelineEvents = [];
  bool _isInitialized = false;

  MockMemPalaceAdapter({int targetNodeCount = 50000})
      : _targetNodeCount = targetNodeCount;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    Log.i('Initializing MockMemPalaceAdapter with $_targetNodeCount nodes...');

    final random = Random(42);
    final now = DateTime.now();

    // Generate Nodes
    for (int i = 0; i < _targetNodeCount; i++) {
      _nodes.add({
        'id': 'node_$i',
        'label': 'Memory Concept $i',
        'tags': ['mock', 'concept'],
        'metadata': {},
        'createdAt':
            now.subtract(Duration(days: random.nextInt(365))).toIso8601String(),
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
      'description': 'Main entry point.',
      'rooms': [
        {
          'id': 'room_1',
          'name': 'Foyer',
          'width': 2000.0,
          'height': 2000.0,
          'placedNodes': [
            {'id': 'pn_1', 'nodeId': 'node_0', 'dx': 1000.0, 'dy': 1000.0},
          ]
        }
      ]
    });

    // Generate Timeline Events
    for (int i = 0; i < 100; i++) {
      _timelineEvents.add({
        'id': 'event_$i',
        'title': 'Forensic Discovery $i',
        'timestamp':
            now.subtract(Duration(days: random.nextInt(730))).toIso8601String(),
        'relatedNodeId': 'node_${random.nextInt(100)}',
        'description':
            'Historical chronometer event logged during index creation.',
      });
    }

    // Sort events chronologically
    _timelineEvents.sort((a, b) => DateTime.parse(a['timestamp'])
        .compareTo(DateTime.parse(b['timestamp'])));

    _isInitialized = true;
    Log.i(
        'MockMemPalaceAdapter initialized. Events: ${_timelineEvents.length}');
  }

  @override
  Future<void> dispose() async {
    _nodes.clear();
    _edges.clear();
    _palaces.clear();
    _timelineEvents.clear();
    _isInitialized = false;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNodes(
          {int limit = 1000, int offset = 0}) async =>
      _paginate(_nodes, limit, offset);

  @override
  Future<List<Map<String, dynamic>>> fetchEdges(
          {int limit = 1000, int offset = 0}) async =>
      _paginate(_edges, limit, offset);

  @override
  Future<List<Map<String, dynamic>>> fetchPalaces() async => _palaces;

  @override
  Future<List<Map<String, dynamic>>> fetchTimelineEvents(
          {int limit = 500, int offset = 0}) async =>
      _paginate(_timelineEvents, limit, offset);

  @override
  Future<void> savePalace(Map<String, dynamic> palaceData) async {
    final index = _palaces.indexWhere((p) => p['id'] == palaceData['id']);
    if (index >= 0)
      _palaces[index] = palaceData;
    else
      _palaces.add(palaceData);
  }

  @override
  Future<Map<String, dynamic>> executeQuery(String query) async =>
      {'status': 'success'};

  List<Map<String, dynamic>> _paginate(
      List<Map<String, dynamic>> list, int limit, int offset) {
    if (offset >= list.length) return [];
    final end = (offset + limit < list.length) ? offset + limit : list.length;
    return list.sublist(offset, end);
  }
}
