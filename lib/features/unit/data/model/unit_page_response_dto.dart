import 'package:event_management/features/unit/data/model/unit_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unit_page_response_dto.g.dart';

@JsonSerializable()
class UnitPageResponseDto {
  UnitPageResponseDto({
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

  factory UnitPageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UnitPageResponseDtoFromJson(json);

  @JsonKey(name: 'content')
  final List<UnitResponseDto> content;

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

  Map<String, dynamic> toJson() => _$UnitPageResponseDtoToJson(this);
}
