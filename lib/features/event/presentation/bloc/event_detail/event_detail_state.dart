import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();

  @override
  List<Object?> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailSuccess extends EventDetailState {
  const EventDetailSuccess({required this.eventDetail, this.isJoining = false});

  final EventDetailResponse eventDetail;
  final bool isJoining;

  EventDetailSuccess copyWith({
    EventDetailResponse? eventDetail,
    bool? isJoining,
  }) {
    return EventDetailSuccess(
      eventDetail: eventDetail ?? this.eventDetail,
      isJoining: isJoining ?? this.isJoining,
    );
  }

  @override
  List<Object> get props => [eventDetail, isJoining];
}

class EventDetailError extends EventDetailState {
  const EventDetailError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
