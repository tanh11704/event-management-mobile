import 'package:event_management/features/unit/data/model/unit_type_converter.dart';
import 'package:event_management/features/unit/domain/entities/unit_type.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_response_dto.g.dart';

@JsonSerializable()
class UnitResponseDto {
  const UnitResponseDto({
    required this.id,
    required this.unitName,
    required this.unitType,
    this.parentId,
    this.parentName,
  });

  factory UnitResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UnitResponseDtoFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'unit_name')
  final String unitName;

  @JsonKey(name: 'unit_type')
  @UnitTypeConverter()
  final UnitType unitType;

  @JsonKey(name: 'parent_id')
  final int? parentId;

  @JsonKey(name: 'parent_name')
  final String? parentName;

  Map<String, dynamic> toJson() => _$UnitResponseDtoToJson(this);

  UnitEntity toEntity() {
    return UnitEntity(
      id: id,
      unitName: unitName,
      unitType: unitType,
      parentId: parentId,
      parentName: parentName,
    );
  }

  static UnitEntity toEntityStatic(UnitResponseDto dto) {
    return dto.toEntity();
  }

  static List<UnitEntity> toEntities(List<UnitResponseDto> dtoList) {
    return dtoList.map((dto) => dto.toEntity()).toList();
  }
}
