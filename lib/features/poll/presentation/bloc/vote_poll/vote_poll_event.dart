import 'package:equatable/equatable.dart';

abstract class VotePollEvent extends Equatable {
  const VotePollEvent();

  @override
  List<Object?> get props => [];
}

class VotePollFetched extends VotePollEvent {
  const VotePollFetched(this.pollId);

  final int pollId;

  @override
  List<Object?> get props => [pollId];
}

class VotePollSubmitted extends VotePollEvent {
  const VotePollSubmitted({required this.pollId, required this.optionIds});

  final int pollId;
  final List<int> optionIds;

  @override
  List<Object?> get props => [pollId, optionIds];
}

class MyVotedOptionsFetched extends VotePollEvent {
  const MyVotedOptionsFetched(this.pollId);

  final int pollId;

  @override
  List<Object?> get props => [pollId];
}
