import 'package:bloc/bloc.dart';
import 'package:event_management/features/auth/data/models/forgot_password_request_dto.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }
  final AuthRepository _authRepository;

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      final message = await _authRepository.forgotPassword(
        ForgotPasswordRequestDto(email: event.email) as String,
      );
      emit(ForgotPasswordSuccess(message));
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
