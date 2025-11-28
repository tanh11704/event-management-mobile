/// Loại đơn vị
enum UnitType {
  department('DEPARTMENT', 'Phòng ban'),
  student('STUDENT', 'Sinh viên'),
  external('EXTERNAL', 'Bên ngoài');

  const UnitType(this.value, this.label);

  final String value;
  final String label;

  static UnitType? fromString(String? value) {
    if (value == null) return null;
    try {
      return UnitType.values.firstWhere(
        (type) => type.value == value.toUpperCase(),
      );
    } catch (e) {
      return UnitType.department;
    }
  }
}
