import 'package:bloc/bloc.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/domain/entity/change_password_request.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password_event.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc(this._authRepository) : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }
  final AuthRepository _authRepository;

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());
    try {
      await _authRepository.changePassword(
        ChangePasswordRequestDto.fromEntity(
          ChangePasswordRequest(
            oldPassword: event.oldPassword,
            newPassword: event.newPassword,
            confirmPassword: event.confirmPassword,
          ),
        ),
      );
      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFailure(e.toString()));
    }
  }
}
