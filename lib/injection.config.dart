// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
import 'package:event_management/features/auth/domain/repository/auth_repository.dart'
    as _i488;
import 'package:event_management/features/auth/presentation/bloc/register_bloc.dart'
    as _i325;
import 'package:event_management/injection.dart' as _i695;
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
    gh.lazySingleton<_i881.AuthApiClient>(
      () => _i881.AuthApiClient(gh<_i361.Dio>(), baseUrl: gh<String>()),
    );
    gh.lazySingleton<_i488.AuthRepository>(
      () => _i964.AuthRepositoryImpl(gh<_i881.AuthApiClient>()),
    );
    gh.factory<_i325.RegisterBloc>(
      () => _i325.RegisterBloc(gh<_i488.AuthRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i695.RegisterModule {}
