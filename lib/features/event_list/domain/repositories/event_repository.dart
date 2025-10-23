import 'package:event_management/features/event_list/domain/entities/event_list_result.dart';
import 'package:event_management/features/event_list/domain/entities/event_status.dart';

abstract class EventRepository {
  Future<EventListResult> getAllEvents({
    required int page,
    EventStatus? status,
    String? search,
  });
}
