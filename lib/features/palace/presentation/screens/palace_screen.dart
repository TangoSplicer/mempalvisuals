import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/palace_provider.dart';
import '../widgets/palace_canvas.dart';

class PalaceScreen extends ConsumerWidget {
  const PalaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palaceState = ref.watch(palaceStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Palace Builder'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.hub),
            onPressed: () => context.go('/graph'),
            tooltip: 'Switch to Knowledge Graph',
          ),
        ],
      ),
      body: palaceState.when(
        data: (palaces) {
          if (palaces.isEmpty) {
            return const Center(child: Text('No Memory Palaces constructed.'));
          }
          
          final defaultPalace = palaces.first;
          if (defaultPalace.rooms.isEmpty) {
            return const Center(child: Text('This palace has no rooms.'));
          }
          
          final defaultRoom = defaultPalace.rooms.first;

          return PalaceCanvas(
            room: defaultRoom,
            onNodeMoved: (updatedNode) {
              ref.read(palaceStateProvider.notifier).updateNodePosition(
                defaultPalace.id,
                defaultRoom.id,
                updatedNode,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading palace: $error')),
      ),
    );
  }
}
