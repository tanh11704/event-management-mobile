import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_management/features/event/data/models/event_dto.dart';
import 'package:event_management/features/event/data/models/import_job_response.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';
import 'package:event_management/features/event/domain/usecases/get_event_detail_usecase.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_event.dart';
import 'package:event_management/features/event/presentation/bloc/event_detail/event_detail_state.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc({required EventRepository eventRepository})
    : _eventRepository = eventRepository,
      _getEventDetailUseCase = GetEventDetailUseCase(eventRepository),
      super(EventDetailInitial()) {
    on<EventDetailFetch>(_onFetch);
    on<EventDetailJoin>(_onJoin);
    on<EventDetailUnjoin>(_onUnjoin);
    on<EventDetailUpdate>(_onUpdate);
    on<EventDetailImportParticipants>(_onImportParticipants);
    on<EventDetailCheckImportStatus>(_onCheckImportStatus);
    on<EventDetailExportParticipants>(_onExportParticipants);
  }

  final EventRepository _eventRepository;
  final GetEventDetailUseCase _getEventDetailUseCase;
  Timer? _pollingTimer;
  EventDetailSuccess? _savedStateBeforeImport;

  Future<void> _onFetch(
    EventDetailFetch event,
    Emitter<EventDetailState> emit,
  ) async {
    if (state is! EventDetailSuccess) {
      emit(EventDetailLoading());
    }

    try {
      final eventDetail = await _getEventDetailUseCase(event.eventId);
      emit(EventDetailSuccess(eventDetail: eventDetail));
    } catch (e) {
      emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onJoin(
    EventDetailJoin event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      emit(currentState.copyWith(isJoining: true));

      try {
        await _eventRepository.joinEvent(event.eventToken);

        final newEventDetail = await _getEventDetailUseCase(
          currentState.eventDetail.id,
        );

        emit(EventDetailSuccess(eventDetail: newEventDetail));
      } catch (e) {
        emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
        emit(currentState.copyWith(isJoining: false));
      }
    }
  }

  Future<void> _onUnjoin(
    EventDetailUnjoin event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      emit(currentState.copyWith(isJoining: true));

      try {
        await _eventRepository.unjoinEvent(event.eventId);

        final newEventDetail = await _getEventDetailUseCase(
          currentState.eventDetail.id,
        );

        emit(EventDetailSuccess(eventDetail: newEventDetail));
      } catch (e) {
        emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
        emit(currentState.copyWith(isJoining: false));
      }
    }
  }

  Future<void> _onUpdate(
    EventDetailUpdate event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      emit(currentState.copyWith(isUpdating: true));

      try {
        // Upload banner if provided
        if (event.bannerFile != null && event.bannerFile is XFile) {
          await _eventRepository.uploadBannerFromXFile(
            event.eventId,
            event.bannerFile as XFile,
          );
        }

        // Update event
        if (event.eventDto is EventDto) {
          final updatedEventDetail = await _eventRepository.updateEvent(
            event.eventId,
            event.eventDto as EventDto,
          );
          emit(EventDetailSuccess(eventDetail: updatedEventDetail));
        } else {
          throw Exception('Invalid event DTO');
        }
      } catch (e) {
        emit(EventDetailError(e.toString().replaceFirst('Exception: ', '')));
        emit(currentState.copyWith(isUpdating: false));
      }
    }
  }

  Future<void> _onImportParticipants(
    EventDetailImportParticipants event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      try {
        if (event.file is XFile) {
          if (kDebugMode) {
            debugPrint(
              'EventDetailBloc: Starting import for event ${event.eventId}',
            );
          }

          // Save current state to restore later
          _savedStateBeforeImport = currentState;

          // Show initial loading state
          emit(
            const EventDetailImporting(
              jobId: 0,
              progress: 0,
              status: 'PROCESSING',
            ),
          );

          // 1. Upload file and get jobId
          final response = await _eventRepository.importParticipants(
            event.eventId,
            event.file as XFile,
          );

          if (kDebugMode) {
            debugPrint(
              'EventDetailBloc: Import accepted - jobId: ${response.jobId}, status: ${response.status}, message: ${response.message}',
            );
          }

          // 2. Start polling for job status (every 2 seconds)
          _startPolling(response.jobId, event.eventId);

          // Poll immediately to get initial status
          add(EventDetailCheckImportStatus(jobId: response.jobId));
        } else {
          throw Exception('Invalid file');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('EventDetailBloc: Import error: $e');
        }
        _pollingTimer?.cancel();
        _pollingTimer = null;
        emit(
          EventDetailImportFailure(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        );
        emit(currentState);
      }
    }
  }

  void _startPolling(int jobId, int eventId) {
    _pollingTimer?.cancel();

    // Poll every 2 seconds as per backend flow
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      add(EventDetailCheckImportStatus(jobId: jobId));
    });
  }

  Future<void> _onCheckImportStatus(
    EventDetailCheckImportStatus event,
    Emitter<EventDetailState> emit,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          'EventDetailBloc: Checking import status for jobId: ${event.jobId}',
        );
      }
      final jobStatus = await _eventRepository.getImportJobStatus(event.jobId);

      if (kDebugMode) {
        debugPrint(
          'EventDetailBloc: Job status - ${jobStatus.status}, progress: ${jobStatus.progressPercentage.toStringAsFixed(1)}%, processed: ${jobStatus.processedCount}/${jobStatus.totalRecords}',
        );
      }

      // Emit importing state with current progress
      emit(
        EventDetailImporting(
          jobId: jobStatus.id,
          progress: jobStatus.progress,
          totalRecords: jobStatus.totalRecords,
          processedCount: jobStatus.processedCount,
          successCount: jobStatus.successCount,
          skippedCount: jobStatus.skippedCount,
          status: jobStatus.status.toString().split('.').last,
        ),
      );

      // Stop polling if job is completed or failed
      if (jobStatus.status == ImportJobStatus.completed ||
          jobStatus.status == ImportJobStatus.failed) {
        _pollingTimer?.cancel();
        _pollingTimer = null;

        if (jobStatus.status == ImportJobStatus.completed) {
          emit(
            EventDetailImportSuccess(
              'Import thành công! ${jobStatus.successCount ?? 0} người đã được thêm.${jobStatus.skippedCount != null && jobStatus.skippedCount! > 0 ? ' ${jobStatus.skippedCount} người đã bỏ qua.' : ''}',
            ),
          );
          // Refresh event detail to show updated participants
          add(EventDetailFetch(eventId: jobStatus.eventId));
        } else {
          // Emit failure, then restore previous state
          emit(
            EventDetailImportFailure(
              jobStatus.errorMessage ?? 'Import thất bại',
            ),
          );
          // Restore previous state to prevent UI from hanging
          if (_savedStateBeforeImport != null) {
            emit(_savedStateBeforeImport!);
            _savedStateBeforeImport = null;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EventDetailBloc: Error checking import status: $e');
      }
      // Don't stop polling on error, just log it
      // The next poll will retry
    }
  }

  Future<void> _onExportParticipants(
    EventDetailExportParticipants event,
    Emitter<EventDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is EventDetailSuccess) {
      if (kDebugMode) {
        debugPrint(
          'EventDetailBloc (instance: $hashCode): Starting export for event ${event.eventId} with filter ${event.filter}',
        );
      }

      // 1. Exporting vẫn giữ eventDetail
      emit(EventDetailExporting(currentState.eventDetail));

      try {
        final filePath = await _eventRepository.exportParticipants(
          eventId: event.eventId,
          filter: event.filter,
        );

        if (kDebugMode) {
          debugPrint(
            'EventDetailBloc (instance: $hashCode): Export successful, file saved to: $filePath',
          );
        }

        // 2. Success cũng giữ eventDetail
        emit(
          EventDetailExportSuccess(
            eventDetail: currentState.eventDetail,
            filePath: filePath,
            message: 'Xuất file Excel thành công!',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        // (tuỳ chọn) Sau khi share xong, bạn có thể emit lại EventDetailSuccess
        // từ UI hoặc sau 1 event khác, nhưng không bắt buộc ngay tại đây.
        // emit(currentState);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('EventDetailBloc: Export error: $e');
          debugPrint('EventDetailBloc: Stack trace: $stackTrace');
        }

        emit(
          EventDetailExportFailure(
            eventDetail: currentState.eventDetail,
            error: e.toString().replaceFirst('Exception: ', ''),
          ),
        );

        // Sau khi show lỗi, có thể emit lại currentState nếu muốn
        emit(currentState);
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          'EventDetailBloc: Cannot export - current state is not EventDetailSuccess: ${state.runtimeType}',
        );
      }
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
