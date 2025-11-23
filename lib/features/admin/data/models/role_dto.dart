import 'package:event_management/features/admin/domain/entity/role_entity.dart';
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

  /// Hiển thị tên vai trò bằng tiếng Việt
  String get displayName {
    switch (roleName) {
      case 'ROLE_ADMIN':
        return 'Quản trị viên';
      case 'ROLE_MANAGER':
        return 'Quản lý';
      case 'ROLE_USER':
        return 'Người dùng';
      default:
        return roleName;
    }
  }

  Map<String, dynamic> toJson() => _$RoleDtoToJson(this);

  static RoleEntity toEntity(RoleDto dto) {
    return RoleEntity(id: dto.id, roleName: dto.roleName);
  }

  static List<RoleEntity> toEntities(List<RoleDto> dtoList) {
    return dtoList.map(RoleDto.toEntity).toList();
  }
}
