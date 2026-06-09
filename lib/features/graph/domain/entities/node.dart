import 'package:freezed_annotation/freezed_annotation.dart';

part 'node.freezed.dart';
part 'node.g.dart';

@freezed
class Node with _$Node {
  const factory Node({
    required String id,
    required String label,
    @Default([]) List<String> tags,
    @Default({}) Map<String, dynamic> metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Node;

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
}
