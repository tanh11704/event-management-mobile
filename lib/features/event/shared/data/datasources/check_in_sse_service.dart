import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:event_management/features/event/shared/data/models/sse_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// SSE Service for check-in events of a specific event.
@LazySingleton()
class CheckInSseService {
  CheckInSseService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  final Map<int, StreamController<SseEvent>> _controllersByEventId = {};
  final Map<int, CancelToken> _cancelTokensByEventId = {};
  final Map<int, String> _buffersByEventId = {};

  /// Subscribes to check-in events for a specific event.
  Stream<SseEvent> subscribeToCheckInEvents(int eventId) {
    if (kDebugMode) {
      debugPrint(
        'CheckInSseService: subscribeToCheckInEvents called for event $eventId',
      );
    }

    // Return existing stream if available
    final existingController = _controllersByEventId[eventId];
    if (existingController != null && !existingController.isClosed) {
      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: Returning existing stream for event $eventId',
        );
      }
      return existingController.stream;
    }

    // Create new stream controller
    final controller = StreamController<SseEvent>.broadcast();
    _controllersByEventId[eventId] = controller;
    _cancelTokensByEventId[eventId] = CancelToken();
    _buffersByEventId[eventId] = '';

    unawaited(_connectToSse(eventId));

    return controller.stream;
  }

  /// Disconnects SSE for a specific event.
  void dispose(int eventId) {
    if (kDebugMode) {
      debugPrint('CheckInSseService: dispose called for event $eventId');
    }

    _cancelTokensByEventId[eventId]?.cancel();
    _cancelTokensByEventId.remove(eventId);

    _controllersByEventId[eventId]?.close();
    _controllersByEventId.remove(eventId);

    _buffersByEventId.remove(eventId);
  }

  /// Disposes all SSE connections.
  void disposeAll() {
    if (kDebugMode) {
      debugPrint('CheckInSseService: disposeAll called');
    }

    for (final eventId in _controllersByEventId.keys.toList()) {
      dispose(eventId);
    }
  }

  Future<void> _connectToSse(int eventId) async {
    if (kDebugMode) {
      debugPrint(
        'CheckInSseService: _connectToSse starting for event $eventId...',
      );
    }

    try {
      final token = await _secureStorage.read(key: 'access_token');
      final baseUrl =
          dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: Connecting to $baseUrl/attendants/subscribe/$eventId',
        );
        debugPrint('CheckInSseService: Token exists: ${token != null}');
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
          responseType: ResponseType.stream,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: Duration.zero,
        ),
      );

      final cancelToken = _cancelTokensByEventId[eventId];
      if (cancelToken == null || cancelToken.isCancelled) {
        if (kDebugMode) {
          debugPrint(
            'CheckInSseService: Connection cancelled before request for event $eventId',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: Sending SSE request for event $eventId...',
        );
      }

      final response = await dio.get<ResponseBody>(
        '/attendants/subscribe/$eventId',
        cancelToken: cancelToken,
      );

      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: SSE response received for event $eventId, '
          'status: ${response.statusCode}',
        );
      }

      final stream = response.data?.stream;
      if (stream != null) {
        if (kDebugMode) {
          debugPrint(
            'CheckInSseService: Stream exists for event $eventId, starting to listen...',
          );
        }

        final lineStream = stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        try {
          await for (final line in lineStream) {
            final currentCancelToken = _cancelTokensByEventId[eventId];
            if (currentCancelToken == null || currentCancelToken.isCancelled) {
              if (kDebugMode) {
                debugPrint(
                  'CheckInSseService: Connection cancelled during stream for event $eventId',
                );
              }
              break;
            }
            _parseAndEmitEvent(eventId, line);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint(
              'CheckInSseService: Error reading stream for event $eventId: $e',
            );
          }
          final controller = _controllersByEventId[eventId];
          if (controller != null && !controller.isClosed) {
            controller.addError(e);
          }
          rethrow;
        }
        if (kDebugMode) {
          debugPrint('CheckInSseService: Stream ended for event $eventId');
        }
      } else {
        if (kDebugMode) {
          debugPrint('CheckInSseService: Stream is null for event $eventId!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: Connection error for event $eventId: $e',
        );
      }

      final cancelToken = _cancelTokensByEventId[eventId];
      final controller = _controllersByEventId[eventId];

      if (cancelToken != null && !cancelToken.isCancelled) {
        if (controller != null && !controller.isClosed) {
          controller.addError(e);
        }

        if (kDebugMode) {
          debugPrint(
            'CheckInSseService: Will retry connection in 5 seconds for event $eventId...',
          );
        }

        await Future<void>.delayed(const Duration(seconds: 5));

        if (controller != null &&
            !controller.isClosed &&
            !cancelToken.isCancelled) {
          if (kDebugMode) {
            debugPrint(
              'CheckInSseService: Retrying connection for event $eventId...',
            );
          }
          unawaited(_connectToSse(eventId));
        }
      }
    }
  }

  void _parseAndEmitEvent(int eventId, String line) {
    if (kDebugMode) {
      debugPrint('CheckInSseService: SSE raw line for event $eventId: $line');
    }

    if (line.isEmpty) {
      final buffer = _buffersByEventId[eventId] ?? '';
      _processCompleteEvent(eventId, buffer);
      _buffersByEventId[eventId] = '';
      return;
    }

    _buffersByEventId[eventId] = '${_buffersByEventId[eventId] ?? ''}$line\n';
  }

  void _processCompleteEvent(int eventId, String eventText) {
    if (eventText.isEmpty) return;

    String? eventName;
    String? eventData;

    final lines = eventText.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue;
      } else if (trimmedLine.startsWith('event:')) {
        eventName = trimmedLine.substring(6).trim();
      } else if (trimmedLine.startsWith('data:')) {
        final dataValue = trimmedLine.substring(5).trim();
        if (eventData == null) {
          eventData = dataValue;
        } else {
          eventData = '$eventData\n$dataValue';
        }
      }
    }

    if (eventName != null) {
      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: SSE Event parsed and emitting for event $eventId: '
          '$eventName, data: ${eventData ?? "null"}',
        );
      }
      final controller = _controllersByEventId[eventId];
      if (controller != null && !controller.isClosed) {
        controller.add(SseEvent(name: eventName, data: eventData ?? ''));
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          'CheckInSseService: SSE Event parsed but no event name found for event '
          '$eventId in: $eventText',
        );
      }
    }
  }
}
