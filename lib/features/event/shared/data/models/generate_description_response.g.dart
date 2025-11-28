// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_description_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateDescriptionResponse _$GenerateDescriptionResponseFromJson(
  Map<String, dynamic> json,
) => GenerateDescriptionResponse(
  description: json['description'] as String,
  rawText: json['raw_text'] as String,
);

Map<String, dynamic> _$GenerateDescriptionResponseToJson(
  GenerateDescriptionResponse instance,
) => <String, dynamic>{
  'description': instance.description,
  'raw_text': instance.rawText,
};
