import 'package:json_annotation/json_annotation.dart';

part 'page_response.g.dart';

/// Generic PageResponse model cho pagination
@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  const PageResponse({
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

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResponseFromJson(json, fromJsonT);

  @JsonKey(name: 'content')
  final List<T> content;

  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'size')
  final int size;

  @JsonKey(name: 'total_elements')
  final int totalElements;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  @JsonKey(name: 'first')
  final bool first;

  @JsonKey(name: 'last')
  final bool last;

  @JsonKey(name: 'has_next')
  final bool hasNext;

  @JsonKey(name: 'has_previous')
  final bool hasPrevious;

  @JsonKey(name: 'number_of_elements')
  final int numberOfElements;

  @JsonKey(name: 'empty')
  final bool empty;

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageResponseToJson(this, toJsonT);
}
