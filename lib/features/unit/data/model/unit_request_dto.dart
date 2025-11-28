import 'package:event_management/features/unit/data/model/unit_type_converter.dart';
import 'package:event_management/features/unit/domain/entities/unit_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_request_dto.g.dart';

@JsonSerializable()
class UnitRequestDto {
  const UnitRequestDto({
    required this.unitName,
    required this.unitType,
    this.parentId,
  });

  factory UnitRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UnitRequestDtoFromJson(json);

  @JsonKey(name: 'unit_name')
  final String unitName;

  @JsonKey(name: 'unit_type')
  @UnitTypeConverter()
  final UnitType unitType;

  @JsonKey(name: 'parent_id')
  final int? parentId;

  Map<String, dynamic> toJson() => _$UnitRequestDtoToJson(this);
}
