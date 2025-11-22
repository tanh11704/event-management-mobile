import 'package:dio/dio.dart';
import 'package:event_management/features/event/data/datasources/event_api_client.dart';
import 'package:event_management/features/event/data/models/attendant.dart';
import 'package:event_management/features/event/data/models/create_event_dto.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/data/models/event_dto.dart';
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
  Future<Event> uploadBannerFromXFile(int eventId, XFile bannerFile) async {
    try {
      final bytes = await bannerFile.readAsBytes();

      final fileName = bannerFile.name;

      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

      return await _eventApiClient.uploadBanner(eventId, multipartFile);
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
  Future<void> unjoinEvent(int eventId) async {
    try {
      await _eventApiClient.unjoinEvent(eventId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể hủy đăng ký sự kiện.');
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
  Future<EventDetailResponse> updateEvent(
    int eventId,
    EventDto eventDto,
  ) async {
    try {
      // Update event (returns Event)
      await _eventApiClient.updateEvent(eventId, eventDto);
      // Fetch updated event detail (returns EventDetailResponse)
      return await _eventApiClient.getEventDetail(eventId);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<void> importParticipants(
    int eventId,
    XFile file,
  ) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName = file.name;
      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

      await _eventApiClient.importParticipants(eventId, multipartFile);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể import người tham gia.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<String> uploadImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.name;
      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

      final response = await _eventApiClient.uploadImage(multipartFile);
      return response.url;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải lên ảnh.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
