import 'package:equatable/equatable.dart';
import 'package:event_management/features/unit/domain/entities/unit_type.dart';

class UnitEntity extends Equatable {
  const UnitEntity({
    required this.id,
    required this.unitName,
    required this.unitType,
    this.parentId,
    this.parentName,
  });

  final int id;
  final String unitName;
  final UnitType unitType;
  final int? parentId;
  final String? parentName;

  @override
  List<Object?> get props => [id, unitName, unitType, parentId, parentName];

  UnitEntity copyWith({
    int? id,
    String? unitName,
    UnitType? unitType,
    int? parentId,
    String? parentName,
  }) {
    return UnitEntity(
      id: id ?? this.id,
      unitName: unitName ?? this.unitName,
      unitType: unitType ?? this.unitType,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
    );
  }
}
