import 'package:dio/dio.dart';
import 'package:event_management/features/unit/data/model/unit_page_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'unit_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class UnitApiClient {
  @factoryMethod
  factory UnitApiClient(Dio dio) = _UnitApiClient;

  @GET('/units')
  Future<UnitPageResponseDto> getUnits({
    @Query('page') int page = 0,
    @Query('size') int size = 1000,
  });
}
