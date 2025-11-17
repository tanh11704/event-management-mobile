import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_counters.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<Event> editEvent({
    required int id,
    required String name,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    XFile? newBanner,
  });
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
