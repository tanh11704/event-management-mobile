import 'package:event_management/features/admin/data/models/role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'role_dto.g.dart';

@JsonSerializable()
class RoleDto {
  const RoleDto({required this.id, required this.roleName});

  factory RoleDto.fromJson(Map<String, dynamic> json) =>
      _$RoleDtoFromJson(json);

  final int id;

  @JsonKey(name: 'role_name')
  final String roleName;

  Role toRole() {
    switch (roleName) {
      case 'ROLE_ADMIN':
        return Role.ROLE_ADMIN;
      case 'ROLE_MANAGER':
        return Role.ROLE_MANAGER;
      case 'ROLE_USER':
        return Role.ROLE_USER;
      default:
        throw ArgumentError('Unknown role: $roleName');
    }
  }

  Map<String, dynamic> toJson() => _$RoleDtoToJson(this);
}
