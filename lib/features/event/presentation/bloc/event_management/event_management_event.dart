import 'package:equatable/equatable.dart';

abstract class EventManagementEvent extends Equatable {
  const EventManagementEvent();

  @override
  List<Object?> get props => [];
}

class EventManagementGetQrCheck extends EventManagementEvent {
  const EventManagementGetQrCheck({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class EventManagementRefreshQrCheck extends EventManagementEvent {
  const EventManagementRefreshQrCheck({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}
