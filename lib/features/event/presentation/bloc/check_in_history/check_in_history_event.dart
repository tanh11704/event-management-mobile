import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/data/models/participant.dart';

/// Events for Check-in History BLoC.
abstract class CheckInHistoryEvent extends Equatable {
  const CheckInHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize check-in history with participants list.
class CheckInHistoryInitialize extends CheckInHistoryEvent {
  const CheckInHistoryInitialize({
    required this.eventId,
    required this.participants,
  });

  final int eventId;
  final List<ParticipantInfo> participants;

  @override
  List<Object?> get props => [eventId, participants];
}

/// Event when SSE receives a check-in notification.
class CheckInHistorySseCheckInReceived extends CheckInHistoryEvent {
  const CheckInHistorySseCheckInReceived({required this.participant});

  final ParticipantInfo participant;

  @override
  List<Object?> get props => [participant];
}

/// Event to refresh check-in history.
class CheckInHistoryRefresh extends CheckInHistoryEvent {
  const CheckInHistoryRefresh({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

/// Event to update connection status.
class CheckInHistoryConnectionStatusChanged extends CheckInHistoryEvent {
  const CheckInHistoryConnectionStatusChanged({required this.isConnected});

  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}

/// Event to disconnect SSE.
class CheckInHistoryDispose extends CheckInHistoryEvent {
  const CheckInHistoryDispose();

  @override
  List<Object?> get props => [];
}
