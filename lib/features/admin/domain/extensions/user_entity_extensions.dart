import 'package:event_management/features/admin/domain/entity/user_entity.dart';

extension UserEntityDisplayExtension on UserEntity {
  String get statusText => enabled ?? false ? 'Hoạt động' : 'Đã khóa';

  String get rolesText {
    if (roles == null || roles!.isEmpty) {
      return 'Chưa có';
    }
    return roles!.map((r) => r.displayName).join(', ');
  }

  String get unitName => unit?.unitName ?? 'Chưa có';
}
