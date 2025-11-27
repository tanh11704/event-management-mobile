import 'package:event_management/core/utils/json_converters.dart';
import 'package:event_management/features/poll/data/models/option_dto.dart';
import 'package:event_management/features/poll/data/models/poll_type_converter.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_poll_dto.g.dart';

@JsonSerializable()
class CreatePollDto {
  const CreatePollDto({
    required this.eventId,
    required this.title,
    required this.pollType,
    required this.startTime,
    required this.endTime,
    required this.options,
  });

  factory CreatePollDto.fromJson(Map<String, dynamic> json) =>
      _$CreatePollDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePollDtoToJson(this);

  @JsonKey(name: 'event_id')
  final int eventId;

  final String title;

  @JsonKey(name: 'poll_type')
  @PollTypeConverter()
  final PollType pollType;

  @JsonKey(name: 'start_time')
  @TimestampConverter()
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  @TimestampConverter()
  final DateTime endTime;

  final List<OptionDto> options;
}
