import 'package:equatable/equatable.dart';
import 'package:event_management/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'participant.g.dart';

@JsonSerializable(createToJson: false)
class ParticipantInfo extends Equatable {
  const ParticipantInfo({
    required this.userId,
    required this.userName,
    required this.joinedAt,
    this.userEmail,
    this.userPhone,
    this.checkedTime,
    this.isCheckedIn,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) =>
      _$ParticipantInfoFromJson(json);

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'user_name')
  final String userName;

  @JsonKey(name: 'user_email')
  final String? userEmail;

  @JsonKey(name: 'user_phone')
  final String? userPhone;

  @TimestampConverter()
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  @NullableTimestampConverter()
  @JsonKey(name: 'checked_time')
  final DateTime? checkedTime;

  @JsonKey(name: 'is_checked_in')
  final bool? isCheckedIn;

  @override
  List<Object?> get props => [
    userId,
    userName,
    userEmail,
    userPhone,
    joinedAt,
    checkedTime,
    isCheckedIn,
  ];
}
