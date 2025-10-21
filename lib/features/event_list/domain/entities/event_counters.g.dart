// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_counters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCounters _$EventCountersFromJson(Map<String, dynamic> json) =>
    EventCounters(
      upcoming: (json['upcoming'] as num).toInt(),
      ongoing: (json['ongoing'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
      cancelled: (json['cancelled'] as num).toInt(),
      manage: (json['manage'] as num).toInt(),
    );

Map<String, dynamic> _$EventCountersToJson(EventCounters instance) =>
    <String, dynamic>{
      'upcoming': instance.upcoming,
      'ongoing': instance.ongoing,
      'completed': instance.completed,
      'cancelled': instance.cancelled,
      'manage': instance.manage,
    };
