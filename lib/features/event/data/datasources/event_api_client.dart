import 'package:dio/dio.dart';
import 'package:event_management/features/event/data/models/attendant.dart';
import 'package:event_management/features/event/data/models/create_event_dto.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/event_dto.dart';
import 'package:event_management/features/event/data/models/event_page_with_counters_response_dto.dart';
import 'package:event_management/features/event/data/models/image_upload_response.dart';
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

  @GET('/events/{id}')
  Future<EventDetailResponse> getEventDetail(@Path('id') int id);

  @POST('/events/join/{eventToken}')
  Future<Attendant> joinEvent(@Path('eventToken') String eventToken);

  @DELETE('/attendants/my-registration/{eventId}')
  Future<void> unjoinEvent(@Path('eventId') int eventId);

  @POST('/events')
  Future<Event> createEvent(@Body() CreateEventDto createEventDto);

  @PUT('/events/{id}/upload-banner')
  @MultiPart()
  Future<Event> uploadBanner(
    @Path('id') int eventId,
    @Part(name: 'banner') MultipartFile bannerFile,
  );

  @PUT('/events/{eventId}')
  Future<Event> updateEvent(
    @Path('eventId') int eventId,
    @Body() EventDto eventDto,
  );

  @POST('/events/{eventId}/import')
  @MultiPart()
  Future<void> importParticipants(
    @Path('eventId') int eventId,
    @Part(name: 'file') MultipartFile file,
  );

  @POST('/medias/image-upload')
  @MultiPart()
  Future<ImageUploadResponse> uploadImage(
    @Part(name: 'image') MultipartFile imageFile,
  );
}
