import 'package:json_annotation/json_annotation.dart';

enum Role {
  @JsonValue('ROLE_ADMIN')
  ROLE_ADMIN,

  @JsonValue('ROLE_MANAGER')
  ROLE_MANAGER,

  @JsonValue('ROLE_USER')
  ROLE_USER,
}

extension RoleExtension on Role {
  String get displayName {
    switch (this) {
      case Role.ROLE_ADMIN:
        return 'Quản trị viên';
      case Role.ROLE_MANAGER:
        return 'Quản lý';
      case Role.ROLE_USER:
        return 'Người dùng';
    }
  }
}
