// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordRequestDto _$ChangePasswordRequestDtoFromJson(
  Map<String, dynamic> json,
) => ChangePasswordRequestDto(
  oldPassword: json['old_password'] as String,
  newPassword: json['new_password'] as String,
  confirmPassword: json['confirm_password'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestDtoToJson(
  ChangePasswordRequestDto instance,
) => <String, dynamic>{
  'old_password': instance.oldPassword,
  'new_password': instance.newPassword,
  'confirm_password': instance.confirmPassword,
};
