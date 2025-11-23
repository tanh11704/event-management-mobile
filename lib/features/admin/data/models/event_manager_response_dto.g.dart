// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_manager_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventManagerResponseDto _$EventManagerResponseDtoFromJson(
  Map<String, dynamic> json,
) => EventManagerResponseDto(
  eventId: (json['event_id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  roleType: json['role_type'] as String,
  assignedBy: (json['assigned_by'] as num?)?.toInt(),
);

Map<String, dynamic> _$EventManagerResponseDtoToJson(
  EventManagerResponseDto instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'user_id': instance.userId,
  'role_type': instance.roleType,
  'assigned_by': instance.assignedBy,
};
