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
