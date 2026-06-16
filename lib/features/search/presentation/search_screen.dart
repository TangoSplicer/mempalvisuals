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

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(palaceRepositoryProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kill-Switch Editor'),
          bottom: const TabBar(tabs: [Tab(text: 'Nodes'), Tab(text: 'Edges')]),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<Node>>(
              future: repo.getAllNodes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final n = snapshot.data![index];
                    return ListTile(
                      title: Text(n.label),
                      subtitle: Text('ID: ${n.id}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await repo.deleteNode(n.id);
                          _refresh();
                        },
                      ),
                    );
                  },
                );
              },
            ),
            FutureBuilder<List<Edge>>(
              future: repo.getAllEdges(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final e = snapshot.data![index];
                    return ListTile(
                      title: Text('${e.sourceId} -> ${e.targetId}'),
                      subtitle: Text(e.label),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await repo.deleteEdge(e.id);
                          _refresh();
                        },
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
