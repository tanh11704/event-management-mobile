import 'package:bloc/bloc.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc//edit_event_state.dart';
import 'package:event_management/features/event/presentation/bloc/edit_event_event.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class EditEventBloc extends Bloc<EditEventEvent, EditEventState> {
  EditEventBloc(this._eventRepository) : super(EditEventInitial()) {
    on<EditEventSubmitted>(_onSubmitted);
  }
  final EventRepository _eventRepository;

  Future<void> _onSubmitted(
    EditEventSubmitted event,
    Emitter<EditEventState> emit,
  ) async {
    // 1. Emit trạng thái Loading
    emit(EditEventLoading());
    try {
      //2 file: `event_repository.dart` và `event_repository_impl.dart`

      await _eventRepository.editEvent(
        id: event.eventId,
        name: event.name,
        description: event.description,
        location: event.location,
        startDate: event.startDate,
        endDate: event.endDate,
        newBanner: event.newBannerImage,
      );

      await Future.delayed(const Duration(seconds: 1));

      // 3. Emit Success
      emit(EditEventSuccess());
    } catch (e) {
      // 4. Emit Failure
      emit(EditEventFailure(e.toString()));
    }
  }
}
