import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({
    required this.email,
    required this.password,
    this.shouldRemember = false,
  });

  final String email;
  final String password;
  final bool shouldRemember;

  @override
  List<Object> get props => [email, password, shouldRemember];
}

class LoginWithBiometric extends LoginEvent {
  const LoginWithBiometric();
}

class LoginCheckBiometricAvailability extends LoginEvent {
  const LoginCheckBiometricAvailability();
}
