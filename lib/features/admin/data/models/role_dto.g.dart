// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleDto _$RoleDtoFromJson(Map<String, dynamic> json) => RoleDto(
  id: (json['id'] as num).toInt(),
  roleName: json['role_name'] as String,
);

Map<String, dynamic> _$RoleDtoToJson(RoleDto instance) => <String, dynamic>{
  'id': instance.id,
  'role_name': instance.roleName,
};
