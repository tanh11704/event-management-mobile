import 'package:equatable/equatable.dart';
import 'package:event_management/features/admin/data/models/role.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.enabled,
    this.unit,
    this.roles,
  });

  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool? enabled;
  final UnitEntity? unit;
  final List<Role>? roles;

  String get statusText => enabled == true ? 'Hoạt động' : 'Đã khóa';

  String get rolesText {
    if (roles == null || roles!.isEmpty) {
      return 'Chưa có';
    }
    return roles!.map((r) => r.displayName).join(', ');
  }

  String get unitName => unit?.unitName ?? 'Chưa có';

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        enabled,
        unit,
        roles,
      ];
}

