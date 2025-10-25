import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl() {
    _authApiClient = AuthApiClient(Dio);
  }
  late final AuthApiClient _authApiClient;

  @override
  Future<String> register(RegisterRequestDto registerRequestDto) async {
    final response = await _authApiClient.register(registerRequestDto);

    return response;
  }
}
