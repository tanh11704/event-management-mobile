import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/shared/data/models/participant.dart';

/// States for Check-in History BLoC.
abstract class CheckInHistoryState extends Equatable {
  const CheckInHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class CheckInHistoryInitial extends CheckInHistoryState {}

/// Loading state.
class CheckInHistoryLoading extends CheckInHistoryState {
  const CheckInHistoryLoading();

  @override
  List<Object?> get props => [];
}

/// Success state with check-in history and statistics.
class CheckInHistorySuccess extends CheckInHistoryState {
  const CheckInHistorySuccess({
    required this.checkInHistory,
    required this.totalParticipants,
    required this.checkedInCount,
    this.isConnected = false,
  });

  final List<ParticipantInfo> checkInHistory;
  final int totalParticipants;
  final int checkedInCount;
  final bool isConnected;

  int get notCheckedInCount => totalParticipants - checkedInCount;

  double get checkInRate {
    if (totalParticipants == 0) return 0;
    return checkedInCount / totalParticipants;
  }

  @override
  List<Object?> get props => [
    checkInHistory,
    totalParticipants,
    checkedInCount,
    isConnected,
  ];

  CheckInHistorySuccess copyWith({
    List<ParticipantInfo>? checkInHistory,
    int? totalParticipants,
    int? checkedInCount,
    bool? isConnected,
  }) {
    return CheckInHistorySuccess(
      checkInHistory: checkInHistory ?? this.checkInHistory,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      checkedInCount: checkedInCount ?? this.checkedInCount,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

/// Error state.
class CheckInHistoryError extends CheckInHistoryState {
  const CheckInHistoryError({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}
