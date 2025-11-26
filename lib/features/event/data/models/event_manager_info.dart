import 'package:equatable/equatable.dart';
import 'package:event_management/features/admin/data/models/event_management.dart';
import 'package:event_management/features/event/data/models/event_manager_dto.dart';

/// Model representing an event manager with user information.
/// This is used for displaying managers/staff assigned to an event.
class EventManagerInfo extends Equatable {
  const EventManagerInfo({
    required this.eventId,
    required this.userId,
    required this.roleType,
    this.userName,
    this.userEmail,
    this.assignedBy,
  });

  /// Creates EventManagerInfo from DTO and user information.
  factory EventManagerInfo.fromDto({
    required EventManagerDto dto,
    String? userName,
    String? userEmail,
  }) {
    return EventManagerInfo(
      eventId: dto.eventId,
      userId: dto.userId,
      roleType: dto.roleType,
      assignedBy: dto.assignedBy,
      userName: userName,
      userEmail: userEmail,
    );
  }

  final int eventId;
  final int userId;
  final EventManagement roleType;
  final String? userName;
  final String? userEmail;
  final int? assignedBy;

  /// Creates a copy with updated values.
  EventManagerInfo copyWith({
    int? eventId,
    int? userId,
    EventManagement? roleType,
    String? userName,
    String? userEmail,
    int? assignedBy,
  }) {
    return EventManagerInfo(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      roleType: roleType ?? this.roleType,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      assignedBy: assignedBy ?? this.assignedBy,
    );
  }

  bool hasAtLeastRole(EventManagement requiredRole) {
    if (requiredRole == EventManagement.staff) {
      return true;
    }
    if (requiredRole == EventManagement.manage) {
      return roleType == EventManagement.manage;
    }
    return false;
  }

  bool get isStaff => roleType == EventManagement.staff;

  bool get isManager => roleType == EventManagement.manage;

  @override
  List<Object?> get props => [
    eventId,
    userId,
    userName,
    userEmail,
    roleType,
    assignedBy,
  ];
}
