import 'package:event_management/features/unit/data/model/unit_type.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_response_dto.g.dart';

@JsonSerializable()
class UnitResponseDto {
  UnitResponseDto({
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
  final UnitType unitType;

  @JsonKey(name: 'parent_id')
  final int? parentId;

  @JsonKey(name: 'parent_name')
  final String? parentName;

  Map<String, dynamic> toJson() => _$UnitResponseDtoToJson(this);

  static UnitEntity toEntity(UnitResponseDto dto) {
    return UnitEntity(
      id: dto.id,
      unitName: dto.unitName,
      unitType: dto.unitType.name,
      parentId: dto.parentId,
      parentName: dto.parentName,
    );
  }

  static List<UnitEntity> toEntities(List<UnitResponseDto> dtoList) {
    return dtoList.map(UnitResponseDto.toEntity).toList();
  }
}
