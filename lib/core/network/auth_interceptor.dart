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

        // Retry original request with new token
        final token = await _secureStorage.read(key: 'access_token');
        final newRequestOptions = requestOptions.copyWith(
          headers: {
            ...requestOptions.headers,
            'Authorization': 'Bearer $token',
          },
        );

        // Use a fresh Dio instance to avoid circular dependency
        final dio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
        final response = await dio.fetch<Response<dynamic>>(newRequestOptions);
        handler.resolve(response);

        // Process pending requests
        _processPendingRequests();

        _isRefreshing = false;
      } catch (e) {
        // Refresh failed, logout user
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

    // Use a Dio instance to retry requests
    final dio = Dio(
      BaseOptions(
        baseUrl: requestsToProcess.isNotEmpty
            ? requestsToProcess.first.requestOptions.baseUrl
            : '',
      ),
    );

    for (final pendingRequest in requestsToProcess) {
      try {
        pendingRequest.requestOptions.headers['Authorization'] =
            'Bearer $token';
        final response = await dio.fetch<Response<dynamic>>(
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
