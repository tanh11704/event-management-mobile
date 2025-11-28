// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  id: (json['id'] as num).toInt(),
  sender: $enumDecode(_$ChatSenderEnumMap, json['sender']),
  content: json['content'] as String,
  timestamp: const TimestampConverter().fromJson(
    (json['timestamp'] as num).toDouble(),
  ),
);

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': _$ChatSenderEnumMap[instance.sender]!,
      'content': instance.content,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };

const _$ChatSenderEnumMap = {ChatSender.user: 'USER', ChatSender.bot: 'BOT'};
