import 'package:equatable/equatable.dart';
import 'package:event_management/features/poll/domain/entities/poll_option.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';

/// Entity đại diện cho một poll
class Poll extends Equatable {
  const Poll({
    required this.question,
    required this.pollType,
    required this.options,
    required this.eventId,
    this.id,
    this.isActive = true,
    this.createdAt,
    this.totalVotes = 0,
  });

  final int? id;
  final String question;
  final PollType pollType;
  final List<PollOption> options;
  final int eventId;
  final bool isActive;
  final DateTime? createdAt;
  final int totalVotes;

  Poll copyWith({
    int? id,
    String? question,
    PollType? pollType,
    List<PollOption>? options,
    int? eventId,
    bool? isActive,
    DateTime? createdAt,
    int? totalVotes,
  }) {
    return Poll(
      id: id ?? this.id,
      question: question ?? this.question,
      pollType: pollType ?? this.pollType,
      options: options ?? this.options,
      eventId: eventId ?? this.eventId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      totalVotes: totalVotes ?? this.totalVotes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    question,
    pollType,
    options,
    eventId,
    isActive,
    createdAt,
    totalVotes,
  ];
}
