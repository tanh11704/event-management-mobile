import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'option_response.g.dart';

@JsonSerializable(createToJson: false)
class OptionResponse extends Equatable {
  const OptionResponse({
    required this.id,
    required this.text,
    this.voteCount = 0,
  });

  factory OptionResponse.fromJson(Map<String, dynamic> json) =>
      _$OptionResponseFromJson(json);

  final int id;

  @JsonKey(name: 'content')
  final String text;

  @JsonKey(name: 'vote_count')
  final int voteCount;

  @override
  List<Object?> get props => [id, text, voteCount];
}
