import 'package:event_management/features/admin/domain/repositories/admin_repository.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_event.dart';
import 'package:event_management/features/admin/presentation/bloc/user_management/user_management_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  UserManagementBloc({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(const UserManagementInitial()) {
    on<UserManagementFetchAll>(_onFetchAll);
    on<UserManagementRefresh>(_onRefresh);
    on<UserManagementFetchRoles>(_onFetchRoles);
    on<UserManagementUpdateRole>(_onUpdateRole);
  }

  final AdminRepository _adminRepository;

  Future<void> _onFetchAll(
    UserManagementFetchAll event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    try {
      final users = await _adminRepository.getAllUsers();
      emit(UserManagementSuccess(users: users));
    } catch (e) {
      emit(UserManagementFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(
    UserManagementRefresh event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    try {
      final users = await _adminRepository.getAllUsers();
      emit(UserManagementSuccess(users: users));
    } catch (e) {
      emit(UserManagementFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFetchRoles(
    UserManagementFetchRoles event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    try {
      final roles = await _adminRepository.getAllRoles();
      if (currentState is UserManagementSuccess) {
        emit(currentState.copyWith(roles: roles));
      } else {
        emit(UserManagementSuccess(users: const [], roles: roles));
      }
    } catch (e) {
      if (currentState is UserManagementSuccess) {
        // Giữ nguyên state hiện tại, không emit error
        // Dialog sẽ hiển thị error từ state.roles == null
      } else {
        emit(
          UserManagementFailure(e.toString().replaceFirst('Exception: ', '')),
        );
      }
    }
  }

  Future<void> _onUpdateRole(
    UserManagementUpdateRole event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserManagementSuccess) return;

    try {
      await _adminRepository.updateUserRole(event.userId, event.roleId);
      final users = await _adminRepository.getAllUsers();
      emit(currentState.copyWith(users: users));
    } catch (e) {
      emit(UserManagementFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
