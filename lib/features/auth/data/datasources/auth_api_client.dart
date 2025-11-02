import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/forgot_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/login_dto.dart';
import 'package:event_management/features/auth/data/models/login_response.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  @POST('/auth/register')
  Future<String> register(@Body() RegisterRequestDto registerRequestDto);

  @POST('/auth/change-password')
  Future<String> changePassword(
    @Body() ChangePasswordRequestDto changePasswordRequestDto,
  );

  @POST('/auth/login')
  Future<LoginResponse> login(@Body() LoginDto loginDto);

  @POST('/auth/forgot-password')
  Future<String> forgotPassword(
    @Body() ForgotPasswordRequestDto forgotPasswordRequestDto,
  );
}
