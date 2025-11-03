import 'package:json_annotation/json_annotation.dart';

part 'message_response.g.dart';

@JsonSerializable()
class MessageResponse {
  const MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  @JsonKey(name: 'message')
  final String message;

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}
