import 'package:json_annotation/json_annotation.dart';

part 'page_response_dto.g.dart';

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PageResponseDto<T> {
  const PageResponseDto({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.hasNext,
    required this.hasPrevious,
    required this.numberOfElements,
    required this.empty,
  });

  factory PageResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResponseDtoFromJson(json, fromJsonT);

  final List<T> content;
  final int page;
  final int size;

  @JsonKey(name: 'total_elements')
  final int totalElements;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  final bool first;
  final bool last;

  @JsonKey(name: 'has_next')
  final bool hasNext;

  @JsonKey(name: 'has_previous')
  final bool hasPrevious;

  @JsonKey(name: 'number_of_elements')
  final int numberOfElements;

  final bool empty;
}
