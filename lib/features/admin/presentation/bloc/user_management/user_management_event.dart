import 'package:equatable/equatable.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object> get props => [];
}

class UserManagementFetchAll extends UserManagementEvent {
  const UserManagementFetchAll();
}

class UserManagementRefresh extends UserManagementEvent {
  const UserManagementRefresh();
}

class UserManagementFetchRoles extends UserManagementEvent {
  const UserManagementFetchRoles();
}

class UserManagementUpdateRole extends UserManagementEvent {
  const UserManagementUpdateRole({required this.userId, required this.roleId});

  final int userId;
  final int roleId;

  @override
  List<Object> get props => [userId, roleId];
}
