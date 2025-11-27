// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_stats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionStatsResponse _$OptionStatsResponseFromJson(Map<String, dynamic> json) =>
    OptionStatsResponse(
      id: (json['id'] as num).toInt(),
      text: json['content'] as String,
      voteCount: (json['vote_count'] as num).toInt(),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
