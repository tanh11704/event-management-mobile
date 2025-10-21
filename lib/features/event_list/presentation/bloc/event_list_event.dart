import 'package:equatable/equatable.dart';

abstract class EventListEvent extends Equatable {
  const EventListEvent();

  @override
  List<Object> get props => [];
}

class EventListFetch extends EventListEvent {}

class EventListRefreshed extends EventListEvent {}
