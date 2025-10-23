import 'package:dio/dio.dart';
import 'package:event_management/features/event_list/data/datasources/event_api_client.dart';
import 'package:event_management/features/event_list/domain/entities/event_list_result.dart';
import 'package:event_management/features/event_list/domain/entities/event_status.dart';
import 'package:event_management/features/event_list/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._apiClient);

  final EventApiClient _apiClient;

  @override
  Future<EventListResult> getAllEvents({
    required int page,
    EventStatus? status,
    String? search,
  }) async {
    try {
      final response = await _apiClient.getAllEvents(
        page: page,
        status: status?.name,
        search: search,
      );

      return EventListResult(
        events: response.pagination.content,
        counters: response.counters,
        hasNextPage: response.pagination.hasNext,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Tải sự kiện thất bại.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
