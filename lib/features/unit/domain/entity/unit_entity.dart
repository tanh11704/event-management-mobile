class UnitEntity {
  UnitEntity({
    required this.id,
    required this.unitName,
    required this.unitType,
    this.parentId,
    this.parentName,
  });

  final int id;
  final String unitName;
  final String unitType;
  final int? parentId;
  final String? parentName;
}
