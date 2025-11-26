// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateEventDto _$UpdateEventDtoFromJson(Map<String, dynamic> json) =>
    UpdateEventDto(
      title: json['title'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      maxParticipants: (json['max_participants'] as num).toInt(),
      urlDocs: json['url_docs'] as String,
    );

Map<String, dynamic> _$UpdateEventDtoToJson(UpdateEventDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'location': instance.location,
      'max_participants': instance.maxParticipants,
      'url_docs': instance.urlDocs,
    };
