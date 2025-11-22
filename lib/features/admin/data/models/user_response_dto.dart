import 'package:event_management/features/admin/data/models/role_dto.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:event_management/features/unit/data/model/unit_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserResponseDto {
  const UserResponseDto({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.enabled,
    this.unit,
    this.roles,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    final rolesJson = json['roles'] as List<dynamic>?;
    final roles = rolesJson?.map((e) {
      if (e is Map<String, dynamic>) {
        return RoleDto.fromJson(e);
      }
      return RoleDto.fromJson({'id': 0, 'role_name': e.toString()});
    }).toList();

    return UserResponseDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      enabled: json['enabled'] as bool?,
      unit: json['unit'] == null
          ? null
          : UnitResponseDto.fromJson(json['unit'] as Map<String, dynamic>),
      roles: roles,
    );
  }

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'enabled')
  final bool? enabled;

  @JsonKey(name: 'unit')
  final UnitResponseDto? unit;

  @JsonKey(includeToJson: false, includeFromJson: false)
  final List<RoleDto>? roles;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'enabled': enabled,
      'unit': unit?.toJson(),
      'roles': roles?.map((role) => role.toJson()).toList(),
    };
  }

  static UserEntity toEntity(UserResponseDto dto) {
    return UserEntity(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      enabled: dto.enabled,
      unit: dto.unit != null ? UnitResponseDto.toEntity(dto.unit!) : null,
      roles: dto.roles?.map(RoleDto.toEntity).toList(),
    );
  }

  static List<UserEntity> toEntities(List<UserResponseDto> dtoList) {
    return dtoList.map(UserResponseDto.toEntity).toList();
  }
}
