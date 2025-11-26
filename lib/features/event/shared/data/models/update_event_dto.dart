import 'package:json_annotation/json_annotation.dart';

part 'update_event_dto.g.dart';

@JsonSerializable()
class UpdateEventDto {
  UpdateEventDto({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.location,
    required this.maxParticipants,
    required this.urlDocs,
  });

  factory UpdateEventDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateEventDtoFromJson(json);

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'start_time')
  final String startTime;

  @JsonKey(name: 'end_time')
  final String endTime;

  @JsonKey(name: 'location')
  final String location;

  @JsonKey(name: 'max_participants')
  final int maxParticipants;

  @JsonKey(name: 'url_docs')
  final String urlDocs;

  Map<String, dynamic> toJson() => _$UpdateEventDtoToJson(this);
}
