import 'package:equatable/equatable.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';

abstract class PollListState extends Equatable {
  const PollListState();

  @override
  List<Object?> get props => [];
}

class PollListInitial extends PollListState {
  const PollListInitial();
}

class PollListLoading extends PollListState {
  const PollListLoading();
}

class PollListSuccess extends PollListState {
  const PollListSuccess(this.polls);

  final List<PollResponse> polls;

  @override
  List<Object?> get props => [polls];
}

class PollListError extends PollListState {
  const PollListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PollCloseSuccess extends PollListState {
  const PollCloseSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
