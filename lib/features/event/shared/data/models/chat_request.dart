import 'package:json_annotation/json_annotation.dart';

part 'chat_request.g.dart';

@JsonSerializable()
class ChatRequest {
  const ChatRequest({required this.eventId, required this.message});

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);

  @JsonKey(name: 'event_id')
  final int eventId;
  final String message;

  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}
