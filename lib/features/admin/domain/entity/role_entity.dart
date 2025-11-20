import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable {
  const RoleEntity({required this.id, required this.roleName});

  final int id;
  final String roleName;

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

  @override
  List<Object> get props => [id, roleName];
}
