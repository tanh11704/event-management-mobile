import 'package:bloc/bloc.dart';
import 'package:event_management/features/poll/data/models/create_poll_dto.dart';
import 'package:event_management/features/poll/data/models/option_dto.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:event_management/features/poll/presentation/bloc/create_poll/create_poll_event.dart';
import 'package:event_management/features/poll/presentation/bloc/create_poll/create_poll_state.dart';
import 'package:injectable/injectable.dart';

/// BLoC để quản lý state của việc tạo poll
@injectable
class CreatePollBloc extends Bloc<CreatePollEvent, CreatePollState> {
  CreatePollBloc(this._pollRepository) : super(const CreatePollInitial()) {
    on<CreatePollPollTypeChanged>(_onPollTypeChanged);
    on<CreatePollSubmitted>(_onSubmitted);
  }

  final PollRepository _pollRepository;

  void _onPollTypeChanged(
    CreatePollPollTypeChanged event,
    Emitter<CreatePollState> emit,
  ) {
    // Poll type được quản lý ở UI level, không cần emit state mới
  }

  Future<void> _onSubmitted(
    CreatePollSubmitted event,
    Emitter<CreatePollState> emit,
  ) async {
    emit(const CreatePollLoading());

    try {
      final pollDto = CreatePollDto(
        eventId: event.eventId,
        title: event.title,
        pollType: event.pollType,
        startTime: event.startTime,
        endTime: event.endTime,
        options: event.options
            .map((optionText) => OptionDto(content: optionText))
            .toList(),
      );

      await _pollRepository.createPoll(pollDto);

      emit(const CreatePollSuccess());
    } catch (e) {
      emit(CreatePollFailure(e.toString()));
    }
  }
}
