import 'package:dio/dio.dart';
import 'package:event_management/features/admin/data/datasources/admin_api_client.dart';
import 'package:event_management/features/admin/data/models/event_management.dart';
import 'package:event_management/features/admin/data/models/event_manager_dto.dart';
import 'package:event_management/features/admin/data/models/event_manager_response_dto.dart';
import 'package:event_management/features/admin/data/models/role_dto.dart';
import 'package:event_management/features/admin/data/models/user_response_dto.dart';
import 'package:event_management/features/admin/domain/entity/event_manager_entity.dart';
import 'package:event_management/features/admin/domain/entity/role_entity.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:event_management/features/admin/domain/repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._adminApiClient);

  final AdminApiClient _adminApiClient;

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final response = await _adminApiClient.getAllUsers();

      return UserResponseDto.toEntities(response);
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
      return RoleDto.toEntities(response);
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

      return UserResponseDto.toEntity(response);
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

  @override
  Future<EventManagerEntity> assignEventManager({
    required int eventId,
    required int userId,
    required EventManagement roleType,
    required int? assignedBy,
  }) async {
    try {
      final dto = EventManagerDto(
        eventId: eventId,
        userId: userId,
        roleType: roleType,
        assignedBy: assignedBy,
      );
      final response = await _adminApiClient.assignEventManager(dto);
      return EventManagerResponseDto.toEntity(response);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể gán người quản lý sự kiện.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<void> removeEventManager({
    required int eventId,
    required int userId,
    required EventManagement roleType,
  }) async {
    try {
      final dto = EventManagerDto(
        eventId: eventId,
        userId: userId,
        roleType: roleType,
      );
      await _adminApiClient.removeEventManager(dto);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể xóa người quản lý sự kiện.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
