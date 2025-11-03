import 'package:json_annotation/json_annotation.dart';

part 'reset_password_dto.g.dart';

@JsonSerializable()
class ResetPasswordDto {
  const ResetPasswordDto({required this.token, required this.newPassword});

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);

  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'new_password')
  final String newPassword;

  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);
}
