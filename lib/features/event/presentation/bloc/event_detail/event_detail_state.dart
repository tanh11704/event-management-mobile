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
  const EventDetailSuccess({required this.eventDetail});

  final EventDetailResponse eventDetail;

  @override
  List<Object?> get props => [eventDetail];
}

class EventDetailError extends EventDetailState {
  const EventDetailError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
