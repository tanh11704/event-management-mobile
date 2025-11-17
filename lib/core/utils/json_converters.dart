import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<DateTime, double> {
  const TimestampConverter();

  @override
  DateTime fromJson(double json) {
    return DateTime.fromMillisecondsSinceEpoch((json * 1000).toInt());
  }

  @override
  double toJson(DateTime object) {
    return object.millisecondsSinceEpoch / 1000;
  }
}

class NullableTimestampConverter implements JsonConverter<DateTime?, double?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(double? json) {
    if (json == null) return null;
    return DateTime.fromMillisecondsSinceEpoch((json * 1000).toInt());
  }

  @override
  double? toJson(DateTime? object) {
    if (object == null) return null;
    return object.millisecondsSinceEpoch / 1000;
  }
}
