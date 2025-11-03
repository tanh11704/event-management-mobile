import 'dart:async';

import 'package:dio/dio.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, this._authRepository);

  final FlutterSecureStorage _secureStorage;
  final AuthRepository _authRepository;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 errors
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Skip refresh for auth endpoints to avoid infinite loop
      if (requestOptions.path.contains('/auth/')) {
        return handler.next(err);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add(_PendingRequest(requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        // Check if refresh token exists
        final refreshToken = await _secureStorage.read(key: 'refresh_token');
        if (refreshToken == null || refreshToken.isEmpty) {
          // No refresh token, logout immediately
          await _authRepository.logout();
          _isRefreshing = false;

          // Reject all pending requests
          for (final pendingRequest in _pendingRequests) {
            pendingRequest.handler.reject(
              DioException(requestOptions: pendingRequest.requestOptions),
            );
          }
          _pendingRequests.clear();

          // Navigate to login - ensure it runs on main isolate
          scheduleMicrotask(() {
            try {
              appRouter.go(AppRoutes.login);
            } catch (e) {
              debugPrint('Error navigating to login: $e');
            }
          });

          return handler.reject(err);
        }

        // Try to refresh token
        await _authRepository.refreshToken();

        // Refresh succeeded, now retry original request with new token
        final token = await _secureStorage.read(key: 'access_token');
        if (token == null || token.isEmpty) {
          throw Exception('Access token không tồn tại sau khi refresh');
        }

        // Update headers with new token while preserving original request options
        requestOptions.headers['Authorization'] = 'Bearer $token';

        // Use a fresh Dio instance to avoid circular dependency
        // Must preserve responseType from original request for Retrofit to parse correctly
        try {
          final dio = Dio(
            BaseOptions(
              baseUrl: requestOptions.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

          // Ensure responseType is set for Retrofit to parse correctly
          // Retrofit expects Map<String, dynamic> for JSON responses
          requestOptions.responseType = ResponseType.json;

          final response = await dio.fetch<Map<String, dynamic>>(
            requestOptions,
          );

          // Ensure response.data is properly formatted for Retrofit
          // Retrofit will parse this response
          if (response.data != null && response.data is Map<String, dynamic>) {
            // Resolve with the successful response
            handler.resolve(response);
          } else {
            // Response format is invalid, reject
            throw DioException(
              requestOptions: requestOptions,
              error: 'Invalid response format after retry',
            );
          }
        } catch (retryError) {
          // Retry failed, but refresh succeeded - just reject the request
          // Don't logout because token was successfully refreshed
          _isRefreshing = false;
          await _processPendingRequests();
          if (retryError is DioException) {
            handler.reject(retryError);
          } else {
            handler.reject(
              DioException(requestOptions: requestOptions, error: retryError),
            );
          }
          return;
        }

        // Process pending requests
        await _processPendingRequests();

        _isRefreshing = false;
      } catch (e) {
        // Refresh token failed, logout user
        _isRefreshing = false;
        await _authRepository.logout();

        // Reject all pending requests
        for (final pendingRequest in _pendingRequests) {
          pendingRequest.handler.reject(
            DioException(requestOptions: pendingRequest.requestOptions),
          );
        }
        _pendingRequests.clear();

        // Navigate to login - ensure it runs on main isolate
        scheduleMicrotask(() {
          try {
            appRouter.go(AppRoutes.login);
          } catch (e) {
            debugPrint('Error navigating to login: $e');
          }
        });

        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _processPendingRequests() async {
    final token = await _secureStorage.read(key: 'access_token');
    final requestsToProcess = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    if (requestsToProcess.isEmpty) {
      return;
    }

    // Use a Dio instance to retry requests
    final dio = Dio(
      BaseOptions(
        baseUrl: requestsToProcess.first.requestOptions.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    for (final pendingRequest in requestsToProcess) {
      try {
        // Update token in headers
        pendingRequest.requestOptions.headers['Authorization'] =
            'Bearer $token';

        // Ensure responseType is set for Retrofit parsing
        pendingRequest.requestOptions.responseType = ResponseType.json;
        final response = await dio.fetch<Map<String, dynamic>>(
          pendingRequest.requestOptions,
        );

        pendingRequest.handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          pendingRequest.handler.reject(e);
        } else {
          pendingRequest.handler.reject(
            DioException(requestOptions: pendingRequest.requestOptions),
          );
        }
      }
    }
  }
}

class _PendingRequest {
  _PendingRequest(this.requestOptions, this.handler);

  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
}
