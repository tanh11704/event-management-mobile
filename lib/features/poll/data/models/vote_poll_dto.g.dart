// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_poll_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VotePollDto _$VotePollDtoFromJson(Map<String, dynamic> json) => VotePollDto(
  optionIds: (json['option_ids'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$VotePollDtoToJson(VotePollDto instance) =>
    <String, dynamic>{'option_ids': instance.optionIds};
