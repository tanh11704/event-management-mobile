import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_management/features/event/data/datasources/event_api_client.dart';
import 'package:event_management/features/event/data/models/attendant.dart';
import 'package:event_management/features/event/data/models/create_event_dto.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: EventRepository)
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._eventApiClient);

  final EventApiClient _eventApiClient;

  @override
  Future<Event> createEvent(CreateEventDto createEventDto) async {
    try {
      return await _eventApiClient.createEvent(createEventDto);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tạo sự kiện.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<EventListResult> getAllEvents({
    int page = 0,
    int size = 12,
    String sortBy = 'startTime',
    String sortDir = 'asc',
    EventStatus? status,
    String? search,
  }) async {
    try {
      final response = await _eventApiClient.getAllEvents(
        page: page,
        size: size,
        sortBy: sortBy,
        sortDir: sortDir,
        status: status?.toJsonValue,
        search: search,
      );

      return EventListResult(
        events: response.pagination.content,
        counters: response.counters,
        hasNext: response.pagination.hasNext,
        totalPages: response.pagination.totalPages,
        currentPage: response.pagination.page,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải danh sách sự kiện.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<EventListResult> getManagedEvents({
    int page = 0,
    int size = 12,
    String sortBy = 'startTime',
    String sortDir = 'asc',
    EventStatus? status,
    String? search,
  }) async {
    try {
      final response = await _eventApiClient.getManagedEvents(
        page: page,
        size: size,
        sortBy: sortBy,
        sortDir: sortDir,
        status: status?.toJsonValue,
        search: search,
      );

      return EventListResult(
        events: response.pagination.content,
        counters: response.counters,
        hasNext: response.pagination.hasNext,
        totalPages: response.pagination.totalPages,
        currentPage: response.pagination.page,
      );
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(
          errorMessage ?? 'Không thể tải danh sách sự kiện quản lý.',
        );
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<EventDetailResponse> getEventDetail(int id) async {
    try {
      return await _eventApiClient.getEventDetail(id);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải chi tiết sự kiện.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<Attendant> joinEvent(String eventToken) async {
    try {
      return await _eventApiClient.joinEvent(eventToken);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tham gia sự kiện.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<Event> uploadBanner(int eventId, File bannerFile) async {
    try {
      return await _eventApiClient.uploadBanner(eventId, bannerFile);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải lên banner.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<Event> uploadBannerFromXFile(int eventId, XFile bannerFile) async {
    try {
      // Convert XFile to File for API call
      final file = File(bannerFile.path);
      return await _eventApiClient.uploadBanner(eventId, file);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải lên banner.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
