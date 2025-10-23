import 'package:json_annotation/json_annotation.dart';

part 'page_response_model.g.dart';

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PageResponseModel<T> {
  const PageResponseModel({
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

  factory PageResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResponseModelFromJson(json, fromJsonT);

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final bool hasNext;
  final bool hasPrevious;
  final int numberOfElements;
  final bool empty;
}
