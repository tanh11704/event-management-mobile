import 'package:equatable/equatable.dart';

abstract class PollListEvent extends Equatable {
  const PollListEvent();

  @override
  List<Object?> get props => [];
}

class PollListFetched extends PollListEvent {
  const PollListFetched(this.eventId);

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class PollListRefreshed extends PollListEvent {
  const PollListRefreshed(this.eventId);

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class PollClosed extends PollListEvent {
  const PollClosed(this.pollId, this.eventId);

  final int pollId;
  final int eventId;

  @override
  List<Object?> get props => [pollId, eventId];
}
