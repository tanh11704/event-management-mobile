import 'package:event_management/core/utils/json_converters.dart';
import 'package:event_management/features/poll/data/models/option_dto.dart';
import 'package:event_management/features/poll/data/models/poll_type_converter.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_poll_dto.g.dart';

@JsonSerializable()
class UpdatePollDto {
  const UpdatePollDto({
    required this.title,
    required this.pollType,
    required this.startTime,
    required this.endTime,
    required this.options,
  });

  factory UpdatePollDto.fromJson(Map<String, dynamic> json) =>
      _$UpdatePollDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePollDtoToJson(this);

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
