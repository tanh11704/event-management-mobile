import 'package:bloc/bloc.dart';
import 'package:event_management/features/admin/data/models/event_management.dart';
import 'package:event_management/features/admin/domain/repositories/admin_repository.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/secretary_management/secretary_management_event.dart';
import 'package:event_management/features/event/presentation/bloc/secretary_management/secretary_management_state.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// BLoC for managing secretaries (staff) for events.
@injectable
class SecretaryManagementBloc
    extends Bloc<SecretaryManagementEvent, SecretaryManagementState> {
  SecretaryManagementBloc({
    required EventRepository eventRepository,
    required AdminRepository adminRepository,
  }) : _eventRepository = eventRepository,
       _adminRepository = adminRepository,
       super(SecretaryManagementInitial()) {
    on<SecretaryManagementFetchEventManagers>(_onFetchEventManagers);
    on<SecretaryManagementAssignSecretary>(_onAssignSecretary);
    on<SecretaryManagementRemoveSecretary>(_onRemoveSecretary);
    on<SecretaryManagementRefresh>(_onRefresh);
  }

  final EventRepository _eventRepository;
  final AdminRepository _adminRepository;

  Future<void> _onFetchEventManagers(
    SecretaryManagementFetchEventManagers event,
    Emitter<SecretaryManagementState> emit,
  ) async {
    emit(const SecretaryManagementLoading());

    try {
      // Fetch event managers from API
      final eventManagers = await _eventRepository.getEventManagers(
        event.eventId,
      );

      // Emit success state with event managers
      emit(SecretaryManagementSuccess(eventManagers: eventManagers));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching event managers: $e');
      }
      emit(
        SecretaryManagementError(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAssignSecretary(
    SecretaryManagementAssignSecretary event,
    Emitter<SecretaryManagementState> emit,
  ) async {
    final currentState = state;

    // Optimistic update: show loading while assigning
    if (currentState is SecretaryManagementSuccess) {
      emit(const SecretaryManagementLoading(isRefreshing: true));
    } else {
      emit(const SecretaryManagementLoading());
    }

    try {
      await _adminRepository.assignEventManager(
        eventId: event.eventId,
        userId: event.userId,
        roleType: EventManagement.staff,
        assignedBy: event.assignedBy,
      );

      // Fetch updated list after successful assignment
      final eventManagers = await _eventRepository.getEventManagers(
        event.eventId,
      );
      emit(
        const SecretaryManagementAssignSuccess(
          message: 'Đã thêm thư ký thành công',
        ),
      );
      // Emit success state with updated list after a short delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(SecretaryManagementSuccess(eventManagers: eventManagers));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error assigning secretary: $e');
      }

      // Restore previous state on error
      if (currentState is SecretaryManagementSuccess) {
        emit(currentState);
      }

      emit(
        SecretaryManagementError(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );

      // Restore success state after showing error
      if (currentState is SecretaryManagementSuccess) {
        await Future<void>.delayed(const Duration(seconds: 2));
        emit(currentState);
      }
    }
  }

  Future<void> _onRemoveSecretary(
    SecretaryManagementRemoveSecretary event,
    Emitter<SecretaryManagementState> emit,
  ) async {
    final currentState = state;

    // Optimistic update: show loading while removing
    if (currentState is SecretaryManagementSuccess) {
      emit(const SecretaryManagementLoading(isRefreshing: true));
    } else {
      emit(const SecretaryManagementLoading());
    }

    try {
      await _adminRepository.removeEventManager(
        eventId: event.eventId,
        userId: event.userId,
        roleType: EventManagement.staff,
      );

      // Fetch updated list after successful removal
      final eventManagers = await _eventRepository.getEventManagers(
        event.eventId,
      );
      emit(
        const SecretaryManagementRemoveSuccess(
          message: 'Đã xóa thư ký thành công',
        ),
      );
      // Emit success state with updated list after a short delay
      await Future<void>.delayed(const Duration(milliseconds: 500));
      emit(SecretaryManagementSuccess(eventManagers: eventManagers));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error removing secretary: $e');
      }

      // Restore previous state on error
      if (currentState is SecretaryManagementSuccess) {
        emit(currentState);
      }

      emit(
        SecretaryManagementError(
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );

      // Restore success state after showing error
      if (currentState is SecretaryManagementSuccess) {
        await Future<void>.delayed(const Duration(seconds: 2));
        emit(currentState);
      }
    }
  }

  Future<void> _onRefresh(
    SecretaryManagementRefresh event,
    Emitter<SecretaryManagementState> emit,
  ) async {
    final currentState = state;

    // Keep current state if it's a success state while loading
    if (currentState is SecretaryManagementSuccess) {
      emit(const SecretaryManagementLoading(isRefreshing: true));
    } else {
      emit(const SecretaryManagementLoading());
    }

    try {
      // Fetch event managers from API
      final eventManagers = await _eventRepository.getEventManagers(
        event.eventId,
      );

      // Emit success state with event managers
      emit(SecretaryManagementSuccess(eventManagers: eventManagers));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error refreshing event managers: $e');
      }

      // Restore previous state on error
      if (currentState is SecretaryManagementSuccess) {
        emit(currentState);
      } else {
        emit(
          SecretaryManagementError(
            error: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }
  }
}
