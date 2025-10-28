// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitResponseDto _$UnitResponseDtoFromJson(Map<String, dynamic> json) =>
    UnitResponseDto(
      id: (json['id'] as num).toInt(),
      unitName: json['unit_name'] as String,
      unitType: json['unit_type'] as String,
      parentId: (json['parent_id'] as num?)?.toInt(),
      parentName: json['parent_name'] as String?,
    );

Map<String, dynamic> _$UnitResponseDtoToJson(UnitResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit_name': instance.unitName,
      'unit_type': instance.unitType,
      'parent_id': instance.parentId,
      'parent_name': instance.parentName,
    };
