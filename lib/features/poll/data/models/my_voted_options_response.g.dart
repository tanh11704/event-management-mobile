// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_voted_options_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyVotedOptionsResponse _$MyVotedOptionsResponseFromJson(
  Map<String, dynamic> json,
) => MyVotedOptionsResponse(
  optionIds: (json['optionIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$MyVotedOptionsResponseToJson(
  MyVotedOptionsResponse instance,
) => <String, dynamic>{'optionIds': instance.optionIds};
