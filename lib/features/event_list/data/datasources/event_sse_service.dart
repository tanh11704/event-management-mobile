import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:event_management/features/event_list/data/models/sse_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class EventSseService {
  EventSseService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  StreamController<SseEvent>? _controller;
  CancelToken? _cancelToken;

  String _buffer = '';

  Stream<SseEvent> subscribeToEvents() {
    if (kDebugMode) {
      debugPrint('EventSseService: subscribeToEvents called');
    }

    if (_controller != null && !_controller!.isClosed) {
      if (kDebugMode) {
        debugPrint('EventSseService: Returning existing stream');
      }
      return _controller!.stream;
    }

    _controller = StreamController<SseEvent>.broadcast();
    _cancelToken = CancelToken();
    _buffer = '';

    unawaited(_connectToSse());

    return _controller!.stream;
  }

  Future<void> _connectToSse() async {
    if (kDebugMode) {
      debugPrint('EventSseService: _connectToSse starting...');
    }
    try {
      final token = await _secureStorage.read(key: 'access_token');
      final baseUrl =
          dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

      if (kDebugMode) {
        debugPrint('EventSseService: Connecting to $baseUrl/events/subscribe');
        debugPrint('EventSseService: Token exists: ${token != null}');
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

      if (kDebugMode) {
        debugPrint('EventSseService: Sending SSE request...');
      }

      final response = await dio.get<ResponseBody>(
        '/events/subscribe',
        cancelToken: _cancelToken,
      );

      if (kDebugMode) {
        debugPrint(
          'EventSseService: SSE response received, status: ${response.statusCode}',
        );
      }

      final stream = response.data?.stream;
      if (stream != null) {
        if (kDebugMode) {
          debugPrint('EventSseService: Stream exists, starting to listen...');
        }

        final stringStream = utf8.decoder.bind(stream);

        final lineStream = stream
            .transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>)
            .transform(const LineSplitter());

        try {
          await for (final line in lineStream) {
            _parseAndEmitEvent(line);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('EventSseService: Error reading stream: $e');
          }
          rethrow;
        }
        if (kDebugMode) {
          debugPrint('EventSseService: Stream ended');
        }
      } else {
        if (kDebugMode) {
          debugPrint('EventSseService: Stream is null!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EventSseService: Connection error: $e');
      }

      if (!(_cancelToken?.isCancelled ?? false)) {
        _controller?.addError(e);
        if (kDebugMode) {
          debugPrint('EventSseService: Will retry connection in 5 seconds...');
        }
        await Future<void>.delayed(const Duration(seconds: 5));
        if (_controller != null && !_controller!.isClosed) {
          if (kDebugMode) {
            debugPrint('EventSseService: Retrying connection...');
          }
          unawaited(_connectToSse());
        }
      }
    }
  }

  void _parseAndEmitEvent(String line) {
    if (kDebugMode) {
      debugPrint('SSE raw line: $line');
    }

    if (line.isEmpty) {
      _processCompleteEvent(_buffer);
      _buffer = '';
      return;
    }

    _buffer += '$line\n';
  }

  void _processCompleteEvent(String eventText) {
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
          'SSE Event parsed and emitting: $eventName, data: ${eventData ?? "null"}',
        );
      }
      _controller?.add(SseEvent(name: eventName, data: eventData ?? ''));
    } else {
      if (kDebugMode) {
        debugPrint('SSE Event parsed but no event name found in: $eventText');
      }
    }
  }

  void dispose() {
    _cancelToken?.cancel();
    _controller?.close();
  }
}
