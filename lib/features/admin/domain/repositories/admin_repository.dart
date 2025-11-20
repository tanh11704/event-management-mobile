import 'package:event_management/features/admin/domain/entity/role_entity.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';

abstract class AdminRepository {
  Future<List<UserEntity>> getAllUsers();

  Future<List<RoleEntity>> getAllRoles();

  Future<UserEntity> updateUserRole(int userId, int roleId);
}
