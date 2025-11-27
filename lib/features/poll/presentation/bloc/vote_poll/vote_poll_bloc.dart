import 'package:bloc/bloc.dart';
import 'package:event_management/features/poll/data/models/vote_poll_dto.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:event_management/features/poll/presentation/bloc/vote_poll/vote_poll_event.dart';
import 'package:event_management/features/poll/presentation/bloc/vote_poll/vote_poll_state.dart';
import 'package:injectable/injectable.dart';

/// BLoC để quản lý state của việc bỏ phiếu poll
@injectable
class VotePollBloc extends Bloc<VotePollEvent, VotePollState> {
  VotePollBloc(this._pollRepository) : super(const VotePollInitial()) {
    on<VotePollFetched>(_onFetched);
    on<VotePollSubmitted>(_onSubmitted);
    on<MyVotedOptionsFetched>(_onMyVotedOptionsFetched);
  }

  final PollRepository _pollRepository;

  Future<void> _onFetched(
    VotePollFetched event,
    Emitter<VotePollState> emit,
  ) async {
    emit(const VotePollLoading());

    try {
      final poll = await _pollRepository.getPoll(event.pollId);
      emit(VotePollSuccess(poll));
    } catch (e) {
      emit(VotePollError(e.toString()));
    }
  }

  Future<void> _onSubmitted(
    VotePollSubmitted event,
    Emitter<VotePollState> emit,
  ) async {
    emit(const VotePollLoading());

    try {
      final voteDto = VotePollDto(optionIds: event.optionIds);
      final poll = await _pollRepository.votePoll(event.pollId, voteDto);
      emit(VotePollSuccess(poll));
    } catch (e) {
      emit(VotePollError(e.toString()));
    }
  }

  Future<void> _onMyVotedOptionsFetched(
    MyVotedOptionsFetched event,
    Emitter<VotePollState> emit,
  ) async {
    try {
      final myVotedOptions = await _pollRepository.getMyVotedOptions(
        event.pollId,
      );
      emit(MyVotedOptionsSuccess(myVotedOptions));
    } catch (e) {
      // Don't emit error state, just silently fail
      // This is optional data
    }
  }
}
