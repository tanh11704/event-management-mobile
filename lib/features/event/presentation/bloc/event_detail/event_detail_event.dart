import 'package:equatable/equatable.dart';

abstract class EventDetailEvent extends Equatable {
  const EventDetailEvent();

  @override
  List<Object?> get props => [];
}

class EventDetailFetch extends EventDetailEvent {
  const EventDetailFetch({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class EventDetailJoin extends EventDetailEvent {
  const EventDetailJoin({required this.eventToken});

  final String eventToken;

  @override
  List<Object?> get props => [eventToken];
}
