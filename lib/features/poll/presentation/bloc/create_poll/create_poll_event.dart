import 'package:equatable/equatable.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';

abstract class CreatePollEvent extends Equatable {
  const CreatePollEvent();

  @override
  List<Object?> get props => [];
}

class CreatePollPollTypeChanged extends CreatePollEvent {
  const CreatePollPollTypeChanged(this.pollType);

  final PollType pollType;

  @override
  List<Object?> get props => [pollType];
}

class CreatePollSubmitted extends CreatePollEvent {
  const CreatePollSubmitted({
    required this.title,
    required this.pollType,
    required this.options,
    required this.eventId,
    required this.startTime,
    required this.endTime,
  });

  final String title;
  final PollType pollType;
  final List<String> options;
  final int eventId;
  final DateTime startTime;
  final DateTime endTime;

  @override
  List<Object?> get props => [
    title,
    pollType,
    options,
    eventId,
    startTime,
    endTime,
  ];
}
