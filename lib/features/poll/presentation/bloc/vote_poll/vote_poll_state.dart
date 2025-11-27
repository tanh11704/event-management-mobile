import 'package:equatable/equatable.dart';
import 'package:event_management/features/poll/data/models/my_voted_options_response.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';

abstract class VotePollState extends Equatable {
  const VotePollState();

  @override
  List<Object?> get props => [];
}

class VotePollInitial extends VotePollState {
  const VotePollInitial();
}

class VotePollLoading extends VotePollState {
  const VotePollLoading();
}

class VotePollSuccess extends VotePollState {
  const VotePollSuccess(this.poll);

  final PollResponse poll;

  @override
  List<Object?> get props => [poll];
}

class VotePollError extends VotePollState {
  const VotePollError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MyVotedOptionsSuccess extends VotePollState {
  const MyVotedOptionsSuccess(this.myVotedOptions);

  final MyVotedOptionsResponse myVotedOptions;

  @override
  List<Object?> get props => [myVotedOptions];
}
