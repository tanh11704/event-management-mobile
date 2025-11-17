// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  startTime: const TimestampConverter().fromJson(json['start_time']),
  endTime: const TimestampConverter().fromJson(json['end_time']),
  status: $enumDecode(_$EventStatusEnumMap, json['status']),
  createdAt: const TimestampConverter().fromJson(json['created_at']),
  description: json['description'] as String?,
  location: json['location'] as String?,
  banner: json['banner'] as String?,
  urlDocs: json['url_docs'] as String?,
  maxParticipants: (json['max_participants'] as num?)?.toInt(),
  currentParticipants: (json['current_participants'] as num?)?.toInt(),
  updatedAt: const NullableTimestampConverter().fromJson(json['updated_at']),
  isRegistered: json['is_registered'] as bool?,
  createdByName: json['created_by_name'] as String?,
  managerName: json['manager_name'] as String?,
  qrJoinToken: json['qr_join_token'] as String?,
);

const _$EventStatusEnumMap = {
  EventStatus.upcoming: 'UPCOMING',
  EventStatus.ongoing: 'ONGOING',
  EventStatus.completed: 'COMPLETED',
  EventStatus.cancelled: 'CANCELLED',
};
