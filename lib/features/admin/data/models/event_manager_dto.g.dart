// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_manager_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventManagerDto _$EventManagerDtoFromJson(Map<String, dynamic> json) =>
    EventManagerDto(
      eventId: (json['event_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      roleType: $enumDecode(_$EventManagementEnumMap, json['role_type']),
      assignedBy: (json['assigned_by'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EventManagerDtoToJson(EventManagerDto instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'user_id': instance.userId,
      'role_type': _$EventManagementEnumMap[instance.roleType]!,
      'assigned_by': instance.assignedBy,
    };

const _$EventManagementEnumMap = {
  EventManagement.manage: 'MANAGE',
  EventManagement.staff: 'STAFF',
};
