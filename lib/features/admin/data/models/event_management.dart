import 'package:json_annotation/json_annotation.dart';

enum EventManagement {
  @JsonValue('MANAGE')
  manage,
  @JsonValue('STAFF')
  staff,
}

extension EventManagementExtension on EventManagement {
  String get value {
    switch (this) {
      case EventManagement.manage:
        return 'MANAGE';
      case EventManagement.staff:
        return 'STAFF';
    }
  }
}
