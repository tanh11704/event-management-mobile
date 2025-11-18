part of 'create_event_bloc.dart';

abstract class CreateEventState extends Equatable {
  const CreateEventState();

  @override
  List<Object> get props => [];
}

class CreateEventInitial extends CreateEventState {}

class CreateEventLoading extends CreateEventState {}

class CreateEventSuccess extends CreateEventState {
  const CreateEventSuccess(this.event);
  final Event event;

  @override
  List<Object> get props => [event];
}

class CreateEventFailure extends CreateEventState {
  const CreateEventFailure(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
