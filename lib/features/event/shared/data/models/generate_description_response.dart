import 'package:json_annotation/json_annotation.dart';

part 'generate_description_response.g.dart';

@JsonSerializable()
class GenerateDescriptionResponse {
  const GenerateDescriptionResponse({
    required this.description,
    required this.rawText,
  });

  factory GenerateDescriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateDescriptionResponseFromJson(json);

  final String description;
  @JsonKey(name: 'raw_text')
  final String rawText;

  Map<String, dynamic> toJson() => _$GenerateDescriptionResponseToJson(this);
}
