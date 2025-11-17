part of 'create_event_bloc.dart';

abstract class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventSubmitted extends CreateEventEvent {
  const CreateEventSubmitted({
    required this.createEventDto,
    this.bannerImage,
    this.bannerImageFile,
  });
  final CreateEventDto createEventDto;
  final File? bannerImage;
  final XFile? bannerImageFile;

  @override
  List<Object?> get props => [createEventDto, bannerImage, bannerImageFile];
}
