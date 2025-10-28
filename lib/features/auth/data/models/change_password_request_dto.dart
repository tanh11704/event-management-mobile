import 'package:event_management/features/auth/domain/entity/change_password_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'change_password_request_dto.g.dart';

@JsonSerializable()
class ChangePasswordRequestDto {
  ChangePasswordRequestDto({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequestDto.fromEntity(
    ChangePasswordRequest changePasswordRequest,
  ) {
    return ChangePasswordRequestDto(
      oldPassword: changePasswordRequest.oldPassword,
      newPassword: changePasswordRequest.newPassword,
      confirmPassword: changePasswordRequest.confirmPassword,
    );
  }

  factory ChangePasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestDtoFromJson(json);

  @JsonKey(name: 'old_password')
  final String oldPassword;

  @JsonKey(name: 'new_password')
  final String newPassword;

  @JsonKey(name: 'confirm_password')
  final String confirmPassword;

  Map<String, dynamic> toJson() => _$ChangePasswordRequestDtoToJson(this);

  static ChangePasswordRequest toEntity(
    ChangePasswordRequestDto changePasswordRequestDto,
  ) {
    return ChangePasswordRequest(
      oldPassword: changePasswordRequestDto.oldPassword,
      newPassword: changePasswordRequestDto.newPassword,
      confirmPassword: changePasswordRequestDto.confirmPassword,
    );
  }
}
