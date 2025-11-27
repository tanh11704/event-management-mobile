import 'package:bloc/bloc.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_event.dart';
import 'package:event_management/features/poll/presentation/bloc/poll_stats/poll_stats_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class PollStatsBloc extends Bloc<PollStatsEvent, PollStatsState> {
  PollStatsBloc(this._pollRepository) : super(const PollStatsInitial()) {
    on<PollStatsFetched>(_onFetched);
    on<PollStatsRefreshed>(_onRefreshed);
  }

  final PollRepository _pollRepository;

  Future<void> _onFetched(
    PollStatsFetched event,
    Emitter<PollStatsState> emit,
  ) async {
    emit(const PollStatsLoading());

    try {
      final stats = await _pollRepository.getPollStatsByEvent(event.eventId);
      emit(PollStatsSuccess(stats));
    } catch (e) {
      emit(PollStatsError(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    PollStatsRefreshed event,
    Emitter<PollStatsState> emit,
  ) async {
    // Silent refresh - keep current state if successful
    if (state is PollStatsSuccess) {
      try {
        final stats = await _pollRepository.getPollStatsByEvent(event.eventId);
        emit(PollStatsSuccess(stats));
      } catch (e) {
        // Don't emit error on silent refresh
      }
    } else {
      // If not in success state, do normal fetch
      add(PollStatsFetched(event.eventId));
    }
  }
}
