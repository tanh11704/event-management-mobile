import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/login_dto.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepositoryImpl)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authApiClient, this._secureStorage);

  final AuthApiClient _authApiClient;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<String> register(RegisterRequestDto registerRequestDto) async {
    try {
      final response = await _authApiClient.register(registerRequestDto);

      return response;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  @override
  Future<String> changePassword(
    ChangePasswordRequestDto changePasswordRequestDto,
  ) {
    return _authApiClient.changePassword(changePasswordRequestDto);
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final loginDto = LoginDto(email: email, password: password);
      final response = await _authApiClient.login(loginDto);

      await _secureStorage.write(
        key: 'access_token',
        value: response.accessToken,
      );
      await _secureStorage.write(
        key: 'refresh_token',
        value: response.refreshToken,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Xác thực thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }
}
