import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST('/auth/register')
  Future<String> register(@Body() RegisterRequestDto registerRequestDto);
}
