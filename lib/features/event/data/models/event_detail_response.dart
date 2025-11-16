import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:event_management/features/event/data/models/manager.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:event_management/features/event/data/models/secretary.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_detail_response.g.dart';

@JsonSerializable(createToJson: false)
class EventDetailResponse extends Equatable {
  const EventDetailResponse({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.description,
    this.location,
    this.createBy,
    this.banner,
    this.urlDocs,
    this.maxParticipants,
    this.qrJoinToken,
    this.updatedAt,
    this.isUserRegistered,
    this.participants = const [],
    this.manager = const [],
    this.secretaries = const [],
  });

  factory EventDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$EventDetailResponseFromJson(json);

  final int id;
  final String title;
  final String? description;

  @UnixTimestampConverter()
  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @UnixTimestampConverter()
  @JsonKey(name: 'end_time')
  final DateTime endTime;

  final String? location;

  @JsonKey(name: 'create_by')
  final int? createBy;

  final EventStatus status;
  final String? banner;

  @JsonKey(name: 'url_docs')
  final String? urlDocs;

  @JsonKey(name: 'max_participants')
  final int? maxParticipants;

  @JsonKey(name: 'qr_join_token')
  final String? qrJoinToken;

  @UnixTimestampConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @UnixTimestampConverter()
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'is_user_registered')
  final bool? isUserRegistered;

  final List<ParticipantInfo> participants;

  final List<ManagerInfo> manager;

  final List<SecretaryInfo> secretaries;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
    createBy,
    status,
    banner,
    urlDocs,
    maxParticipants,
    qrJoinToken,
    createdAt,
    updatedAt,
    isUserRegistered,
    participants,
    manager,
    secretaries,
  ];
}
