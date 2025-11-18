import 'package:event_management/core/services/biometric_service.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_event.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
    required BiometricService biometricService,
  }) : _authRepository = authRepository,
       _biometricService = biometricService,
       super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithBiometric>(_onLoginWithBiometric);
    on<LoginCheckBiometricAvailability>(_onLoginCheckBiometricAvailability);
  }

  final AuthRepository _authRepository;
  final BiometricService _biometricService;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      await _authRepository.login(email: event.email, password: event.password);

      if (event.shouldRemember) {
        await _authRepository.saveCredentialsForBiometric(
          email: event.email,
          password: event.password,
        );
      } else {
        await _authRepository.clearSavedCredentialsForBiometric();
      }

      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoginWithBiometric(
    LoginWithBiometric event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final isAuthenticated = await _biometricService.authenticate(
        reason: 'Xác thực để đăng nhập vào ứng dụng',
      );

      if (!isAuthenticated) {
        emit(const LoginFailure('Xác thực sinh trắc học thất bại'));
        return;
      }

      final credentials = await _authRepository
          .getSavedCredentialsForBiometric();
      if (credentials == null) {
        emit(const LoginFailure('Không tìm thấy thông tin đăng nhập đã lưu'));
        return;
      }

      // Đăng nhập với credentials đã lưu
      emit(const LoginLoading());
      await _authRepository.login(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoginCheckBiometricAvailability(
    LoginCheckBiometricAvailability event,
    Emitter<LoginState> emit,
  ) async {
    try {
      final isSupported = await _biometricService.isDeviceSupported();
      final canCheck = await _biometricService.canCheckBiometrics();
      final credentials = await _authRepository
          .getSavedCredentialsForBiometric();

      emit(
        LoginBiometricAvailabilityChecked(
          isAvailable: isSupported && canCheck && credentials != null,
          savedEmail: credentials?['email'],
        ),
      );
    } catch (e) {
      emit(const LoginBiometricAvailabilityChecked(isAvailable: false));
    }
  }
}
