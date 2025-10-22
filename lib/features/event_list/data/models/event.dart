import 'package:equatable/equatable.dart';
import 'package:event_management/features/event_list/data/models/event_status.dart';
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
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  final int id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final EventStatus status;
  final String? banner;
  final String? urlDocs;
  final int? maxParticipants;
  final int? currentParticipants;
  final DateTime? updatedAt;
  final DateTime createdAt;
  final bool? isRegistered;
  final String? createdByName;
  final String? managerName;

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
