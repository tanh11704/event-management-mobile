import 'package:event_management/features/admin/domain/entity/user_entity.dart';

abstract class AdminRepository {
  Future<List<UserEntity>> getAllUsers();
}
