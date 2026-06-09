import 'package:freezed_annotation/freezed_annotation.dart';

part 'edge.freezed.dart';
part 'edge.g.dart';

@freezed
class Edge with _$Edge {
  const factory Edge({
    required String id,
    required String sourceId,
    required String targetId,
    required String relation,
    @Default(1.0) double weight,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Edge;

  factory Edge.fromJson(Map<String, dynamic> json) => _$EdgeFromJson(json);
}
