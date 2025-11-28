// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponse<T> _$PageResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PageResponse<T>(
  content: (json['content'] as List<dynamic>).map(fromJsonT).toList(),
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

Map<String, dynamic> _$PageResponseToJson<T>(
  PageResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'content': instance.content.map(toJsonT).toList(),
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
