// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_counters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventCounters _$EventCountersFromJson(Map<String, dynamic> json) =>
    EventCounters(
      upcoming: (json['UPCOMING'] as num).toInt(),
      ongoing: (json['ONGOING'] as num).toInt(),
      completed: (json['COMPLETED'] as num).toInt(),
      cancelled: (json['CANCELLED'] as num).toInt(),
      manage: (json['MANAGE'] as num).toInt(),
    );
