import 'package:event_management/features/admin/data/models/event_management.dart';
import 'package:event_management/features/admin/domain/entity/event_manager_entity.dart';
import 'package:event_management/features/admin/domain/entity/role_entity.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';

abstract class AdminRepository {
  Future<List<UserEntity>> getAllUsers();

  Future<List<RoleEntity>> getAllRoles();

  Future<UserEntity> updateUserRole(int userId, int roleId);

  Future<EventManagerEntity> assignEventManager({
    required int eventId,
    required int userId,
    required EventManagement roleType,
    required int? assignedBy,
  });

  Future<void> removeEventManager({
    required int eventId,
    required int userId,
    required EventManagement roleType,
  });
}
