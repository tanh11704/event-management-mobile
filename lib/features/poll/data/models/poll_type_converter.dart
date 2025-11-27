import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter để serialize/deserialize PollType enum
class PollTypeConverter implements JsonConverter<PollType, String> {
  const PollTypeConverter();

  @override
  PollType fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'SINGLE_CHOICE':
        return PollType.singleChoice;
      case 'MULTIPLE_CHOICE':
        return PollType.multipleChoice;
      default:
        throw ArgumentError('Unknown PollType: $json');
    }
  }

  @override
  String toJson(PollType object) {
    return object.value;
  }
}
