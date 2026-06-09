import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/palace.dart';
import '../../../../bootstrap/providers.dart';

part 'palace_provider.g.dart';

@riverpod
class PalaceState extends _$PalaceState {
  @override
  FutureOr<List<Palace>> build() async {
    final repository = ref.watch(palaceRepositoryProvider);
    return await repository.getPalaces();
  }

  Future<void> updateNodePosition(
      String palaceId, String roomId, PlacedNode updatedNode) async {
    if (state.value == null) return;

    final currentPalaces = List<Palace>.from(state.value!);
    final palaceIndex = currentPalaces.indexWhere((p) => p.id == palaceId);
    if (palaceIndex == -1) return;

    final palace = currentPalaces[palaceIndex];
    final roomIndex = palace.rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex == -1) return;

    final room = palace.rooms[roomIndex];
    final nodeIndex =
        room.placedNodes.indexWhere((n) => n.id == updatedNode.id);
    if (nodeIndex == -1) return;

    // Immutable state update
    final updatedNodes = List<PlacedNode>.from(room.placedNodes);
    updatedNodes[nodeIndex] = updatedNode;

    final updatedRoom = room.copyWith(placedNodes: updatedNodes);
    final updatedRooms = List<Room>.from(palace.rooms);
    updatedRooms[roomIndex] = updatedRoom;

    final updatedPalace = palace.copyWith(rooms: updatedRooms);
    currentPalaces[palaceIndex] = updatedPalace;

    // Optimistic UI update
    state = AsyncData(currentPalaces);

    // Persist to engine
    final repository = ref.read(palaceRepositoryProvider);
    await repository.savePalace(updatedPalace);
  }
}
