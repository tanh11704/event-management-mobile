import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    this.unitId,
  });
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final int? unitId;

  @override
  List<Object?> get props => [
    name,
    email,
    phoneNumber,
    password,
    confirmPassword,
    unitId,
  ];
}
