import 'package:event_management/core/utils/json_converters.dart';
import 'package:event_management/features/event/shared/data/models/chat_sender.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  const MessageDto({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  final int id;
  final ChatSender sender;
  final String content;
  @TimestampConverter()
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
