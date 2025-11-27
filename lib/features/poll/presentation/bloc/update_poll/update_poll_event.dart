import 'package:equatable/equatable.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';

abstract class UpdatePollEvent extends Equatable {
  const UpdatePollEvent();

  @override
  List<Object?> get props => [];
}

class UpdatePollSubmitted extends UpdatePollEvent {
  const UpdatePollSubmitted({
    required this.pollId,
    required this.title,
    required this.pollType,
    required this.startTime,
    required this.endTime,
    required this.options,
  });

  final int pollId;
  final String title;
  final PollType pollType;
  final List<String> options;
  final DateTime startTime;
  final DateTime endTime;

  @override
  List<Object?> get props => [
    pollId,
    title,
    pollType,
    options,
    startTime,
    endTime,
  ];
}
