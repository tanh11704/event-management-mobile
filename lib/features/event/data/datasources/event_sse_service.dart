import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class EventSseService {
  EventSseService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  StreamController<SseEvent>? _controller;
  CancelToken? _cancelToken;

  Stream<SseEvent> subscribeToEvents() {
    _controller?.close();
    _controller = StreamController<SseEvent>.broadcast();
    _cancelToken = CancelToken();

    _connectToSse();

    return _controller!.stream;
  }

  Future<void> _connectToSse() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      final baseUrl =
          dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

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

      final response = await dio.get<ResponseBody>(
        '/events/subscribe',
        cancelToken: _cancelToken,
      );

      final stream = response.data?.stream;
      if (stream != null) {
        await for (final data in stream.transform<String>(
          StreamTransformer<Uint8List, String>.fromHandlers(
            handleData: (bytes, sink) {
              final decoded = utf8.decode(bytes as List<int>);
              sink.add(decoded);
            },
          ),
        )) {
          _parseAndEmitEvent(data);
        }
      }
    } catch (e) {
      if (!(_cancelToken?.isCancelled ?? false)) {
        _controller?.addError(e);
        // Retry connection after 5 seconds
        await Future<void>.delayed(const Duration(seconds: 5));
        if (_controller != null && !_controller!.isClosed) {
          unawaited(_connectToSse());
        }
      }
    }
  }

  void _parseAndEmitEvent(String data) {
    final lines = data.split('\n');
    String? eventName;
    String? eventData;

    for (final line in lines) {
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        eventData = line.substring(5).trim();
      }
    }

    if (eventName != null && eventData != null) {
      _controller?.add(SseEvent(name: eventName, data: eventData));
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
