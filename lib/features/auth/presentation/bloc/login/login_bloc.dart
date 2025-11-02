import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_event.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }
  final AuthRepository _authRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      await _authRepository.login(email: event.email, password: event.password);
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
