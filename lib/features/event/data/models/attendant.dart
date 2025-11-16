import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendant.g.dart';

@JsonSerializable(createToJson: false)
class Attendant extends Equatable {
  const Attendant({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.joinedAt,
    this.checkedTime,
  });

  factory Attendant.fromJson(Map<String, dynamic> json) =>
      _$AttendantFromJson(json);

  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'checked_time')
  final DateTime? checkedTime;
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;

  @override
  List<Object?> get props => [id, userId, eventId, checkedTime, joinedAt];
}
