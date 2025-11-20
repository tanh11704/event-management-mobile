import 'package:json_annotation/json_annotation.dart';

enum UnitType {
  @JsonValue('DEPARTMENT')
  department,

  @JsonValue('EXTERNAL')
  external,

  @JsonValue('STUDENT')
  student,
}

extension UnitTypeExtension on UnitType {
  String get displayName {
    switch (this) {
      case UnitType.department:
        return 'Phòng/Khoa/Ban';
      case UnitType.external:
        return 'Ngoại vi';
      case UnitType.student:
        return 'Sinh viên';
    }
  }
}
