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
}
