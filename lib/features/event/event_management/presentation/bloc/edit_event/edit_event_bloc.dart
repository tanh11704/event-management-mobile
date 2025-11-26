import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_management/features/admin/data/models/event_management.dart';
import 'package:event_management/features/admin/domain/entity/user_entity.dart';
import 'package:event_management/features/admin/domain/repositories/admin_repository.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:event_management/features/event/shared/data/models/event_dto.dart';
import 'package:event_management/features/event/shared/data/models/manager.dart';
import 'package:event_management/features/event/shared/domain/repositories/event_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

part 'edit_event_event.dart';
part 'edit_event_state.dart';

@injectable
class EditEventBloc extends Bloc<EditEventEvent, EditEventState> {
  EditEventBloc({
    required EventRepository eventRepository,
    required AdminRepository adminRepository,
    required AuthRepository authRepository,
  }) : _eventRepository = eventRepository,
       _adminRepository = adminRepository,
       _authRepository = authRepository,
       super(EditEventInitial()) {
    on<EditEventInitialized>(_onInitialized);
    on<EditEventLoadUsers>(_onLoadUsers);
    on<EditEventTitleChanged>(_onTitleChanged);
    on<EditEventDescriptionChanged>(_onDescriptionChanged);
    on<EditEventLocationChanged>(_onLocationChanged);
    on<EditEventMaxParticipantsChanged>(_onMaxParticipantsChanged);
    on<EditEventUrlDocsChanged>(_onUrlDocsChanged);
    on<EditEventStartDateChanged>(_onStartDateChanged);
    on<EditEventEndDateChanged>(_onEndDateChanged);
    on<EditEventBannerChanged>(_onBannerChanged);
    on<EditEventManagerAdded>(_onManagerAdded);
    on<EditEventManagerRemoved>(_onManagerRemoved);
    on<EditEventSubmitted>(_onSubmitted);
  }

  final EventRepository _eventRepository;
  final AdminRepository _adminRepository;
  final AuthRepository _authRepository;

  int? _cachedEventId;
  List<ManagerInfo> _cachedSelectedManagers = [];

  void _onInitialized(
    EditEventInitialized event,
    Emitter<EditEventState> emit,
  ) {
    final eventDetail = event.eventDetail;
    final managers = List<ManagerInfo>.from(eventDetail.manager);

    // Cache eventId and managers for API calls
    _cachedEventId = eventDetail.id;
    _cachedSelectedManagers = managers;

    emit(
      EditEventFormState(
        eventId: eventDetail.id,
        title: eventDetail.title,
        description: eventDetail.description ?? '',
        location: eventDetail.location ?? '',
        maxParticipants: eventDetail.maxParticipants ?? 0,
        urlDocs: eventDetail.urlDocs ?? '',
        startDate: eventDetail.startTime,
        endDate: eventDetail.endTime,
        selectedManagers: managers,
        bannerUrl: eventDetail.banner,
      ),
    );
    // Auto load users
    add(const EditEventLoadUsers());
  }

  Future<void> _onLoadUsers(
    EditEventLoadUsers event,
    Emitter<EditEventState> emit,
  ) async {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith());
    } else {
      emit(EditEventLoadingUsers());
    }

    try {
      final users = await _adminRepository.getAllUsers();
      if (currentState is EditEventFormState) {
        emit(currentState.copyWith(allUsers: users));
      } else {
        emit(EditEventUsersLoaded(users: users));
      }
    } catch (e) {
      if (currentState is EditEventFormState) {
        emit(currentState.copyWith());
      } else {
        emit(EditEventUsersLoadError(e.toString()));
      }
    }
  }

  void _onTitleChanged(
    EditEventTitleChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(title: event.title));
    }
  }

  void _onDescriptionChanged(
    EditEventDescriptionChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(description: event.description));
    }
  }

  void _onLocationChanged(
    EditEventLocationChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(location: event.location));
    }
  }

  void _onMaxParticipantsChanged(
    EditEventMaxParticipantsChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(maxParticipants: event.maxParticipants));
    }
  }

  void _onUrlDocsChanged(
    EditEventUrlDocsChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(urlDocs: event.urlDocs));
    }
  }

  void _onStartDateChanged(
    EditEventStartDateChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(startDate: event.startDate));
    }
  }

  void _onEndDateChanged(
    EditEventEndDateChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(currentState.copyWith(endDate: event.endDate));
    }
  }

  void _onBannerChanged(
    EditEventBannerChanged event,
    Emitter<EditEventState> emit,
  ) {
    final currentState = state;
    if (currentState is EditEventFormState) {
      emit(
        currentState.copyWith(
          bannerImage: event.bannerImage,
          bannerImageFile: event.bannerImageFile,
          bannerUrl: event.bannerUrl,
        ),
      );
    }
  }

  Future<void> _onManagerAdded(
    EditEventManagerAdded event,
    Emitter<EditEventState> emit,
  ) async {
    final currentState = state;

    // Get eventId and managers from state or cache
    final eventId = currentState is EditEventFormState
        ? currentState.eventId
        : _cachedEventId;

    if (eventId == null) {
      emit(const EditEventManagerAssignError('Event not initialized'));
      return;
    }

    // Check if user already exists in cache
    final alreadyExists = _cachedSelectedManagers.any(
      (m) => m.userId == event.user.id,
    );

    // If already exists, no need to do anything
    if (alreadyExists) {
      return;
    }

    // Save previous cache for error revert
    final previousCache = List<ManagerInfo>.from(_cachedSelectedManagers);

    // Create manager info
    final manager = ManagerInfo(
      userId: event.user.id,
      userName: event.user.name,
      userEmail: event.user.email,
    );

    // Optimistic update: update cache immediately
    _cachedSelectedManagers = [..._cachedSelectedManagers, manager];

    // Optimistic update: update UI immediately
    if (currentState is EditEventFormState) {
      final optimisticState = currentState.copyWith(
        selectedManagers: _cachedSelectedManagers,
      );
      emit(optimisticState);
    }

    try {
      final currentUser = await _authRepository.getAuthUser();
      final currentUserId = currentUser.id;

      await _adminRepository.assignEventManager(
        eventId: eventId,
        userId: event.user.id,
        roleType: EventManagement.manage,
        assignedBy: currentUserId,
      );

      // API call successful - cache and UI are already updated
      // Emit state again to ensure UI is in sync
      if (currentState is EditEventFormState) {
        final updatedState = currentState.copyWith(
          selectedManagers: _cachedSelectedManagers,
        );
        emit(updatedState);
      }
    } catch (e) {
      // Revert cache on error
      _cachedSelectedManagers = previousCache;

      // Revert UI state on error
      if (currentState is EditEventFormState) {
        emit(currentState);
      }

      emit(EditEventManagerAssignError(e.toString()));

      // Emit previous state again after error
      if (currentState is EditEventFormState) {
        emit(currentState);
      }
    }
  }

  Future<void> _onManagerRemoved(
    EditEventManagerRemoved event,
    Emitter<EditEventState> emit,
  ) async {
    final currentState = state;

    final eventId = currentState is EditEventFormState
        ? currentState.eventId
        : _cachedEventId;

    if (eventId == null) {
      emit(const EditEventManagerRemoveError('Event not initialized'));
      return;
    }

    if (!_cachedSelectedManagers.any((m) => m.userId == event.user.id)) {
      return;
    }

    final previousCache = List<ManagerInfo>.from(_cachedSelectedManagers);

    final updatedManagers = _cachedSelectedManagers
        .where((m) => m.userId != event.user.id)
        .toList();

    _cachedSelectedManagers = updatedManagers;

    if (currentState is EditEventFormState) {
      final optimisticState = currentState.copyWith(
        selectedManagers: updatedManagers,
      );
      emit(optimisticState);
    }

    try {
      await _adminRepository.removeEventManager(
        eventId: eventId,
        userId: event.user.id,
        roleType: EventManagement.manage,
      );
      // Success - ensure UI state is updated with latest cache
      if (currentState is EditEventFormState) {
        final latestState = currentState.copyWith(
          selectedManagers: _cachedSelectedManagers,
        );
        emit(latestState);
      }
    } catch (e) {
      // Revert cache on error
      _cachedSelectedManagers = previousCache;

      // Revert UI state if we have form state
      if (currentState is EditEventFormState) {
        emit(
          currentState.copyWith(
            selectedManagers: currentState.selectedManagers,
          ),
        );
      }
      emit(EditEventManagerRemoveError(e.toString()));
      if (currentState is EditEventFormState) {
        emit(
          currentState.copyWith(
            selectedManagers: currentState.selectedManagers,
          ),
        );
      }
    }
  }

  Future<void> _onSubmitted(
    EditEventSubmitted event,
    Emitter<EditEventState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EditEventFormState) return;

    emit(EditEventSaving());

    try {
      final startDateTime = DateTime.utc(
        currentState.startDate.year,
        currentState.startDate.month,
        currentState.startDate.day,
        currentState.startDate.hour,
        currentState.startDate.minute,
      );
      final endDateTime = DateTime.utc(
        currentState.endDate.year,
        currentState.endDate.month,
        currentState.endDate.day,
        currentState.endDate.hour,
        currentState.endDate.minute,
      );

      final dto = EventDto(
        title: currentState.title,
        description: currentState.description,
        location: currentState.location,
        startTime: startDateTime.toIso8601String(),
        endTime: endDateTime.toIso8601String(),
        maxParticipants: currentState.maxParticipants,
        urlDocs: currentState.urlDocs,
      );

      await _eventRepository.updateEvent(event.eventId, dto);

      if (currentState.bannerImageFile != null) {
        await _eventRepository.uploadBannerFromXFile(
          event.eventId,
          currentState.bannerImageFile!,
        );
      }

      emit(EditEventSaveSuccess());
    } catch (e) {
      emit(EditEventSaveError(e.toString()));
    }
  }
}
