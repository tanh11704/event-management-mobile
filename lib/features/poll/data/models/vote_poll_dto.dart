import 'package:json_annotation/json_annotation.dart';

part 'vote_poll_dto.g.dart';

@JsonSerializable()
class VotePollDto {
  const VotePollDto({required this.optionIds});

  factory VotePollDto.fromJson(Map<String, dynamic> json) =>
      _$VotePollDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VotePollDtoToJson(this);

  @JsonKey(name: 'option_ids')
  final List<int> optionIds;
}

