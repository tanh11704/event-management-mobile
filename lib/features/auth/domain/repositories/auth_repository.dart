import 'package:event_management/features/auth/data/models/change_password_request_dto.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';

abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<String> register(RegisterRequestDto registerRequestDto);

  Future<String> changePassword(
    ChangePasswordRequestDto changePasswordRequestDto,
  );

  Future<void> refreshToken();

  Future<void> logout();
}
