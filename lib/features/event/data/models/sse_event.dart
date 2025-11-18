import 'package:flutter/foundation.dart';

@immutable
class SseEvent {
  const SseEvent({required this.name, required this.data});

  final String name;
  final String data;
}
