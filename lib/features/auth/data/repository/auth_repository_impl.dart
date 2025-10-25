import 'package:dio/dio.dart';
import 'package:event_management/core/config/environtment.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.dio) {
    dio.options.baseUrl = Environment.baseUrl;
  }
  final Dio dio;

  @override
  Future<Map<String, dynamic>> register(
    RegisterRequestDto registerRequestDto,
  ) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: registerRequestDto.toJson(),
    );

    return response.data!;
  }
}
