import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/shared/data/models/event_manager_info.dart';

/// States for Secretary Management BLoC.
abstract class SecretaryManagementState extends Equatable {
  const SecretaryManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class SecretaryManagementInitial extends SecretaryManagementState {}

/// Loading state when fetching or performing operations.
class SecretaryManagementLoading extends SecretaryManagementState {
  const SecretaryManagementLoading({this.isRefreshing = false});

  final bool isRefreshing;

  @override
  List<Object?> get props => [isRefreshing];
}

/// Success state with list of event managers.
class SecretaryManagementSuccess extends SecretaryManagementState {
  const SecretaryManagementSuccess({
    required this.eventManagers,
    this.staffOnly = false,
  });

  final List<EventManagerInfo> eventManagers;
  final bool staffOnly;

  /// Gets only staff members (secretaries).
  List<EventManagerInfo> get staffMembers =>
      eventManagers.where((m) => m.isStaff).toList();

  /// Gets only managers.
  List<EventManagerInfo> get managers =>
      eventManagers.where((m) => m.isManager).toList();

  @override
  List<Object?> get props => [eventManagers, staffOnly];

  SecretaryManagementSuccess copyWith({
    List<EventManagerInfo>? eventManagers,
    bool? staffOnly,
  }) {
    return SecretaryManagementSuccess(
      eventManagers: eventManagers ?? this.eventManagers,
      staffOnly: staffOnly ?? this.staffOnly,
    );
  }
}

/// Error state.
class SecretaryManagementError extends SecretaryManagementState {
  const SecretaryManagementError({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

/// Success state for assign operation.
class SecretaryManagementAssignSuccess extends SecretaryManagementState {
  const SecretaryManagementAssignSuccess({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

/// Success state for remove operation.
class SecretaryManagementRemoveSuccess extends SecretaryManagementState {
  const SecretaryManagementRemoveSuccess({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
