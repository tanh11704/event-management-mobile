import 'package:bloc/bloc.dart';
import 'package:event_management/features/poll/data/models/option_dto.dart';
import 'package:event_management/features/poll/data/models/update_poll_dto.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:event_management/features/poll/presentation/bloc/update_poll/update_poll_event.dart';
import 'package:event_management/features/poll/presentation/bloc/update_poll/update_poll_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdatePollBloc extends Bloc<UpdatePollEvent, UpdatePollState> {
  UpdatePollBloc(this._pollRepository) : super(const UpdatePollInitial()) {
    on<UpdatePollSubmitted>(_onSubmitted);
  }

  final PollRepository _pollRepository;

  Future<void> _onSubmitted(
    UpdatePollSubmitted event,
    Emitter<UpdatePollState> emit,
  ) async {
    emit(const UpdatePollLoading());

    try {
      final updatePollDto = UpdatePollDto(
        title: event.title,
        pollType: event.pollType,
        startTime: event.startTime,
        endTime: event.endTime,
        options: event.options
            .map((optionText) => OptionDto(content: optionText))
            .toList(),
      );

      await _pollRepository.updatePoll(event.pollId, updatePollDto);

      emit(const UpdatePollSuccess());
    } catch (e) {
      emit(UpdatePollFailure(e.toString()));
    }
  }
}
