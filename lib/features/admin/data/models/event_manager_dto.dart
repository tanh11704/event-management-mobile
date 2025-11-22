import 'package:event_management/features/admin/data/models/event_management.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_manager_dto.g.dart';

@JsonSerializable()
class EventManagerDto {
  EventManagerDto({
    required this.eventId,
    required this.userId,
    required this.roleType,
    this.assignedBy,
  });

  factory EventManagerDto.fromJson(Map<String, dynamic> json) =>
      _$EventManagerDtoFromJson(json);

  @JsonKey(name: 'event_id')
  final int eventId;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'role_type')
  final EventManagement roleType;

  @JsonKey(name: 'assigned_by')
  final int? assignedBy;

  Map<String, dynamic> toJson() => _$EventManagerDtoToJson(this);
}
