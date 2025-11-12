// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attendant _$AttendantFromJson(Map<String, dynamic> json) => Attendant(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  eventId: (json['event_id'] as num).toInt(),
  joinedAt: DateTime.parse(json['joined_at'] as String),
  checkedTime: json['checked_time'] == null
      ? null
      : DateTime.parse(json['checked_time'] as String),
);
