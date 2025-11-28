import 'package:dio/dio.dart';
import 'package:event_management/features/event/shared/data/models/attendant.dart';
import 'package:event_management/features/event/shared/data/models/chat_request.dart';
import 'package:event_management/features/event/shared/data/models/chat_response.dart';
import 'package:event_management/features/event/shared/data/models/create_event_dto.dart';
import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/event/shared/data/models/event_dto.dart';
import 'package:event_management/features/event/shared/data/models/event_manager_dto.dart';
import 'package:event_management/features/event/shared/data/models/event_page_with_counters_response_dto.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_request.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_response.dart';
import 'package:event_management/features/event/shared/data/models/image_upload_response.dart';
import 'package:event_management/features/event/shared/data/models/import_job_response.dart';
import 'package:event_management/features/event/shared/data/models/import_participants_response.dart';
import 'package:event_management/features/event/shared/data/models/message_dto.dart';
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

  @PUT('/events/{id}')
  Future<Event> updateEvent(@Path('id') int eventId, @Body() EventDto eventDto);

  @PUT('/events/{id}/upload-banner')
  @MultiPart()
  Future<Event> uploadBanner(
    @Path('id') int eventId,
    @Part(name: 'banner') MultipartFile bannerFile,
  );

  @POST('/attendants/{eventId}/import')
  @MultiPart()
  Future<ImportParticipantsResponse> importParticipants(
    @Path('eventId') int eventId,
    @Part(name: 'file') MultipartFile file, {
    @SendProgress() ProgressCallback? onSendProgress,
  });

  @GET('/attendants/import/{jobId}')
  Future<ImportJobResponse> getImportJobStatus(@Path('jobId') int jobId);

  @POST('/medias/image-upload')
  @MultiPart()
  Future<ImageUploadResponse> uploadImage(
    @Part(name: 'image') MultipartFile imageFile,
  );

  @GET('/attendants/get-qr-check/{eventId}')
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> getQrCheck(@Path('eventId') int eventId);

  @POST('/attendants/check-in/{eventToken}')
  Future<Attendant> checkInEvent(@Path('eventToken') String eventToken);

  @GET('/event-manager/event-managers')
  Future<List<EventManagerDto>> getEventManagersByEventId({
    @Query('eventId') required int eventId,
  });

  @POST('/events/generate-description')
  Future<GenerateDescriptionResponse> generateDescription(
    @Body() GenerateDescriptionRequest request,
  );

  @POST('/chats/send')
  Future<ChatResponse> sendChatMessage(@Body() ChatRequest request);

  @GET('/chats/history/{eventId}')
  Future<List<MessageDto>> getChatHistory(@Path('eventId') int eventId);
}
