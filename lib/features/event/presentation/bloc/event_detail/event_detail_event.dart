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

class EventDetailUnjoin extends EventDetailEvent {
  const EventDetailUnjoin({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class EventDetailUpdate extends EventDetailEvent {
  const EventDetailUpdate({
    required this.eventId,
    required this.eventDto,
    this.bannerFile,
  });

  final int eventId;
  final dynamic eventDto; // EventDto
  final dynamic bannerFile; // XFile?

  @override
  List<Object?> get props => [eventId, eventDto, bannerFile];
}

class EventDetailImportParticipants extends EventDetailEvent {
  const EventDetailImportParticipants({
    required this.eventId,
    required this.file,
  });

  final int eventId;
  final dynamic file; // XFile

  @override
  List<Object?> get props => [eventId, file];
}

class EventDetailExportParticipants extends EventDetailEvent {
  const EventDetailExportParticipants({
    required this.eventId,
    this.filter = 'all',
  });

  final int eventId;
  final String filter;

  @override
  List<Object?> get props => [eventId, filter];
}
