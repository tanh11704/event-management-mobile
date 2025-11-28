import 'package:dio/dio.dart';
import 'package:event_management/features/unit/data/model/page_response.dart';
import 'package:event_management/features/unit/data/model/unit_request_dto.dart';
import 'package:event_management/features/unit/data/model/unit_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'unit_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class UnitApiClient {
  @factoryMethod
  factory UnitApiClient(Dio dio) = _UnitApiClient;

  @GET('/units')
  Future<PageResponse<UnitResponseDto>> listUnits({
    @Query('q') String? query,
    @Query('page') int page = 0,
    @Query('size') int size = 20,
  });

  @GET('/units/all')
  Future<List<UnitResponseDto>> getAllUnits();

  @GET('/units/{id}')
  Future<UnitResponseDto> getUnit(@Path('id') int id);

  @POST('/units')
  Future<UnitResponseDto> createUnit(@Body() UnitRequestDto dto);

  @PUT('/units/{id}')
  Future<UnitResponseDto> updateUnit(
    @Path('id') int id,
    @Body() UnitRequestDto dto,
  );

  @DELETE('/units/{id}')
  Future<void> deleteUnit(@Path('id') int id);
}
