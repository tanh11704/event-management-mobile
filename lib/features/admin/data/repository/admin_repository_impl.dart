import 'package:dio/dio.dart';
import 'package:event_management/features/admin/data/datasources/admin_api_client.dart';
import 'package:event_management/features/admin/data/models/role_dto.dart';
import 'package:event_management/features/admin/data/models/user_response_dto.dart';
import 'package:event_management/features/admin/domain/entity/role_entity.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:event_management/features/admin/domain/repositories/admin_repository.dart';
import 'package:event_management/features/unit/data/model/unit_response_dto.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._adminApiClient);

  final AdminApiClient _adminApiClient;

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final response = await _adminApiClient.getAllUsers();

      return response.map(_toEntity).toList();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải danh sách người dùng.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<List<RoleEntity>> getAllRoles() async {
    try {
      final response = await _adminApiClient.getAllRoles();
      return response.map(_toRoleEntity).toList();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải danh sách vai trò.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<UserEntity> updateUserRole(int userId, int roleId) async {
    try {
      final response = await _adminApiClient.updateUserRole(userId, {
        'role_id': roleId,
      });

      return _toEntity(response);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(
          errorMessage ?? 'Không thể cập nhật vai trò người dùng.',
        );
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  UserEntity _toEntity(UserResponseDto dto) {
    return UserEntity(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      enabled: dto.enabled,
      unit: dto.unit != null ? UnitResponseDto.toEntity(dto.unit!) : null,
      roles: dto.roles?.map(_toRoleEntity).toList(),
    );
  }

  RoleEntity _toRoleEntity(RoleDto dto) {
    return RoleEntity(id: dto.id, roleName: dto.roleName);
  }
}
