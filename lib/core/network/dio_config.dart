import 'package:dio/dio.dart';
import 'package:event_management/core/network/auth_interceptor.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioConfig {
  static Dio createDio(
    FlutterSecureStorage secureStorage,
    AuthRepository authRepository,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add request interceptor to attach access token FIRST
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Add auth interceptor for 401 handling AFTER request interceptor
    // This ensures token is attached before error handling
    dio.interceptors.add(AuthInterceptor(secureStorage, authRepository));

    final isDebugMode = dotenv.env['DEBUG']?.toLowerCase() == 'true';

    if (isDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }

  /// Creates a simple Dio instance for auth endpoints (no interceptor to avoid circular dependency)
  static Dio createAuthDio(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add request interceptor to attach access token (if exists)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    final isDebugMode = dotenv.env['DEBUG']?.toLowerCase() == 'true';

    if (isDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
