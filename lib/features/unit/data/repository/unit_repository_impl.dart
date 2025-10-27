import 'package:event_management/features/unit/data/datasource/unit_api_client.dart';
import 'package:event_management/features/unit/data/model/unit_response_dto.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UnitRepository)
class UnitRepositoryImpl implements UnitRepository {
  UnitRepositoryImpl(this._apiClient);
  final UnitApiClient _apiClient;

  @override
  Future<List<UnitEntity>> getUnits(int page, int size) async {
    final response = await _apiClient.getUnits(page: page, size: size);
    return UnitResponseDto.toEntities(response.content);
  }
}
