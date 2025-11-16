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
  }

  final EventRepository _eventRepository;
  final GetEventDetailUseCase _getEventDetailUseCase;

  Future<void> _onFetch(
    EventDetailFetch event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(EventDetailLoading());
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
    try {
      await _eventRepository.joinEvent(event.eventToken);
      // Refresh event detail after joining
      if (state is EventDetailSuccess) {
        final currentState = state as EventDetailSuccess;
        add(EventDetailFetch(eventId: currentState.eventDetail.id));
      }
    } catch (e) {
      emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
