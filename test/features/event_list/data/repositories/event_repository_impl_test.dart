import 'package:dio/dio.dart';
import 'package:event_management/features/event_list/data/datasources/event_api_client.dart';
import 'package:event_management/features/event_list/data/models/event_page_response_model.dart';
import 'package:event_management/features/event_list/data/models/page_response_model.dart';
import 'package:event_management/features/event_list/data/repository/event_repository_impl.dart';
import 'package:event_management/features/event_list/domain/entities/event.dart';
import 'package:event_management/features/event_list/domain/entities/event_counters.dart';
import 'package:event_management/features/event_list/domain/entities/event_list_result.dart';
import 'package:event_management/features/event_list/domain/entities/event_status.dart';
import 'package:event_management/features/event_list/domain/repositories/event_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'event_repository_impl_test.mocks.dart';

@GenerateMocks([EventApiClient])
void main() {
  late EventRepository eventRepository;
  late MockEventApiClient mockEventApiClient;

  setUp(() {
    mockEventApiClient = MockEventApiClient();
    eventRepository = EventRepositoryImpl(mockEventApiClient);
  });

  final tEvent = Event(
    id: 1,
    title: 'Sự kiện Test',
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 2)),
    status: EventStatus.upcoming,
    createdAt: DateTime.now(),
  );

  const tCounters = EventCounters(
    upcoming: 1,
    ongoing: 0,
    completed: 0,
    cancelled: 0,
    manage: 1,
  );

  final tPageResponseModel = PageResponseModel<Event>(
    content: [tEvent],
    page: 0,
    size: 1,
    totalElements: 1,
    totalPages: 1,
    first: true,
    last: true,
    hasNext: false,
    hasPrevious: false,
    numberOfElements: 1,
    empty: false,
  );

  final tEventPageResponseModel = EventPageResponseModel(
    pagination: tPageResponseModel,
    counters: tCounters,
  );

  const tPage = 0;
  const tStatus = EventStatus.upcoming;
  const tSearch = 'test';

  group('getAllEvents', () {
    // Test kịch bản THÀNH CÔNG
    test('nên trả về EventListResult khi gọi API thành công', () async {
      when(
        mockEventApiClient.getAllEvents(status: tStatus.name, search: tSearch),
      ).thenAnswer((_) async => tEventPageResponseModel);

      final result = await eventRepository.getAllEvents(
        page: tPage,
        status: tStatus,
        search: tSearch,
      );

      expect(result, isA<EventListResult>());
      expect(result.events, [tEvent]);
      expect(result.counters, tCounters);
      expect(result.hasNextPage, false);

      verify(
        mockEventApiClient.getAllEvents(status: tStatus.name, search: tSearch),
      ).called(1);
    });

    test('nên ném ra Exception với thông báo lỗi từ DioException', () async {
      // ARRANGE (Sắp đặt):
      // Tạo một lỗi DioException giả
      final tDioException = DioException(
        requestOptions: RequestOptions(path: '/events'),
        response: Response(
          requestOptions: RequestOptions(path: '/events'),
          data: {'message': 'Server bận, thử lại sau'}, // Lỗi từ backend
          statusCode: 500,
        ),
      );

      // Giả lập rằng khi client gọi `getAllEvents`...
      when(
        mockEventApiClient.getAllEvents(status: tStatus.name, search: tSearch),
      ).thenThrow(tDioException);

      final call = eventRepository.getAllEvents(
        page: tPage,
        status: tStatus,
        search: tSearch,
      );

      expect(
        () => call,
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Server bận, thử lại sau',
          ),
        ),
      );

      verify(
        mockEventApiClient.getAllEvents(status: tStatus.name, search: tSearch),
      ).called(1);
    });
  });
}
