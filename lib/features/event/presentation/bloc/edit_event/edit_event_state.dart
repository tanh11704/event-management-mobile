part of 'edit_event_bloc.dart';

abstract class EditEventState extends Equatable {
  const EditEventState();

  @override
  List<Object?> get props => [];
}

class EditEventInitial extends EditEventState {}

class EditEventFormState extends EditEventState {
  const EditEventFormState({
    required this.eventId,
    required this.title,
    required this.description,
    required this.location,
    required this.maxParticipants,
    required this.urlDocs,
    required this.startDate,
    required this.endDate,
    required this.selectedManagers,
    this.bannerImage,
    this.bannerImageFile,
    this.bannerUrl,
    this.allUsers = const [],
  });

  final int eventId;
  final String title;
  final String description;
  final String location;
  final int maxParticipants;
  final String urlDocs;
  final DateTime startDate;
  final DateTime endDate;
  final List<ManagerInfo> selectedManagers;
  final dynamic bannerImage;
  final XFile? bannerImageFile;
  final String? bannerUrl;
  final List<UserEntity> allUsers;

  @override
  List<Object?> get props => [
    eventId,
    title,
    description,
    location,
    maxParticipants,
    urlDocs,
    startDate,
    endDate,
    selectedManagers,
    bannerImage,
    bannerImageFile,
    bannerUrl,
    allUsers,
  ];

  EditEventFormState copyWith({
    int? eventId,
    String? title,
    String? description,
    String? location,
    int? maxParticipants,
    String? urlDocs,
    DateTime? startDate,
    DateTime? endDate,
    List<ManagerInfo>? selectedManagers,
    dynamic bannerImage,
    XFile? bannerImageFile,
    String? bannerUrl,
    List<UserEntity>? allUsers,
  }) {
    return EditEventFormState(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      urlDocs: urlDocs ?? this.urlDocs,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedManagers: selectedManagers ?? this.selectedManagers,
      bannerImage: bannerImage ?? this.bannerImage,
      bannerImageFile: bannerImageFile ?? this.bannerImageFile,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      allUsers: allUsers ?? this.allUsers,
    );
  }
}

class EditEventLoadingUsers extends EditEventState {}

class EditEventUsersLoaded extends EditEventState {
  const EditEventUsersLoaded({required this.users});

  final List<UserEntity> users;

  @override
  List<Object?> get props => [users];
}

class EditEventUsersLoadError extends EditEventState {
  const EditEventUsersLoadError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class EditEventSaving extends EditEventState {}

class EditEventSaveSuccess extends EditEventState {}

class EditEventSaveError extends EditEventState {
  const EditEventSaveError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class EditEventManagerAssignError extends EditEventState {
  const EditEventManagerAssignError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class EditEventManagerRemoveError extends EditEventState {
  const EditEventManagerRemoveError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
