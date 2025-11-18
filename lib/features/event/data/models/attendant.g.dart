// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendant _$AttendantFromJson(Map<String, dynamic> json) => Attendant(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  eventId: (json['event_id'] as num).toInt(),
  joinedAt: const TimestampConverter().fromJson(json['joined_at']),
  checkedTime: const NullableTimestampConverter().fromJson(
    json['checked_time'],
  ),
);
