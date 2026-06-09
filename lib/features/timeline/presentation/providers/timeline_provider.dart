import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/timeline_event.dart';
import '../../../../bootstrap/providers.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineState extends _$TimelineState {
  @override
  FutureOr<List<TimelineEvent>> build() async {
    final repository = ref.watch(timelineRepositoryProvider);
    return await repository.getEvents(limit: 500, offset: 0);
  }
}
