// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseDto<T> _$PageResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PageResponseDto<T>(
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
