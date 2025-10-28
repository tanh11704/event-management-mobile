// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_page_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitPageResponseDto _$UnitPageResponseDtoFromJson(Map<String, dynamic> json) =>
    UnitPageResponseDto(
      content: (json['content'] as List<dynamic>)
          .map((e) => UnitResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalElements: (json['total_elements'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      first: json['first'] as bool,
      last: json['last'] as bool,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
      numberOfElements: (json['number_of_elements'] as num).toInt(),
      empty: json['empty'] as bool,
    );

Map<String, dynamic> _$UnitPageResponseDtoToJson(
  UnitPageResponseDto instance,
) => <String, dynamic>{
  'content': instance.content,
  'page': instance.page,
  'size': instance.size,
  'total_elements': instance.totalElements,
  'total_pages': instance.totalPages,
  'first': instance.first,
  'last': instance.last,
  'has_next': instance.hasNext,
  'has_previous': instance.hasPrevious,
  'number_of_elements': instance.numberOfElements,
  'empty': instance.empty,
};
