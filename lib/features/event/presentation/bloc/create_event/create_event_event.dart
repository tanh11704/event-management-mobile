part of 'create_event_bloc.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventSubmitted extends CreateEventEvent {
  const CreateEventSubmitted({required this.createEventDto, this.bannerImage});
  final CreateEventDto createEventDto;
  final File? bannerImage;

  @override
  List<Object?> get props => [createEventDto, bannerImage];
}
