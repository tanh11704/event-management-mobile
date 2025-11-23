import 'package:equatable/equatable.dart';
import 'package:event_management/features/admin/domain/entity/role_entity.dart';
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
  final List<RoleEntity>? roles;

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
