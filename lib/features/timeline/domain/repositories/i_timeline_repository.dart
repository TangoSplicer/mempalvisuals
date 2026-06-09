import '../entities/timeline_event.dart';

abstract interface class ITimelineRepository {
  Future<List<TimelineEvent>> getEvents({int limit = 500, int offset = 0});
}
