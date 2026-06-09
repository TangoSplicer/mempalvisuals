import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

@freezed
class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required String title,
    required DateTime timestamp,
    required String relatedNodeId,
    @Default('') String description,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);
}
