import '../../../core/logging/logger.dart';
import '../../../../adapters/mempalace/i_mempalace_adapter.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/repositories/i_timeline_repository.dart';

class TimelineRepositoryImpl implements ITimelineRepository {
  final IMemPalaceAdapter _adapter;

  TimelineRepositoryImpl(this._adapter);

  @override
  Future<List<TimelineEvent>> getEvents({int limit = 500, int offset = 0}) async {
    try {
      final rawEvents = await _adapter.fetchTimelineEvents(limit: limit, offset: offset);
      return rawEvents.map((json) => TimelineEvent.fromJson(json)).toList();
    } catch (e, stackTrace) {
      Log.e('Failed to fetch timeline events', e, stackTrace);
      rethrow;
    }
  }
}
