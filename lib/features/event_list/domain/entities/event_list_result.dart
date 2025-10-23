import 'package:equatable/equatable.dart';
import 'package:event_management/features/event_list/domain/entities/event.dart';
import 'package:event_management/features/event_list/domain/entities/event_counters.dart';

class EventListResult extends Equatable {
  const EventListResult({
    required this.events,
    required this.counters,
    required this.hasNextPage,
  });

  final List<Event> events;
  final EventCounters counters;
  final bool hasNextPage;

  @override
  List<Object?> get props => [events, counters, hasNextPage];
}
