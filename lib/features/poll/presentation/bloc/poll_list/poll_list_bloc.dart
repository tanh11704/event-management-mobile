import 'package:bloc/bloc.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_event.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_list/poll_list_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class PollListBloc extends Bloc<PollListEvent, PollListState> {
  PollListBloc(this._pollRepository) : super(const PollListInitial()) {
    on<PollListFetched>(_onFetched);
    on<PollListRefreshed>(_onRefreshed);
    on<PollClosed>(_onClosed);
  }

  final PollRepository _pollRepository;

  Future<void> _onFetched(
    PollListFetched event,
    Emitter<PollListState> emit,
  ) async {
    emit(const PollListLoading());

    try {
      final polls = await _pollRepository.getPollsByEvent(event.eventId);
      emit(PollListSuccess(polls));
    } catch (e) {
      emit(PollListError(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    PollListRefreshed event,
    Emitter<PollListState> emit,
  ) async {
    // Silent refresh - keep current state if successful
    if (state is PollListSuccess) {
      try {
        final polls = await _pollRepository.getPollsByEvent(event.eventId);
        emit(PollListSuccess(polls));
      } catch (e) {
        // Don't emit error on silent refresh
      }
    } else {
      // If not in success state, do normal fetch
      add(PollListFetched(event.eventId));
    }
  }

  Future<void> _onClosed(PollClosed event, Emitter<PollListState> emit) async {
    try {
      await _pollRepository.closePoll(event.pollId);
      emit(const PollCloseSuccess('Đóng poll thành công!'));
      // Refresh list after closing
      add(PollListRefreshed(event.eventId));
    } catch (e) {
      emit(PollListError('Không thể đóng poll: $e'));
    }
  }
}
