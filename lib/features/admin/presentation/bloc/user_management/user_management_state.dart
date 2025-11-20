import 'package:equatable/equatable.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object> get props => [];
}

class UserManagementInitial extends UserManagementState {
  const UserManagementInitial();
}

class UserManagementLoading extends UserManagementState {
  const UserManagementLoading();
}

class UserManagementSuccess extends UserManagementState {
  const UserManagementSuccess({required this.users});

  final List<UserEntity> users;

  @override
  List<Object> get props => [users];
}

class UserManagementFailure extends UserManagementState {
  const UserManagementFailure(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
