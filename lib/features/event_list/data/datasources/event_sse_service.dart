import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
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
  String _buffer = ''; // Buffer for incomplete SSE messages

  Stream<SseEvent> subscribeToEvents() {
    if (kDebugMode) {
      debugPrint('EventSseService: subscribeToEvents called');
    }
    _controller?.close();
    _controller = StreamController<SseEvent>.broadcast();
    _cancelToken = CancelToken();
    _buffer = ''; // Reset buffer

    _connectToSse();

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
        ),
      );

      if (kDebugMode) {
        debugPrint('EventSseService: Sending SSE request...');
      }

      final response = await dio
          .get<ResponseBody>('/events/subscribe', cancelToken: _cancelToken)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint(
                  'EventSseService: SSE request timeout after 30 seconds',
                );
              }
              throw TimeoutException('SSE connection timeout');
            },
          );

      if (kDebugMode) {
        debugPrint(
          'EventSseService: SSE response received, status: ${response.statusCode}',
        );
        debugPrint('EventSseService: Response headers: ${response.headers}');
      }

      final stream = response.data?.stream;
      if (stream != null) {
        if (kDebugMode) {
          debugPrint('EventSseService: Stream exists, starting to listen...');
        }
        try {
          await for (final data in stream.transform<String>(
            StreamTransformer<Uint8List, String>.fromHandlers(
              handleData: (bytes, sink) {
                try {
                  final decoded = utf8.decode(bytes as List<int>);
                  sink.add(decoded);
                  if (kDebugMode && decoded.isNotEmpty) {
                    debugPrint(
                      'EventSseService: Received ${decoded.length} bytes',
                    );
                  }
                } catch (e) {
                  if (kDebugMode) {
                    debugPrint('EventSseService: Error decoding bytes: $e');
                  }
                  sink.addError(e);
                }
              },
            ),
          )) {
            _parseAndEmitEvent(data);
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
          debugPrint(
            'EventSseService: response.data type: ${response.data?.runtimeType}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EventSseService: Connection error: $e');
      }
      if (!(_cancelToken?.isCancelled ?? false)) {
        _controller?.addError(e);
        // Retry connection after 5 seconds
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

  void _parseAndEmitEvent(String data) {
    if (kDebugMode) {
      debugPrint('SSE raw data received: ${data.replaceAll('\n', r'\n')}');
    }

    // Append new data to buffer
    _buffer += data;

    // Process complete events (events end with double newline \n\n)
    while (_buffer.contains('\n\n')) {
      final eventEndIndex = _buffer.indexOf('\n\n');
      final eventText = _buffer.substring(0, eventEndIndex);
      _buffer = _buffer.substring(
        eventEndIndex + 2,
      ); // Remove processed event + \n\n

      _processCompleteEvent(eventText);
    }
  }

  void _processCompleteEvent(String eventText) {
    String? eventName;
    String? eventData;

    final lines = eventText.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        continue; // Skip empty lines
      } else if (trimmedLine.startsWith('event:')) {
        eventName = trimmedLine.substring(6).trim();
      } else if (trimmedLine.startsWith('data:')) {
        final dataValue = trimmedLine.substring(5).trim();
        // Accumulate data if multiple data lines exist
        if (eventData == null) {
          eventData = dataValue;
        } else {
          eventData = '$eventData\n$dataValue';
        }
      }
    }

    // Emit event if we have event name
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
    _controller = null;
  }
}

class SseEvent {
  const SseEvent({required this.name, required this.data});

  final String name;
  final String data;
}
