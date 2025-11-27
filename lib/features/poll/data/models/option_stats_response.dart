import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'option_stats_response.g.dart';

@JsonSerializable(createToJson: false)
class OptionStatsResponse extends Equatable {
  const OptionStatsResponse({
    required this.id,
    required this.text,
    required this.voteCount,
    this.percentage = 0.0,
  });

  factory OptionStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$OptionStatsResponseFromJson(json);

  final int id;

  @JsonKey(name: 'content')
  final String text;

  @JsonKey(name: 'vote_count')
  final int voteCount;

  final double percentage;

  @override
  List<Object?> get props => [id, text, voteCount, percentage];
}
