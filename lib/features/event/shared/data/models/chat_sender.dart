import 'package:json_annotation/json_annotation.dart';

enum ChatSender {
  @JsonValue('USER')
  user,
  @JsonValue('BOT')
  bot,
}
