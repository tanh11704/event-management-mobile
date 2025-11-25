import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_management/features/event/data/datasources/check_in_sse_service.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:event_management/features/event/data/models/sse_event.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/presentation/bloc/check_in_history/check_in_history_event.dart';
import 'package:event_management/features/event/presentation/bloc/check_in_history/check_in_history_state.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class CheckInHistoryBloc
    extends Bloc<CheckInHistoryEvent, CheckInHistoryState> {
  CheckInHistoryBloc({
    required EventRepository eventRepository,
    required CheckInSseService checkInSseService,
  }) : _eventRepository = eventRepository,
       _checkInSseService = checkInSseService,
       super(CheckInHistoryInitial()) {
    on<CheckInHistoryInitialize>(_onInitialize);
    on<CheckInHistorySseCheckInReceived>(_onSseCheckInReceived);
    on<CheckInHistoryRefresh>(_onRefresh);
    on<CheckInHistoryConnectionStatusChanged>(_onConnectionStatusChanged);
    on<CheckInHistoryDispose>(_onDispose);
  }

  final EventRepository _eventRepository;
  final CheckInSseService _checkInSseService;
  StreamSubscription<SseEvent>? _sseSubscription;
  int? _currentEventId;

  Future<void> _onInitialize(
    CheckInHistoryInitialize event,
    Emitter<CheckInHistoryState> emit,
  ) async {
    _currentEventId = event.eventId;

    final checkedInParticipants = event.participants
        .where((p) => (p.isCheckedIn ?? false) && p.checkedTime != null)
        .toList();

    checkedInParticipants.sort((a, b) {
      if (a.checkedTime == null || b.checkedTime == null) return 0;
      return b.checkedTime!.compareTo(a.checkedTime!);
    });

    final checkedInCount = event.participants
        .where((p) => p.isCheckedIn ?? false)
        .length;

    emit(
      CheckInHistorySuccess(
        checkInHistory: checkedInParticipants,
        totalParticipants: event.participants.length,
        checkedInCount: checkedInCount,
      ),
    );

    _subscribeToSse(event.eventId);
  }

  void _subscribeToSse(int eventId) {
    _sseSubscription?.cancel();

    try {
      final sseStream = _checkInSseService.subscribeToCheckInEvents(eventId);

      _sseSubscription = sseStream.listen(
        (sseEvent) {
          if (kDebugMode) {
            debugPrint(
              'CheckInHistoryBloc: SSE event received: ${sseEvent.name}, '
              'data: ${sseEvent.data}',
            );
          }

          if (sseEvent.name == 'INIT') {
            add(const CheckInHistoryConnectionStatusChanged(isConnected: true));
            return;
          }

          if (sseEvent.name == 'participant-checked-in') {
            if (kDebugMode) {
              debugPrint(
                'CheckInHistoryBloc: Check-in event detected (participant-checked-in), '
                'refreshing history...',
              );
            }
            if (_currentEventId != null) {
              add(CheckInHistoryRefresh(eventId: _currentEventId!));
            }
          } else {
            final eventNameLower = sseEvent.name.toLowerCase();
            final isCheckInEvent =
                eventNameLower.contains('check') &&
                eventNameLower.contains('in');

            if (isCheckInEvent ||
                sseEvent.name == 'CHECK_IN' ||
                sseEvent.name == 'check_in' ||
                sseEvent.name == 'CHECKIN' ||
                sseEvent.name == 'checkIn') {
              if (kDebugMode) {
                debugPrint(
                  'CheckInHistoryBloc: Check-in event detected (alternative name: '
                  '${sseEvent.name}), refreshing history...',
                );
              }
              if (_currentEventId != null) {
                add(CheckInHistoryRefresh(eventId: _currentEventId!));
              }
            } else if (kDebugMode) {
              debugPrint(
                'CheckInHistoryBloc: Unknown SSE event name: ${sseEvent.name}, '
                'ignoring...',
              );
            }
          }
        },
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint('CheckInHistoryBloc: SSE error: $error');
          }
          add(const CheckInHistoryConnectionStatusChanged(isConnected: false));
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint('CheckInHistoryBloc: SSE stream closed');
          }
          add(const CheckInHistoryConnectionStatusChanged(isConnected: false));
        },
      );

      if (kDebugMode) {
        debugPrint('CheckInHistoryBloc: Subscribed to SSE for event $eventId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CheckInHistoryBloc: Error subscribing to SSE: $e');
      }
    }
  }

  void _onSseCheckInReceived(
    CheckInHistorySseCheckInReceived event,
    Emitter<CheckInHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is! CheckInHistorySuccess) return;

    final participant = event.participant;

    final existingIndex = currentState.checkInHistory.indexWhere(
      (p) => p.userId == participant.userId,
    );

    final List<ParticipantInfo> updatedHistory;

    if (existingIndex >= 0) {
      updatedHistory = List<ParticipantInfo>.from(currentState.checkInHistory);
      updatedHistory[existingIndex] = participant;
    } else {
      updatedHistory = [participant, ...currentState.checkInHistory];
    }

    final newCheckedInCount =
        currentState.checkedInCount + (existingIndex < 0 ? 1 : 0);

    emit(
      currentState.copyWith(
        checkInHistory: updatedHistory,
        checkedInCount: newCheckedInCount,
        isConnected: true,
      ),
    );
  }

  Future<void> _onRefresh(
    CheckInHistoryRefresh event,
    Emitter<CheckInHistoryState> emit,
  ) async {
    _currentEventId = event.eventId;

    final currentState = state;
    final isSilentRefresh = currentState is CheckInHistorySuccess;

    // Chỉ hiển thị loading nếu không phải silent refresh (không ở trạng thái Success)
    if (!isSilentRefresh) {
      emit(const CheckInHistoryLoading());
    }

    try {
      final eventDetail = await _eventRepository.getEventDetail(event.eventId);

      final checkedInParticipants = eventDetail.participants
          .where((p) => (p.isCheckedIn ?? false) && p.checkedTime != null)
          .toList();

      checkedInParticipants.sort((a, b) {
        if (a.checkedTime == null || b.checkedTime == null) return 0;
        return b.checkedTime!.compareTo(a.checkedTime!);
      });

      final checkedInCount = eventDetail.participants
          .where((p) => p.isCheckedIn ?? false)
          .length;

      emit(
        CheckInHistorySuccess(
          checkInHistory: checkedInParticipants,
          totalParticipants: eventDetail.participants.length,
          checkedInCount: checkedInCount,
          isConnected: isSilentRefresh ? currentState.isConnected : false,
        ),
      );

      final updatedState = state;
      if (updatedState is CheckInHistorySuccess && !updatedState.isConnected) {
        _subscribeToSse(event.eventId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CheckInHistoryBloc: Error refreshing: $e');
      }
      // Chỉ emit error nếu không phải silent refresh, nếu không giữ nguyên state
      if (!isSilentRefresh) {
        emit(
          CheckInHistoryError(
            error: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }
  }

  void _onConnectionStatusChanged(
    CheckInHistoryConnectionStatusChanged event,
    Emitter<CheckInHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is CheckInHistorySuccess) {
      emit(currentState.copyWith(isConnected: event.isConnected));
    }
  }

  void _onDispose(
    CheckInHistoryDispose event,
    Emitter<CheckInHistoryState> emit,
  ) {
    _sseSubscription?.cancel();
    _sseSubscription = null;

    if (_currentEventId != null) {
      _checkInSseService.dispose(_currentEventId!);
      _currentEventId = null;
    }
  }

  @override
  Future<void> close() {
    _sseSubscription?.cancel();
    if (_currentEventId != null) {
      _checkInSseService.dispose(_currentEventId!);
    }
    return super.close();
  }
}
