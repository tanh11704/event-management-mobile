// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:event_management/features/auth/data/datasources/auth_api_client.dart'
    as _i881;
import 'package:event_management/features/auth/data/repository/auth_repository_impl.dart'
    as _i964;
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart'
    as _i257;
import 'package:event_management/features/auth/presentation/bloc/change_password_bloc.dart'
    as _i517;
import 'package:event_management/features/auth/presentation/bloc/register_bloc.dart'
    as _i325;
import 'package:event_management/features/unit/data/datasource/unit_api_client.dart'
    as _i132;
import 'package:event_management/features/unit/data/repository/unit_repository_impl.dart'
    as _i110;
import 'package:event_management/features/unit/domain/repository/unit_repository.dart'
    as _i1037;
import 'package:event_management/injection.dart' as _i695;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i881.AuthApiClient>(
      () => _i881.AuthApiClient.new(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i132.UnitApiClient>(
      () => _i132.UnitApiClient.new(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1037.UnitRepository>(
      () => _i110.UnitRepositoryImpl(gh<_i132.UnitApiClient>()),
    );
    gh.lazySingleton<_i257.AuthRepository>(
      () => _i964.AuthRepositoryImpl(
        gh<_i881.AuthApiClient>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i517.ChangePasswordBloc>(
      () => _i517.ChangePasswordBloc(gh<_i257.AuthRepository>()),
    );
    gh.factory<_i325.RegisterBloc>(
      () => _i325.RegisterBloc(
        gh<_i257.AuthRepository>(),
        gh<_i1037.UnitRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i695.RegisterModule {}
