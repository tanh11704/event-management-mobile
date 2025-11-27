import 'package:json_annotation/json_annotation.dart';

part 'option_dto.g.dart';

@JsonSerializable()
class OptionDto {
  const OptionDto({required this.content});

  factory OptionDto.fromJson(Map<String, dynamic> json) =>
      _$OptionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OptionDtoToJson(this);

  final String content;
}
