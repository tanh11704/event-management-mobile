import 'package:bloc/bloc.dart';
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/event_management/event_management_event.dart';
import 'package:event_management/features/event/event_management/presentation/bloc/event_management/event_management_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventManagementBloc
    extends Bloc<EventManagementEvent, EventManagementState> {
  EventManagementBloc({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(EventManagementInitial()) {
    on<EventManagementGetQrCheck>(_onGetQrCheck);
    on<EventManagementRefreshQrCheck>(_onRefreshQrCheck);
  }

  final EventRepository _eventRepository;

  Future<void> _onGetQrCheck(
    EventManagementGetQrCheck event,
    Emitter<EventManagementState> emit,
  ) async {
    emit(const EventManagementQrCheckLoading());

    try {
      final qrCodeBytes = await _eventRepository.getQrCheck(event.eventId);
      emit(EventManagementQrCheckSuccess(qrCodeBytes: qrCodeBytes));
    } catch (e) {
      emit(
        EventManagementQrCheckError(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRefreshQrCheck(
    EventManagementRefreshQrCheck event,
    Emitter<EventManagementState> emit,
  ) async {
    // Keep current state if it's a success state while loading
    if (state is EventManagementQrCheckSuccess) {
      emit(const EventManagementQrCheckLoading(isRefreshing: true));
    } else {
      emit(const EventManagementQrCheckLoading());
    }

    try {
      final qrCodeBytes = await _eventRepository.getQrCheck(event.eventId);
      emit(EventManagementQrCheckSuccess(qrCodeBytes: qrCodeBytes));
    } catch (e) {
      emit(
        EventManagementQrCheckError(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
