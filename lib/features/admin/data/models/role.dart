import 'package:json_annotation/json_annotation.dart';

enum Role {
  @JsonValue('ADMIN')
  admin,

  @JsonValue('MANAGER')
  manager,

  @JsonValue('USER')
  user,
}

extension RoleExtension on Role {
  String get displayName {
    switch (this) {
      case Role.admin:
        return 'Quản trị viên';
      case Role.manager:
        return 'Quản lý';
      case Role.user:
        return 'Người dùng';
    }
  }
}
