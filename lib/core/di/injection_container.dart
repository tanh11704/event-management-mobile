import 'package:dio/dio.dart';
import 'package:event_management/core/network/dio_config.dart';
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/repository/auth_repository_impl.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/unit/data/datasource/unit_api_client.dart';
import 'package:event_management/features/unit/data/repository/unit_repository_impl.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl
    ..registerFactory(() => LoginBloc(authRepository: sl()))
    ..registerFactory(
      () => RegisterBloc(authRepository: sl(), unitRepository: sl()),
    )
    ..registerFactory(() => ChangePasswordBloc(authRepository: sl()))
    ..registerFactory(() => ForgotPasswordBloc(authRepository: sl()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<UnitApiClient>(() => UnitApiClient(sl()))
    ..registerLazySingleton<UnitRepository>(() => UnitRepositoryImpl(sl()))
    ..registerLazySingleton<AuthApiClient>(() => AuthApiClient(sl()))
    ..registerLazySingleton<Dio>(() => DioConfig.createDio(sl()))
    ..registerLazySingleton(() => const FlutterSecureStorage());
}
