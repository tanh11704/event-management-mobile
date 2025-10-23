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

  @JsonValue('MANAGE')
  manage,
}
