import 'package:event_management/features/unit/data/model/page_response.dart';
import 'package:event_management/features/unit/data/model/unit_request_dto.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';

abstract class UnitRepository {
  Future<PageResponse<UnitEntity>> listUnits({
    String? query,
    int page = 0,
    int size = 20,
  });

  Future<List<UnitEntity>> getAllUnits();

  Future<UnitEntity> getUnit(int id);

  Future<UnitEntity> createUnit(UnitRequestDto dto);

  Future<UnitEntity> updateUnit(int id, UnitRequestDto dto);

  Future<void> deleteUnit(int id);
}
