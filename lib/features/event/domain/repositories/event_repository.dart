import 'package:event_management/features/event/data/models/attendant.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_counters.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/event_status.dart';

abstract class EventRepository {
  Future<EventListResult> getAllEvents({
    int page = 0,
    int size = 12,
    String sortBy = 'startTime',
    String sortDir = 'asc',
    EventStatus? status,
    String? search,
  });

  Future<EventListResult> getManagedEvents({
    int page = 0,
    int size = 12,
    String sortBy = 'startTime',
    String sortDir = 'asc',
    EventStatus? status,
    String? search,
  });

  Future<EventDetailResponse> getEventDetail(int id);

  Future<Attendant> joinEvent(String eventToken);
}

class EventListResult {
  const EventListResult({
    required this.events,
    required this.counters,
    required this.hasNext,
    required this.totalPages,
    required this.currentPage,
  });

  final List<Event> events;
  final EventCounters counters;
  final bool hasNext;
  final int totalPages;
  final int currentPage;
}
