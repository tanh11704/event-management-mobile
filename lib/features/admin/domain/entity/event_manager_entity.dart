import 'package:equatable/equatable.dart';

class EventManagerEntity extends Equatable {
  const EventManagerEntity({
    required this.eventId,
    required this.userId,
    required this.roleType,
    this.assignedBy,
  });

  final int eventId;
  final int userId;
  final String roleType;
  final int? assignedBy;

  @override
  List<Object?> get props => [eventId, userId, roleType, assignedBy];
}
