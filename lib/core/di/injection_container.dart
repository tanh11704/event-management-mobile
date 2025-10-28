import 'package:dio/dio.dart';
import 'package:event_management/core/network/dio_config.dart';
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/repository/auth_repository_impl.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => LoginBloc(authRepository: sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<AuthApiClient>(() => AuthApiClient(sl()));

  sl.registerLazySingleton<Dio>(() => DioConfig.createDio(sl()));

  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
