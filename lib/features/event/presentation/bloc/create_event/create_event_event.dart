part of 'create_event_bloc.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventSubmitted extends CreateEventEvent {
  const CreateEventSubmitted({
    required this.createEventDto,
    this.bannerImageFile,
  });
  final CreateEventDto createEventDto;
  final XFile? bannerImageFile;

  @override
  List<Object?> get props => [createEventDto, bannerImageFile];
}
