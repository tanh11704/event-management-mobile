import 'package:dio/dio.dart';
import 'package:event_management/features/poll/data/models/create_poll_dto.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';
import 'package:event_management/features/poll/data/models/poll_stats_response.dart';
import 'package:event_management/features/poll/data/models/update_poll_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'poll_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class PollApiClient {
  @factoryMethod
  factory PollApiClient(Dio dio) = _PollApiClient;

  @POST('/polls')
  Future<PollResponse> createPoll(@Body() CreatePollDto pollDto);

  @GET('/polls/{pollId}')
  Future<PollResponse> getPoll(@Path('pollId') int pollId);

  @GET('/polls/events/{eventId}')
  Future<List<PollResponse>> getPollsByEvent(@Path('eventId') int eventId);

  @GET('/polls/events/{eventId}/stats')
  Future<List<PollStatsResponse>> getPollStatsByEvent(
    @Path('eventId') int eventId,
  );

  @PUT('/polls/{pollId}/close')
  Future<PollResponse> closePoll(@Path('pollId') int pollId);

  @PUT('/polls/{pollId}')
  Future<PollResponse> updatePoll(
    @Path('pollId') int pollId,
    @Body() UpdatePollDto updatePollDto,
  );
}
