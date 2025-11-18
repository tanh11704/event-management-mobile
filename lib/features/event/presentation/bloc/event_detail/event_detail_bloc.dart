import 'package:bloc/bloc.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/domain/usecases/get_event_detail_usecase.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      _getEventDetailUseCase = GetEventDetailUseCase(eventRepository),
      super(EventDetailInitial()) {
    on<EventDetailFetch>(_onFetch);
    on<EventDetailJoin>(_onJoin);
    on<EventDetailUnjoin>(_onUnjoin);
  }

  final EventRepository _eventRepository;
  final GetEventDetailUseCase _getEventDetailUseCase;

  Future<void> _onFetch(
    EventDetailFetch event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is! EventDetailSuccess) {
      emit(EventDetailLoading());
    }

    try {
      final eventDetail = await _getEventDetailUseCase(event.eventId);
      emit(EventDetailSuccess(eventDetail: eventDetail));
    } catch (e) {
      emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onJoin(
    EventDetailJoin event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      emit(currentState.copyWith(isJoining: true));

      try {
        await _eventRepository.joinEvent(event.eventToken);

        final newEventDetail = await _getEventDetailUseCase(
          currentState.eventDetail.id,
        );

        emit(EventDetailSuccess(eventDetail: newEventDetail));
      } catch (e) {
        emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
        emit(currentState.copyWith(isJoining: false));
      }
    }
  }

  Future<void> _onUnjoin(
    EventDetailUnjoin event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      emit(currentState.copyWith(isJoining: true));

      try {
        await _eventRepository.unjoinEvent(event.eventId);

        final newEventDetail = await _getEventDetailUseCase(
          currentState.eventDetail.id,
        );

        emit(EventDetailSuccess(eventDetail: newEventDetail));
      } catch (e) {
        emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
        emit(currentState.copyWith(isJoining: false));
      }
    }
  }
}
