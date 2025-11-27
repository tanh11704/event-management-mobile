// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_poll_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePollDto _$CreatePollDtoFromJson(Map<String, dynamic> json) =>
    CreatePollDto(
      eventId: (json['event_id'] as num).toInt(),
      title: json['title'] as String,
      pollType: const PollTypeConverter().fromJson(json['poll_type'] as String),
      startTime: const TimestampConverter().fromJson(
        (json['start_time'] as num).toDouble(),
      ),
      endTime: const TimestampConverter().fromJson(
        (json['end_time'] as num).toDouble(),
      ),
      options: (json['options'] as List<dynamic>)
          .map((e) => OptionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreatePollDtoToJson(CreatePollDto instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'title': instance.title,
      'poll_type': const PollTypeConverter().toJson(instance.pollType),
      'start_time': const TimestampConverter().toJson(instance.startTime),
      'end_time': const TimestampConverter().toJson(instance.endTime),
      'options': instance.options,
    };
