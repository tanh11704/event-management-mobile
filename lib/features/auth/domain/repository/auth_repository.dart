import 'package:event_management/features/auth/data/models/register_request_dto.dart';

abstract class AuthRepository {
  Future<String> register(RegisterRequestDto registerRequestDto);
}
