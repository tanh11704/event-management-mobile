import 'package:dio/dio.dart';
import 'package:event_management/core/network/dio_config.dart';
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/repository/auth_repository_impl.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/event/data/datasources/event_api_client.dart';
import 'package:event_management/features/event/data/datasources/event_sse_service.dart';
import 'package:event_management/features/event/data/repositories/event_repository_impl.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/unit/data/datasource/unit_api_client.dart';
import 'package:event_management/features/unit/data/repository/unit_repository_impl.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl
    // Auth Bloc
    ..registerFactory(() => LoginBloc(authRepository: sl()))
    ..registerFactory(
      () => RegisterBloc(authRepository: sl(), unitRepository: sl()),
    )
    ..registerFactory(() => ChangePasswordBloc(authRepository: sl()))
    ..registerFactory(() => ForgotPasswordBloc(authRepository: sl()))
    // Event Bloc
    ..registerFactory(
      () => EventListBloc(eventRepository: sl(), eventSseService: sl()),
    )
    // Core - Register secure storage first
    ..registerLazySingleton(() => const FlutterSecureStorage())
    // Repositories - Must be registered before Dio (which needs AuthRepository)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<EventRepository>(() => EventRepositoryImpl(sl()))
    ..registerLazySingleton<UnitRepository>(() => UnitRepositoryImpl(sl()))
    // Dio instances - Main Dio for general use (has auth interceptor)
    ..registerLazySingleton<Dio>(
      () =>
          DioConfig.createDio(sl<FlutterSecureStorage>(), sl<AuthRepository>()),
    )
    // API Clients & Services
    // AuthApiClient uses a separate Dio instance without interceptor to avoid circular dependency
    ..registerLazySingleton<AuthApiClient>(
      () => AuthApiClient(DioConfig.createAuthDio(sl<FlutterSecureStorage>())),
    )
    ..registerLazySingleton<UnitApiClient>(() => UnitApiClient(sl()))
    ..registerLazySingleton<EventApiClient>(() => EventApiClient(sl()))
    ..registerLazySingleton<EventSseService>(() => EventSseService(sl()));
}
