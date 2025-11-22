import 'package:event_management/features/admin/domain/entity/event_manager_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_manager_response_dto.g.dart';

@JsonSerializable()
class EventManagerResponseDto {
  EventManagerResponseDto({
    required this.eventId,
    required this.userId,
    required this.roleType,
    this.assignedBy,
  });

  factory EventManagerResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EventManagerResponseDtoFromJson(json);

  @JsonKey(name: 'event_id')
  final int eventId;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'role_type')
  final String roleType;

  @JsonKey(name: 'assigned_by')
  final int? assignedBy;

  Map<String, dynamic> toJson() => _$EventManagerResponseDtoToJson(this);

  static EventManagerEntity toEntity(EventManagerResponseDto dto) {
    return EventManagerEntity(
      eventId: dto.eventId,
      userId: dto.userId,
      roleType: dto.roleType,
      assignedBy: dto.assignedBy,
    );
  }
}
