// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitResponseDto _$UnitResponseDtoFromJson(Map<String, dynamic> json) =>
    UnitResponseDto(
      id: (json['id'] as num).toInt(),
      unitName: json['unit_name'] as String,
      unitType: $enumDecode(_$UnitTypeEnumMap, json['unit_type']),
      parentId: (json['parent_id'] as num?)?.toInt(),
      parentName: json['parent_name'] as String?,
    );

Map<String, dynamic> _$UnitResponseDtoToJson(UnitResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit_name': instance.unitName,
      'unit_type': _$UnitTypeEnumMap[instance.unitType]!,
      'parent_id': instance.parentId,
      'parent_name': instance.parentName,
    };

const _$UnitTypeEnumMap = {
  UnitType.department: 'DEPARTMENT',
  UnitType.external: 'EXTERNAL',
  UnitType.student: 'STUDENT',
};
