// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitRequestDto _$UnitRequestDtoFromJson(Map<String, dynamic> json) =>
    UnitRequestDto(
      unitName: json['unit_name'] as String,
      unitType: const UnitTypeConverter().fromJson(json['unit_type'] as String),
      parentId: (json['parent_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UnitRequestDtoToJson(UnitRequestDto instance) =>
    <String, dynamic>{
      'unit_name': instance.unitName,
      'unit_type': const UnitTypeConverter().toJson(instance.unitType),
      'parent_id': instance.parentId,
    };
