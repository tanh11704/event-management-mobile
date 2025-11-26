import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/shared/data/models/event_counters.dart';

abstract class EventListState extends Equatable {
  const EventListState();

  @override
  List<Object?> get props => [];
}

class EventListInitial extends EventListState {}

class EventListLoading extends EventListState {
  const EventListLoading({this.joiningEventToken});

  final String? joiningEventToken;

  @override
  List<Object?> get props => [joiningEventToken];
}

class EventListLoaded extends EventListState {
  const EventListLoaded({
    required this.events,
    required this.counters,
    required this.hasNextPage,
  });

  final List<Event> events;
  final EventCounters counters;
  final bool hasNextPage;

  @override
  List<Object?> get props => [events, counters, hasNextPage];

  EventListLoaded copyWith({
    List<Event>? events,
    EventCounters? counters,
    bool? hasNextPage,
  }) {
    return EventListLoaded(
      events: events ?? this.events,
      counters: counters ?? this.counters,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class EventListEmpty extends EventListState {
  const EventListEmpty({required this.counters});

  final EventCounters counters;

  @override
  List<Object> get props => [counters];
}

class EventListError extends EventListState {
  const EventListError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

class EventListJoinSuccess extends EventListState {
  const EventListJoinSuccess();

  @override
  List<Object> get props => [];
}

class EventListJoinError extends EventListState {
  const EventListJoinError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
