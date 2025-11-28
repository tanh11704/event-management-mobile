import 'package:json_annotation/json_annotation.dart';

part 'generate_description_request.g.dart';

@JsonSerializable()
class GenerateDescriptionRequest {
  const GenerateDescriptionRequest({
    required this.title,
    this.location,
    required this.startTime,
    this.endTime,
    this.speakers,
    this.additionalInfo,
    required this.tone,
    required this.length,
    required this.target,
  });

  final String title;
  final String? location;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  final List<String>? speakers;
  @JsonKey(name: 'additional_info')
  final String? additionalInfo;
  final ContentTone tone;
  final ContentLength length;
  final ContentTarget target;

  factory GenerateDescriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateDescriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateDescriptionRequestToJson(this);
}

enum ContentTone {
  @JsonValue('PROFESSIONAL')
  professional,
  @JsonValue('FRIENDLY')
  friendly,
  @JsonValue('EXCITING')
  exciting,
  @JsonValue('FORMAL')
  formal,
  @JsonValue('CASUAL')
  casual,
}

enum ContentLength {
  @JsonValue('SHORT')
  short,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('LONG')
  long,
}

enum ContentTarget {
  @JsonValue('WEBSITE')
  website,
  @JsonValue('FACEBOOK')
  facebook,
  @JsonValue('EMAIL')
  email,
  @JsonValue('GENERAL')
  general,
}
