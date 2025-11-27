// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionResponse _$OptionResponseFromJson(Map<String, dynamic> json) =>
    OptionResponse(
      id: (json['id'] as num).toInt(),
      text: json['content'] as String,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
    );
