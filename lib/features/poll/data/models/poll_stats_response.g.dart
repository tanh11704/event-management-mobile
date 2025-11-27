// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_stats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollStatsResponse _$PollStatsResponseFromJson(Map<String, dynamic> json) =>
    PollStatsResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      pollType: const PollTypeConverter().fromJson(json['poll_type'] as String),
      isDelete: json['is_delete'] as bool,
      totalVotes: (json['total_votes'] as num).toInt(),
      totalVoters: (json['total_voters'] as num).toInt(),
      options: (json['options'] as List<dynamic>)
          .map((e) => OptionStatsResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      startTime: const TimestampConverter().fromJson(
        (json['start_time'] as num).toDouble(),
      ),
      endTime: const TimestampConverter().fromJson(
        (json['end_time'] as num).toDouble(),
      ),
    );
