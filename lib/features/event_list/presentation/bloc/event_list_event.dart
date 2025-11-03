import 'package:equatable/equatable.dart';
import 'package:event_management/features/event_list/data/models/event_status.dart';

abstract class EventListEvent extends Equatable {
  const EventListEvent();

  @override
  List<Object?> get props => [];
}

class EventListFetchAll extends EventListEvent {
  const EventListFetchAll({this.page = 0, this.status, this.search});

  final int page;
  final EventStatus? status;
  final String? search;

  @override
  List<Object?> get props => [page, status, search];
}

class EventListFetchManaged extends EventListEvent {
  const EventListFetchManaged({this.page = 0, this.status, this.search});

  final int page;
  final EventStatus? status;
  final String? search;

  @override
  List<Object?> get props => [page, status, search];
}

class EventListRefresh extends EventListEvent {
  const EventListRefresh({required this.isManaged});

  final bool isManaged;

  @override
  List<Object?> get props => [isManaged];
}

class EventListFilterChanged extends EventListEvent {
  const EventListFilterChanged({required this.status, required this.isManaged});

  final EventStatus? status;
  final bool isManaged;

  @override
  List<Object?> get props => [status, isManaged];
}

class EventListSearchChanged extends EventListEvent {
  const EventListSearchChanged({required this.search, required this.isManaged});

  final String? search;
  final bool isManaged;

  @override
  List<Object?> get props => [search, isManaged];
}

class EventListLoadMore extends EventListEvent {
  const EventListLoadMore({required this.isManaged});

  final bool isManaged;

  @override
  List<Object?> get props => [isManaged];
}

class EventListSseConnected extends EventListEvent {
  const EventListSseConnected();
}

class EventListSseReceived extends EventListEvent {
  const EventListSseReceived();
}
