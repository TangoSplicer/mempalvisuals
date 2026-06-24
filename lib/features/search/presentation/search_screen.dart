import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/data/palace_repository.dart';
import '../../database/data/database.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  void _refresh() => setState(() {});

  Future<void> _editNodeDialog(PalaceRepository repo, Node node) async {
    final controller = TextEditingController(text: node.label);
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Amend Node'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Node Label', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await repo.updateNode(node.id, controller.text.trim());
              if (mounted) Navigator.pop(c);
              _refresh();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editEdgeDialog(PalaceRepository repo, Edge edge) async {
    final controller = TextEditingController(text: edge.label);
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Amend Relationship'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Edge Label', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await repo.updateEdge(edge.id, controller.text.trim());
              if (mounted) Navigator.pop(c);
              _refresh();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(palaceRepositoryProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Editor'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          bottom: const TabBar(tabs: [Tab(text: 'Nodes'), Tab(text: 'Edges')]),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<Node>>(
              future: repo.getAllNodes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final n = snapshot.data![index];
                    return ListTile(
                      title: Text(n.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${n.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => _editNodeDialog(repo, n),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await repo.deleteNode(n.id);
                              _refresh();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            FutureBuilder<List<Edge>>(
              future: repo.getAllEdges(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final e = snapshot.data![index];
                    return ListTile(
                      title: Text('${e.sourceId} -> ${e.targetId}'),
                      subtitle: Text(e.label, style: const TextStyle(color: Colors.teal)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => _editEdgeDialog(repo, e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await repo.deleteEdge(e.id);
                              _refresh();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
