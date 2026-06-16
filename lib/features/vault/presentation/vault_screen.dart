import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/data/palace_repository.dart';
import '../../database/data/database.dart';
import '../../palace/presentation/palace_screen.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(palaceRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Vault'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Palace>>(
        future: repo.getAllPalaces(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final palaces = snapshot.data!;
          if (palaces.isEmpty) return const Center(child: Text('Vault is empty. Tap + to begin.'));
          
          return ListView.builder(
            itemCount: palaces.length,
            itemBuilder: (context, index) {
              final p = palaces[index];
              return ListTile(
                leading: const Icon(Icons.account_balance),
                title: Text(p.title),
                subtitle: Text(p.createdAt.toString()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PalaceScreen(existingPalaceId: p.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PalaceScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Room'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
