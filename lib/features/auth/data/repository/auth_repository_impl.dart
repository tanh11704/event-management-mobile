import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/forgot_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/login_dto.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
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
  Future<String> forgotPassword(
    ForgotPasswordRequestDto forgotPasswordRequestDto,
  ) async {
    try {
      final response = await _authApiClient.forgotPassword(
        forgotPasswordRequestDto,
      );
      return response;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(
          errorMessage ?? 'Không thể gửi yêu cầu đặt lại mật khẩu.',
        );
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
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
      if (response.refreshToken != null) {
        await _secureStorage.write(
          key: 'refresh_token',
          value: response.refreshToken,
        );
      }
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

  @override
  Future<void> refreshToken() async {
    try {
      final refreshTokenValue = await _secureStorage.read(key: 'refresh_token');
      if (refreshTokenValue == null) {
        throw Exception('Không có refresh token');
      }

      final response = await _authApiClient.refreshToken(refreshTokenValue);

      await _secureStorage.write(
        key: 'access_token',
        value: response.accessToken,
      );
      if (response.refreshToken != null) {
        await _secureStorage.write(
          key: 'refresh_token',
          value: response.refreshToken,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Làm mới token thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshTokenValue = await _secureStorage.read(key: 'refresh_token');
      if (refreshTokenValue != null) {
        try {
          await _authApiClient.logout(refreshTokenValue);
        } catch (e) {
          // Ignore logout API errors, just clear local storage
        }
      }
    } catch (e) {
      // Ignore errors during logout
    } finally {
      // Always clear local storage
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');
    }
  }
}
