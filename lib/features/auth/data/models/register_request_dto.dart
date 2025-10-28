import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

@JsonSerializable()
class RegisterRequestDto {
  RegisterRequestDto({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    this.unitId,
  });

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  @JsonKey(name: 'password')
  final String password;

  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  @JsonKey(name: 'unit_id')
  final int? unitId;

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}
