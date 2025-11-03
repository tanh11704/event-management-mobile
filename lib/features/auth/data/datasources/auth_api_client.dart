import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/login_dto.dart';
import 'package:event_management/features/auth/data/models/login_response.dart';
import 'package:event_management/features/auth/data/models/message_response.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/data/models/reset_password_dto.dart';
import 'package:event_management/features/auth/data/models/user_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginDto loginDto);

  @POST('/auth/refresh-token')
  Future<LoginResponse> refreshToken(
    @Header('X-Refresh-Token') String refreshToken,
  );

  @POST('/auth/logout')
  Future<MessageResponse> logout(
    @Header('X-Refresh-Token') String refreshToken,
  );

  @POST('/auth/register')
  Future<MessageResponse> register(
    @Body() RegisterRequestDto registerRequestDto,
  );

  @POST('/auth/change-password')
  Future<MessageResponse> changePassword(
    @Body() ChangePasswordRequestDto changePasswordRequestDto,
  );

  @POST('/auth/forgot-password')
  Future<MessageResponse> forgotPassword(@Body() Map<String, String> request);

  @POST('/auth/reset-password')
  Future<MessageResponse> resetPassword(
    @Body() ResetPasswordDto resetPasswordDto,
  );

  @GET('/auth/auth-user')
  Future<UserResponseDto> getAuthUser();
}
