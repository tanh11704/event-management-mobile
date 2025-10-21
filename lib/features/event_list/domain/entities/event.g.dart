// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  status: $enumDecode(_$EventStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  description: json['description'] as String?,
  location: json['location'] as String?,
  banner: json['banner'] as String?,
  urlDocs: json['urlDocs'] as String?,
  maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
  currentParticipants: (json['currentParticipants'] as num?)?.toInt(),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isRegistered: json['isRegistered'] as bool?,
  createdByName: json['createdByName'] as String?,
  managerName: json['managerName'] as String?,
);

const _$EventStatusEnumMap = {
  EventStatus.upcoming: 'UPCOMING',
  EventStatus.ongoing: 'ONGOING',
  EventStatus.completed: 'COMPLETED',
  EventStatus.cancelled: 'CANCELLED',
  EventStatus.manage: 'MANAGE',
};
