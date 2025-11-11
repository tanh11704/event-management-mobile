import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_management/features/event/data/datasources/event_sse_service.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_list_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventListBloc extends Bloc<EventListEvent, EventListState> {
  EventListBloc({
    required EventRepository eventRepository,
    required EventSseService eventSseService,
  }) : _eventRepository = eventRepository,
       _eventSseService = eventSseService,
       super(EventListInitial()) {
    on<EventListFetchAll>(_onFetchAll);
    on<EventListFetchManaged>(_onFetchManaged);
    on<EventListRefresh>(_onRefresh);
    on<EventListFilterChanged>(_onFilterChanged);
    on<EventListSearchChanged>(_onSearchChanged);
    on<EventListLoadMore>(_onLoadMore);
    on<EventListSseConnected>(_onSseConnected);
    on<EventListSseReceived>(_onSseReceived);

    // Subscribe to SSE
    _sseSubscription = _eventSseService.subscribeToEvents().listen(
      (event) {
        if (event.name == 'event_list_updated') {
          add(const EventListSseReceived());
        }
      },
      onError: (error) {
        // Handle SSE connection errors silently
      },
    );
  }

  final EventRepository _eventRepository;
  final EventSseService _eventSseService;
  StreamSubscription<SseEvent>? _sseSubscription;

  // Cache cho pagination
  int _currentPage = 0;
  EventStatus? _currentStatus;
  String? _currentSearch;

  Future<void> _onFetchAll(
    EventListFetchAll event,
    Emitter<EventListState> emit,
  ) async {
    emit(EventListLoading());

    _currentPage = event.page;
    _currentStatus = event.status;
    _currentSearch = event.search;

    try {
      final result = await _eventRepository.getAllEvents(
        page: event.page,
        status: event.status,
        search: event.search,
      );

      if (result.events.isEmpty) {
        emit(EventListEmpty(counters: result.counters));
      } else {
        emit(
          EventListLoaded(
            events: result.events,
            counters: result.counters,
            hasNextPage: result.hasNext,
          ),
        );
      }
    } catch (e) {
      emit(EventListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFetchManaged(
    EventListFetchManaged event,
    Emitter<EventListState> emit,
  ) async {
    emit(EventListLoading());

    _currentPage = event.page;
    _currentStatus = event.status;
    _currentSearch = event.search;

    try {
      final result = await _eventRepository.getManagedEvents(
        page: event.page,
        status: event.status,
        search: event.search,
      );

      if (result.events.isEmpty) {
        emit(EventListEmpty(counters: result.counters));
      } else {
        emit(
          EventListLoaded(
            events: result.events,
            counters: result.counters,
            hasNextPage: result.hasNext,
          ),
        );
      }
    } catch (e) {
      emit(EventListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(
    EventListRefresh event,
    Emitter<EventListState> emit,
  ) async {
    _currentPage = 0;

    if (event.isManaged) {
      add(
        EventListFetchManaged(status: _currentStatus, search: _currentSearch),
      );
    } else {
      add(EventListFetchAll(status: _currentStatus, search: _currentSearch));
    }
  }

  Future<void> _onFilterChanged(
    EventListFilterChanged event,
    Emitter<EventListState> emit,
  ) async {
    _currentPage = 0;
    _currentStatus = event.status;

    if (event.isManaged) {
      add(EventListFetchManaged(status: event.status, search: _currentSearch));
    } else {
      add(EventListFetchAll(status: event.status, search: _currentSearch));
    }
  }

  Future<void> _onSearchChanged(
    EventListSearchChanged event,
    Emitter<EventListState> emit,
  ) async {
    _currentPage = 0;
    _currentSearch = event.search;

    if (event.isManaged) {
      add(EventListFetchManaged(status: _currentStatus, search: event.search));
    } else {
      add(EventListFetchAll(status: _currentStatus, search: event.search));
    }
  }

  Future<void> _onLoadMore(
    EventListLoadMore event,
    Emitter<EventListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EventListLoaded || !currentState.hasNextPage) {
      return;
    }

    final nextPage = _currentPage + 1;

    try {
      final result = event.isManaged
          ? await _eventRepository.getManagedEvents(
              page: nextPage,
              status: _currentStatus,
              search: _currentSearch,
            )
          : await _eventRepository.getAllEvents(
              page: nextPage,
              status: _currentStatus,
              search: _currentSearch,
            );

      _currentPage = nextPage;

      emit(
        currentState.copyWith(
          events: [...currentState.events, ...result.events],
          hasNextPage: result.hasNext,
        ),
      );
    } catch (e) {
      // Giữ nguyên state hiện tại nếu load more thất bại
    }
  }

  void _onSseConnected(
    EventListSseConnected event,
    Emitter<EventListState> emit,
  ) {
    // SSE connected successfully
  }

  void _onSseReceived(
    EventListSseReceived event,
    Emitter<EventListState> emit,
  ) {
    // Auto refresh when SSE event received
    // Determine if currently viewing managed or all events
    final isManaged = state is EventListLoaded;
    if (isManaged) {
      add(const EventListRefresh(isManaged: false));
    }
  }

  @override
  Future<void> close() {
    _sseSubscription?.cancel();
    _eventSseService.dispose();
    return super.close();
  }
}
