import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_management/features/event/shared/data/datasources/event_api_client.dart';
import 'package:event_management/features/event/shared/data/models/attendant.dart';
import 'package:event_management/features/event/shared/data/models/chat_request.dart';
import 'package:event_management/features/event/shared/data/models/chat_response.dart';
import 'package:event_management/features/event/shared/data/models/create_event_dto.dart';
import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/event/shared/data/models/event_dto.dart';
import 'package:event_management/features/event/shared/data/models/event_manager_info.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_request.dart';
import 'package:event_management/features/event/shared/data/models/generate_description_response.dart';
import 'package:event_management/features/event/shared/data/models/import_job_response.dart';
import 'package:event_management/features/event/shared/data/models/import_participants_response.dart';
import 'package:event_management/features/event/shared/data/models/message_dto.dart';
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

@LazySingleton(as: EventRepository)
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._eventApiClient, this._secureStorage);

  final EventApiClient _eventApiClient;
  final FlutterSecureStorage _secureStorage;

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
  Future<Attendant> checkInEvent(String eventToken) async {
    try {
      return await _eventApiClient.checkInEvent(eventToken);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể check-in sự kiện.');
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
      if (kDebugMode) {
        debugPrint(
          'EventRepository: Uploading banner from XFile: ${bannerFile.path}',
        );
        debugPrint('EventRepository: File name: ${bannerFile.name}');
      }

      final bytes = await bannerFile.readAsBytes();

      if (kDebugMode) {
        debugPrint('EventRepository: Read ${bytes.length} bytes from file');
      }

      final fileName = bannerFile.name;

      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

      if (kDebugMode) {
        debugPrint(
          'EventRepository: Calling uploadBanner API for event $eventId',
        );
      }

      return await _eventApiClient.uploadBanner(eventId, multipartFile);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('EventRepository: DioException during banner upload: $e');
        debugPrint('EventRepository: Response: ${e.response?.data}');
      }
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải lên banner.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EventRepository: Error during banner upload: $e');
        debugPrint('EventRepository: Error type: ${e.runtimeType}');
      }
      if (e is Exception) rethrow;
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
  Future<ImportParticipantsResponse> importParticipants(
    int eventId,
    XFile file, {
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName = file.name;
      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

      final response = await _eventApiClient.importParticipants(
        eventId,
        multipartFile,
        onSendProgress: onSendProgress,
      );
      return response;
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
  Future<ImportJobResponse> getImportJobStatus(int jobId) async {
    try {
      return await _eventApiClient.getImportJobStatus(jobId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy trạng thái import.');
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
  Future<String> exportParticipants({
    required int eventId,
    String filter = 'all',
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 300,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    try {
      final response = await dio.get<List<int>>(
        '/attendants/$eventId/export',
        queryParameters: {'filter': filter},
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Server trả về dữ liệu rỗng.');
      }

      final contentType = response.headers.value('content-type');
      if (contentType != null &&
          !contentType.contains('spreadsheet') &&
          !contentType.contains('excel')) {
        throw Exception('Server trả về dữ liệu không hợp lệ.');
      }

      final directory = await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'Danh_sach_nguoi_tham_du_${eventId}_$timestamp.xlsx';
      final filePath = path.join(directory.path, filename);

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      return filePath;
    } on DioException catch (e) {
      var errorMessage = 'Không thể xuất danh sách người tham gia.';

      if (e.response != null && e.response!.data != null) {
        try {
          final dynamic errorData = e.response!.data;

          if (errorData is List<int>) {
            final decodedString = utf8.decode(errorData);
            try {
              final dynamic decodedJson = jsonDecode(decodedString);
              if (decodedJson is Map<String, dynamic>) {
                errorMessage =
                    decodedJson['message'] as String? ?? decodedString;
              } else {
                errorMessage = decodedString;
              }
            } catch (_) {
              errorMessage = decodedString;
            }
          } else if (errorData is Map) {
            errorMessage = errorData['message'] as String? ?? errorMessage;
          }
        } catch (decodeError) {
          if (kDebugMode) {
            debugPrint('Lỗi khi decode error message: $decodeError');
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối quá lâu. Vui lòng thử lại.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến máy chủ. Kiểm tra mạng.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<Uint8List> getQrCheck(int eventId) async {
    try {
      final bytes = await _eventApiClient.getQrCheck(eventId);

      if (bytes.isEmpty) {
        throw Exception('Server trả về dữ liệu QR code rỗng.');
      }

      final uint8List = Uint8List.fromList(bytes);

      // Validate that it's a valid PNG image (PNG signature: 89 50 4E 47)
      if (uint8List.length >= 4) {
        final signature = [
          uint8List[0],
          uint8List[1],
          uint8List[2],
          uint8List[3],
        ];
        if (kDebugMode) {
          debugPrint('Image signature: $signature');
        }
      }

      return uint8List;
    } on DioException catch (e) {
      var errorMessage = 'Không thể tải mã QR check-in.';

      if (e.response != null && e.response!.data != null) {
        try {
          final dynamic errorData = e.response!.data;

          if (errorData is List<int>) {
            final decodedString = utf8.decode(errorData);
            try {
              final dynamic decodedJson = jsonDecode(decodedString);
              if (decodedJson is Map<String, dynamic>) {
                errorMessage =
                    decodedJson['message'] as String? ?? decodedString;
              } else {
                errorMessage = decodedString;
              }
            } catch (_) {
              errorMessage = decodedString;
            }
          } else if (errorData is Map) {
            errorMessage = errorData['message'] as String? ?? errorMessage;
          }
        } catch (decodeError) {
          if (kDebugMode) {
            debugPrint('Lỗi khi decode error message: $decodeError');
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối quá lâu. Vui lòng thử lại.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không thể kết nối đến máy chủ. Kiểm tra mạng.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Lỗi không xác định: $e');
    }
  }

  @override
  Future<List<EventManagerInfo>> getEventManagers(int eventId) async {
    try {
      final dtos = await _eventApiClient.getEventManagersByEventId(
        eventId: eventId,
      );

      // Convert DTOs to EventManagerInfo
      // Note: userName and userEmail are not provided by backend,
      // they will be null and should be enriched separately if needed
      return dtos.map((dto) => EventManagerInfo.fromDto(dto: dto)).toList();
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(
          errorMessage ?? 'Không thể tải danh sách quản lý sự kiện.',
        );
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<GenerateDescriptionResponse> generateDescription(
    GenerateDescriptionRequest request,
  ) async {
    try {
      return await _eventApiClient.generateDescription(request);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tạo mô tả với AI.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<ChatResponse> sendChatMessage(ChatRequest request) async {
    try {
      return await _eventApiClient.sendChatMessage(request);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể gửi tin nhắn.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<List<MessageDto>> getChatHistory(int eventId) async {
    try {
      return await _eventApiClient.getChatHistory(eventId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tải lịch sử chat.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
