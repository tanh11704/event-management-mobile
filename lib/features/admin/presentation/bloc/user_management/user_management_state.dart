import 'package:equatable/equatable.dart';
import 'package:event_management/features/admin/domain/entity/role_entity.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {
  const UserManagementInitial();
}

class UserManagementLoading extends UserManagementState {
  const UserManagementLoading();
}

class UserManagementSuccess extends UserManagementState {
  const UserManagementSuccess({required this.users, this.roles});

  final List<UserEntity> users;
  final List<RoleEntity>? roles;

  UserManagementSuccess copyWith({
    List<UserEntity>? users,
    List<RoleEntity>? roles,
  }) {
    return UserManagementSuccess(
      users: users ?? this.users,
      roles: roles ?? this.roles,
    );
  }

  @override
  List<Object?> get props => [users, roles];
}

class UserManagementFailure extends UserManagementState {
  const UserManagementFailure(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
