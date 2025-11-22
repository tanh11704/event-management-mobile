import 'package:event_management/features/admin/data/models/role_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response_dto.g.dart';

@JsonSerializable()
class UserResponseDto {
  const UserResponseDto({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.unitId,
    this.avatar,
    this.roles,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'unit_id')
  final int? unitId;

  @JsonKey(name: 'avatar')
  final String? avatar;

  @JsonKey(name: 'roles', includeToJson: false, includeFromJson: true)
  final List<RoleDto>? roles;

  Map<String, dynamic> toJson() => _$UserResponseDtoToJson(this);
}
