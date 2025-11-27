// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollResponse _$PollResponseFromJson(Map<String, dynamic> json) => PollResponse(
  id: (json['id'] as num).toInt(),
  eventId: (json['event_id'] as num).toInt(),
  title: json['title'] as String,
  pollType: const PollTypeConverter().fromJson(json['poll_type'] as String),
  startTime: const TimestampConverter().fromJson(
    (json['start_time'] as num).toDouble(),
  ),
  endTime: const TimestampConverter().fromJson(
    (json['end_time'] as num).toDouble(),
  ),
  isDelete: json['is_delete'] as bool,
  options: (json['options'] as List<dynamic>)
      .map((e) => OptionResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: const TimestampConverter().fromJson(
    (json['created_at'] as num).toDouble(),
  ),
  updatedAt: const NullableTimestampConverter().fromJson(
    (json['updated_at'] as num?)?.toDouble(),
  ),
  hasVoted: json['has_voted'] as bool? ?? false,
);
