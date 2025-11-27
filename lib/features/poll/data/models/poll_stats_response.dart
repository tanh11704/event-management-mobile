import 'package:equatable/equatable.dart';
import 'package:event_management/core/utils/json_converters.dart';
import 'package:event_management/features/poll/data/models/option_stats_response.dart';
import 'package:event_management/features/poll/data/models/poll_type_converter.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'poll_stats_response.g.dart';

@JsonSerializable(createToJson: false)
class PollStatsResponse extends Equatable {
  const PollStatsResponse({
    required this.id,
    required this.title,
    required this.pollType,
    required this.isDelete,
    required this.totalVotes,
    required this.totalVoters,
    required this.options,
    required this.startTime,
    required this.endTime,
  });

  factory PollStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$PollStatsResponseFromJson(json);

  final int id;
  final String title;

  @JsonKey(name: 'poll_type')
  @PollTypeConverter()
  final PollType pollType;

  @JsonKey(name: 'is_delete')
  final bool isDelete;

  @JsonKey(name: 'total_votes')
  final int totalVotes;

  @JsonKey(name: 'total_voters')
  final int totalVoters;

  final List<OptionStatsResponse> options;

  @JsonKey(name: 'start_time')
  @TimestampConverter()
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  @TimestampConverter()
  final DateTime endTime;

  @override
  List<Object?> get props => [
    id,
    title,
    pollType,
    isDelete,
    totalVotes,
    totalVoters,
    options,
    startTime,
    endTime,
  ];
}
