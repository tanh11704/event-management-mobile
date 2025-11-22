import 'package:json_annotation/json_annotation.dart';

part 'import_participants_response.g.dart';

@JsonSerializable(createToJson: false)
class ImportParticipantsResponse {
  const ImportParticipantsResponse({
    required this.jobId,
    required this.status,
    required this.message,
  });

  factory ImportParticipantsResponse.fromJson(Map<String, dynamic> json) =>
      _$ImportParticipantsResponseFromJson(json);

  @JsonKey(name: 'job_id')
  final int jobId;

  final String status;

  final String message;
}
