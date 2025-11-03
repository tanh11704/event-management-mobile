import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/login_dto.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/data/models/reset_password_dto.dart';
import 'package:event_management/features/auth/data/models/user_response_dto.dart';
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
      return response.message;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Đăng ký thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<String> changePassword(
    ChangePasswordRequestDto changePasswordRequestDto,
  ) async {
    try {
      final response = await _authApiClient.changePassword(
        changePasswordRequestDto,
      );
      return response.message;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Đổi mật khẩu thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _authApiClient.forgotPassword({'email': email});
      return response.message;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Gửi yêu cầu quên mật khẩu thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<String> resetPassword(ResetPasswordDto resetPasswordDto) async {
    try {
      final response = await _authApiClient.resetPassword(resetPasswordDto);
      return response.message;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Đặt lại mật khẩu thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<UserResponseDto> getAuthUser() async {
    try {
      final response = await _authApiClient.getAuthUser();
      return response;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Lấy thông tin người dùng thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
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
