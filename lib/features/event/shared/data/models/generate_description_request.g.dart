// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_description_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateDescriptionRequest _$GenerateDescriptionRequestFromJson(
  Map<String, dynamic> json,
) => GenerateDescriptionRequest(
  title: json['title'] as String,
  location: json['location'] as String?,
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String?,
  speakers: (json['speakers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  additionalInfo: json['additional_info'] as String?,
  tone: $enumDecode(_$ContentToneEnumMap, json['tone']),
  length: $enumDecode(_$ContentLengthEnumMap, json['length']),
  target: $enumDecode(_$ContentTargetEnumMap, json['target']),
);

Map<String, dynamic> _$GenerateDescriptionRequestToJson(
  GenerateDescriptionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'location': instance.location,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'speakers': instance.speakers,
  'additional_info': instance.additionalInfo,
  'tone': _$ContentToneEnumMap[instance.tone]!,
  'length': _$ContentLengthEnumMap[instance.length]!,
  'target': _$ContentTargetEnumMap[instance.target]!,
};

const _$ContentToneEnumMap = {
  ContentTone.professional: 'PROFESSIONAL',
  ContentTone.friendly: 'FRIENDLY',
  ContentTone.exciting: 'EXCITING',
  ContentTone.formal: 'FORMAL',
  ContentTone.casual: 'CASUAL',
};

const _$ContentLengthEnumMap = {
  ContentLength.short: 'SHORT',
  ContentLength.medium: 'MEDIUM',
  ContentLength.long: 'LONG',
};

const _$ContentTargetEnumMap = {
  ContentTarget.website: 'WEBSITE',
  ContentTarget.facebook: 'FACEBOOK',
  ContentTarget.email: 'EMAIL',
  ContentTarget.general: 'GENERAL',
};
