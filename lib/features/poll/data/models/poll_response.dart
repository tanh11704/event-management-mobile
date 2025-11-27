import 'package:equatable/equatable.dart';
import 'package:event_management/core/utils/json_converters.dart';
import 'package:event_management/features/poll/data/models/option_response.dart';
import 'package:event_management/features/poll/data/models/poll_type_converter.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'poll_response.g.dart';

@JsonSerializable(createToJson: false)
class PollResponse extends Equatable {
  const PollResponse({
    required this.id,
    required this.eventId,
    required this.title,
    required this.pollType,
    required this.startTime,
    required this.endTime,
    required this.isDelete,
    required this.options,
    required this.createdAt,
    this.updatedAt,
    this.hasVoted = false,
  });

  factory PollResponse.fromJson(Map<String, dynamic> json) =>
      _$PollResponseFromJson(json);

  final int id;

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

  @JsonKey(name: 'is_delete')
  final bool isDelete;

  final List<OptionResponse> options;

  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @JsonKey(name: 'has_voted')
  final bool hasVoted;

  @override
  List<Object?> get props => [
    id,
    eventId,
    title,
    pollType,
    startTime,
    endTime,
    isDelete,
    options,
    createdAt,
    updatedAt,
    hasVoted,
  ];
}
