import 'package:equatable/equatable.dart';
import 'package:event_management/core/utils/json_converters.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable(createToJson: false)
class Event extends Equatable {
  const Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.description,
    this.location,
    this.banner,
    this.urlDocs,
    this.maxParticipants,
    this.currentParticipants,
    this.updatedAt,
    this.isRegistered,
    this.createdByName,
    this.managerName,
    this.qrJoinToken,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  final int id;
  final String title;
  final String? description;

  @TimestampConverter()
  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @TimestampConverter()
  @JsonKey(name: 'end_time')
  final DateTime endTime;

  final String? location;
  final EventStatus status;
  final String? banner;

  @JsonKey(name: 'url_docs')
  final String? urlDocs;

  @JsonKey(name: 'max_participants')
  final int? maxParticipants;

  @JsonKey(name: 'current_participants')
  final int? currentParticipants;

  @JsonKey(name: 'updated_at')
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @TimestampConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'is_registered')
  final bool? isRegistered;

  @JsonKey(name: 'created_by_name')
  final String? createdByName;

  @JsonKey(name: 'manager_name')
  final String? managerName;

  @JsonKey(name: 'qr_join_token')
  final String? qrJoinToken;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
    status,
    banner,
    isRegistered,
  ];
}
