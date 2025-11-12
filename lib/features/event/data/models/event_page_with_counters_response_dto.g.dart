// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_page_with_counters_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventPageWithCountersResponseDto _$EventPageWithCountersResponseDtoFromJson(
  Map<String, dynamic> json,
) => EventPageWithCountersResponseDto(
  pagination: PageResponseDto<Event>.fromJson(
    json['pagination'] as Map<String, dynamic>,
    (value) => Event.fromJson(value as Map<String, dynamic>),
  ),
  counters: EventCounters.fromJson(json['counters'] as Map<String, dynamic>),
);
