part of 'edit_event_bloc.dart';

abstract class EditEventEvent extends Equatable {
  const EditEventEvent();

  @override
  List<Object?> get props => [];
}

class EditEventInitialized extends EditEventEvent {
  const EditEventInitialized({required this.eventDetail});

  final EventDetailResponse eventDetail;

  @override
  List<Object?> get props => [eventDetail];
}

class EditEventLoadUsers extends EditEventEvent {
  const EditEventLoadUsers();
}

class EditEventTitleChanged extends EditEventEvent {
  const EditEventTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

class EditEventDescriptionChanged extends EditEventEvent {
  const EditEventDescriptionChanged(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

class EditEventLocationChanged extends EditEventEvent {
  const EditEventLocationChanged(this.location);

  final String location;

  @override
  List<Object?> get props => [location];
}

class EditEventMaxParticipantsChanged extends EditEventEvent {
  const EditEventMaxParticipantsChanged(this.maxParticipants);

  final int maxParticipants;

  @override
  List<Object?> get props => [maxParticipants];
}

class EditEventUrlDocsChanged extends EditEventEvent {
  const EditEventUrlDocsChanged(this.urlDocs);

  final String urlDocs;

  @override
  List<Object?> get props => [urlDocs];
}

class EditEventStartDateChanged extends EditEventEvent {
  const EditEventStartDateChanged(this.startDate);

  final DateTime startDate;

  @override
  List<Object?> get props => [startDate];
}

class EditEventEndDateChanged extends EditEventEvent {
  const EditEventEndDateChanged(this.endDate);

  final DateTime endDate;

  @override
  List<Object?> get props => [endDate];
}

class EditEventBannerChanged extends EditEventEvent {
  const EditEventBannerChanged({
    this.bannerImage,
    this.bannerImageFile,
    this.bannerUrl,
  });

  final dynamic bannerImage;
  final XFile? bannerImageFile;
  final String? bannerUrl;

  @override
  List<Object?> get props => [bannerImage, bannerImageFile, bannerUrl];
}

class EditEventManagerAdded extends EditEventEvent {
  const EditEventManagerAdded(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class EditEventManagerRemoved extends EditEventEvent {
  const EditEventManagerRemoved(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

class EditEventSubmitted extends EditEventEvent {
  const EditEventSubmitted(this.eventId);

  final int eventId;

  @override
  List<Object?> get props => [eventId];
}
