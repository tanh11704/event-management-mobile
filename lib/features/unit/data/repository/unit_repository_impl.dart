import 'package:dio/dio.dart';
import 'package:event_management/features/unit/data/datasource/unit_api_client.dart';
import 'package:event_management/features/unit/data/model/page_response.dart';
import 'package:event_management/features/unit/data/model/unit_request_dto.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UnitRepository)
class UnitRepositoryImpl implements UnitRepository {
  const UnitRepositoryImpl(this._apiClient);

  final UnitApiClient _apiClient;

  @override
  Future<PageResponse<UnitEntity>> listUnits({
    String? query,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.listUnits(
        query: query,
        page: page,
        size: size,
      );
      return PageResponse<UnitEntity>(
        content: response.content.map((dto) => dto.toEntity()).toList(),
        page: response.page,
        size: response.size,
        totalElements: response.totalElements,
        totalPages: response.totalPages,
        first: response.first,
        last: response.last,
        hasNext: response.hasNext,
        hasPrevious: response.hasPrevious,
        numberOfElements: response.numberOfElements,
        empty: response.empty,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy danh sách đơn vị.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<List<UnitEntity>> getAllUnits() async {
    try {
      final response = await _apiClient.getAllUnits();
      return response.map((dto) => dto.toEntity()).toList();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy danh sách đơn vị.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<UnitEntity> getUnit(int id) async {
    try {
      final response = await _apiClient.getUnit(id);
      return response.toEntity();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy thông tin đơn vị.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<UnitEntity> createUnit(UnitRequestDto dto) async {
    try {
      final response = await _apiClient.createUnit(dto);
      return response.toEntity();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tạo đơn vị.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<UnitEntity> updateUnit(int id, UnitRequestDto dto) async {
    try {
      final response = await _apiClient.updateUnit(id, dto);
      return response.toEntity();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể cập nhật đơn vị.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<void> deleteUnit(int id) async {
    try {
      await _apiClient.deleteUnit(id);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể xóa đơn vị.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
