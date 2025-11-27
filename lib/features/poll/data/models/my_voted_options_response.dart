import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_voted_options_response.g.dart';

@JsonSerializable()
class MyVotedOptionsResponse extends Equatable {
  const MyVotedOptionsResponse({required this.optionIds});

  factory MyVotedOptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyVotedOptionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyVotedOptionsResponseToJson(this);

  @JsonKey(name: 'optionIds')
  final List<int> optionIds;

  @override
  List<Object?> get props => [optionIds];
}
