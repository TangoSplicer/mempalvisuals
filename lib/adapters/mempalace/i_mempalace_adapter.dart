/// Core interface for MemPalace backend communication.
/// The frontend must ONLY interact with the engine through this contract.
abstract interface class IMemPalaceAdapter {
  /// Bootstraps the adapter connection.
  Future<void> initialize();

  /// Safely terminates the connection and cleans up resources.
  Future<void> dispose();

  /// Retrieves a paginated list of nodes.
  Future<List<Map<String, dynamic>>> fetchNodes({int limit = 1000, int offset = 0});

  /// Retrieves a paginated list of edges.
  Future<List<Map<String, dynamic>>> fetchEdges({int limit = 1000, int offset = 0});
  
  /// Retrieves all configured Memory Palaces.
  Future<List<Map<String, dynamic>>> fetchPalaces();

  /// Saves or updates a Memory Palace layout in the core engine.
  Future<void> savePalace(Map<String, dynamic> palaceData);

  /// Executes a raw query against the MemPalace engine.
  Future<Map<String, dynamic>> executeQuery(String query);
}
