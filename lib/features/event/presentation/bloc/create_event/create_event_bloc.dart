import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/data/models/create_event_dto.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';

part 'create_event_event.dart';
part 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  CreateEventBloc({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(CreateEventInitial()) {
    on<CreateEventSubmitted>(_onCreateEventSubmitted);
  }
  final EventRepository _eventRepository;

  Future<void> _onCreateEventSubmitted(
    CreateEventSubmitted event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(CreateEventLoading());
    try {
      final created = await _eventRepository.createEvent(event.createEventDto);
      emit(CreateEventSuccess(created));
    } catch (e) {
      emit(CreateEventFailure(e.toString()));
    }
  }
}
