import 'package:event_management/features/admin/data/models/role.dart';
import 'package:event_management/features/unit/data/model/unit_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response_dto.g.dart';

@JsonSerializable()
class UserResponseDto {
  const UserResponseDto({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.enabled,
    this.unit,
    this.roles,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'enabled')
  final bool? enabled;

  @JsonKey(name: 'unit')
  final UnitResponseDto? unit;

  @JsonKey(name: 'roles')
  final List<Role>? roles;

  Map<String, dynamic> toJson() => _$UserResponseDtoToJson(this);
}
