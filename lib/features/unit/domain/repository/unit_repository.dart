import 'package:event_management/features/unit/domain/entity/unit_entity.dart';

abstract class UnitRepository {
  Future<List<UnitEntity>> getUnits(int page, int size);
}
