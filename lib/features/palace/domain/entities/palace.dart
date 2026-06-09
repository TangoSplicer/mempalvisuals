import 'package:freezed_annotation/freezed_annotation.dart';

part 'palace.freezed.dart';
part 'palace.g.dart';

@freezed
class Palace with _$Palace {
  const factory Palace({
    required String id,
    required String name,
    @Default('') String description,
    @Default([]) List<Room> rooms,
  }) = _Palace;

  factory Palace.fromJson(Map<String, dynamic> json) => _$PalaceFromJson(json);
}

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    required double width,
    required double height,
    @Default([]) List<PlacedNode> placedNodes,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

@freezed
class PlacedNode with _$PlacedNode {
  const factory PlacedNode({
    required String id,
    required String nodeId,
    required double dx,
    required double dy,
  }) = _PlacedNode;

  factory PlacedNode.fromJson(Map<String, dynamic> json) => _$PlacedNodeFromJson(json);
}
