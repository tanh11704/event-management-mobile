import 'package:dio/dio.dart';
import 'package:event_management/features/event/data/models/event_page_with_counters_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'event_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class EventApiClient {
  @factoryMethod
  factory EventApiClient(Dio dio) = _EventApiClient;

  @GET('/events')
  Future<EventPageWithCountersResponseDto> getAllEvents({
    @Query('page') int page = 0,
    @Query('size') int size = 12,
    @Query('sortBy') String sortBy = 'startTime',
    @Query('sortDir') String sortDir = 'asc',
    @Query('status') String? status,
    @Query('search') String? search,
  });

  @GET('/events/managed')
  Future<EventPageWithCountersResponseDto> getManagedEvents({
    @Query('page') int page = 0,
    @Query('size') int size = 12,
    @Query('sortBy') String sortBy = 'startTime',
    @Query('sortDir') String sortDir = 'asc',
    @Query('status') String? status,
    @Query('search') String? search,
  });
}
