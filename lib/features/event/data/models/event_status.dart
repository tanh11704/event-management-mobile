import 'package:json_annotation/json_annotation.dart';

enum EventStatus {
  @JsonValue('UPCOMING')
  upcoming,

  @JsonValue('ONGOING')
  ongoing,

  @JsonValue('COMPLETED')
  completed,

  @JsonValue('CANCELLED')
  cancelled,
}

extension EventStatusExtension on EventStatus {
  String get toJsonValue {
    switch (this) {
      case EventStatus.upcoming:
        return 'UPCOMING';
      case EventStatus.ongoing:
        return 'ONGOING';
      case EventStatus.completed:
        return 'COMPLETED';
      case EventStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
