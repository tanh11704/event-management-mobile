import 'package:dio/dio.dart';
import 'package:event_management/features/admin/data/models/role_dto.dart';
import 'package:event_management/features/admin/data/models/user_response_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'admin_api_client.g.dart';

@RestApi()
@LazySingleton()
abstract class AdminApiClient {
  @factoryMethod
  factory AdminApiClient(Dio dio) = _AdminApiClient;

  @GET('/users')
  Future<List<UserResponseDto>> getAllUsers();

  @GET('/users/roles')
  Future<List<RoleDto>> getAllRoles();

  @PUT('/users/{id}/roles')
  Future<UserResponseDto> updateUserRole(
    @Path('id') int userId,
    @Body() Map<String, int> requestBody,
  );
}
