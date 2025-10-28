import 'package:event_management/features/auth/data/datasources/auth_api_client.dart';
import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repository/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authApiClient);
  final AuthApiClient _authApiClient;

  @override
  Future<String> register(RegisterRequestDto registerRequestDto) async {
    try {
      final response = await _authApiClient.register(registerRequestDto);

      return response;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  @override
  Future<String> changePassword(
    ChangePasswordRequestDto changePasswordRequestDto,
  ) {
    return _authApiClient.changePassword(changePasswordRequestDto);
  }
}
