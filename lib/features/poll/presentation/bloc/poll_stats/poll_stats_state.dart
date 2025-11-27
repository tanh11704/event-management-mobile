import 'package:equatable/equatable.dart';
import 'package:event_management/features/poll/data/models/poll_stats_response.dart';

abstract class PollStatsState extends Equatable {
  const PollStatsState();

  @override
  List<Object?> get props => [];
}

class PollStatsInitial extends PollStatsState {
  const PollStatsInitial();
}

class PollStatsLoading extends PollStatsState {
  const PollStatsLoading();
}

class PollStatsSuccess extends PollStatsState {
  const PollStatsSuccess(this.stats);

  final List<PollStatsResponse> stats;

  @override
  List<Object?> get props => [stats];
}

class PollStatsError extends PollStatsState {
  const PollStatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
