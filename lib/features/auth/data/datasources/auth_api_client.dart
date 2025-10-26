import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/models/login_dto.dart';
import 'package:event_management/features/auth/data/models/login_response.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginDto loginDto);
}
