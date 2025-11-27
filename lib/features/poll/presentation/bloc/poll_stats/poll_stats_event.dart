import 'package:equatable/equatable.dart';

abstract class PollStatsEvent extends Equatable {
  const PollStatsEvent();

  @override
  List<Object?> get props => [];
}

class PollStatsFetched extends PollStatsEvent {
  const PollStatsFetched(this.eventId);

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}

class PollStatsRefreshed extends PollStatsEvent {
  const PollStatsRefreshed(this.eventId);

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}
