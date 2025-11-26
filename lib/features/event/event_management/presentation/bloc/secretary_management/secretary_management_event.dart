import 'package:equatable/equatable.dart';

/// Events for Secretary Management BLoC.
abstract class SecretaryManagementEvent extends Equatable {
  const SecretaryManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch event managers (including secretaries/staff).
class SecretaryManagementFetchEventManagers extends SecretaryManagementEvent {
  const SecretaryManagementFetchEventManagers({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

/// Event to assign a secretary (STAFF role) to an event.
class SecretaryManagementAssignSecretary extends SecretaryManagementEvent {
  const SecretaryManagementAssignSecretary({
    required this.eventId,
    required this.userId,
    required this.assignedBy,
  });

  final int eventId;
  final int userId;
  final int assignedBy;

  @override
  List<Object?> get props => [eventId, userId, assignedBy];
}

/// Event to remove a secretary from an event.
class SecretaryManagementRemoveSecretary extends SecretaryManagementEvent {
  const SecretaryManagementRemoveSecretary({
    required this.eventId,
    required this.userId,
  });

  final int eventId;
  final int userId;

  @override
  List<Object?> get props => [eventId, userId];
}

class SecretaryManagementRefresh extends SecretaryManagementEvent {
  const SecretaryManagementRefresh({required this.eventId});

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}
