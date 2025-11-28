import 'package:event_management/features/unit/domain/entities/unit_type.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter để serialize/deserialize UnitType enum
class UnitTypeConverter implements JsonConverter<UnitType, String> {
  const UnitTypeConverter();

  @override
  UnitType fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'DEPARTMENT':
        return UnitType.department;
      case 'STUDENT':
        return UnitType.student;
      case 'EXTERNAL':
        return UnitType.external;
      default:
        return UnitType.department;
    }
  }

  @override
  String toJson(UnitType object) {
    return object.value;
  }
}
