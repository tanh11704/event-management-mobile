import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

/// State khởi tạo, chưa thực hiện hành động gì.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State đang trong quá trình gọi API đăng nhập.
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// State đăng nhập thành công.
class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// State đăng nhập thất bại với một thông báo lỗi.
class LoginFailure extends LoginState {
  const LoginFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}

class LoginBiometricAvailabilityChecked extends LoginState {
  const LoginBiometricAvailabilityChecked({
    required this.isAvailable,
    this.savedEmail,
  });

  final bool isAvailable;
  final String? savedEmail;

  @override
  List<Object> get props => [isAvailable, savedEmail ?? ''];
}
