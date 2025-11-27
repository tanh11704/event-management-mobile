// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_poll_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePollDto _$UpdatePollDtoFromJson(Map<String, dynamic> json) =>
    UpdatePollDto(
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

Map<String, dynamic> _$UpdatePollDtoToJson(UpdatePollDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'poll_type': const PollTypeConverter().toJson(instance.pollType),
      'start_time': const TimestampConverter().toJson(instance.startTime),
      'end_time': const TimestampConverter().toJson(instance.endTime),
      'options': instance.options,
    };
