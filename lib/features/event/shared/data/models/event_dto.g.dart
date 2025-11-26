// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDto _$EventDtoFromJson(Map<String, dynamic> json) => EventDto(
  title: json['title'] as String,
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  description: json['description'] as String,
  location: json['location'] as String,
  maxParticipants: (json['max_participants'] as num).toInt(),
  urlDocs: json['url_docs'] as String?,
);

Map<String, dynamic> _$EventDtoToJson(EventDto instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'location': instance.location,
  'max_participants': instance.maxParticipants,
  'url_docs': instance.urlDocs,
};
