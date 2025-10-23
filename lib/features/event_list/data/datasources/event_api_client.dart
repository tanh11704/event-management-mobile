import 'package:dio/dio.dart';
import 'package:event_management/features/event_list/data/models/event_page_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'event_api_client.g.dart';

@RestApi()
abstract class EventApiClient {
  factory EventApiClient(Dio dio, {String baseUrl}) = _EventApiClient;

  @GET('/events')
  Future<EventPageResponseModel> getAllEvents({
    @Query('page') int page = 0,
    @Query('size') int size = 12,
    @Query('sortBy') String sortBy = 'startTime',
    @Query('sortDir') String sortDir = 'asc',
    @Query('status') String? status,
    @Query('search') String? search,
  });
}
