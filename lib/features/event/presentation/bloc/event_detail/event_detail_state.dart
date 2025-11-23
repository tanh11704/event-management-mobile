import 'package:equatable/equatable.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';

abstract class EventDetailState extends Equatable {
  const EventDetailState();

  @override
  List<Object?> get props => [];
}

class EventDetailInitial extends EventDetailState {}

class EventDetailLoading extends EventDetailState {}

class EventDetailSuccess extends EventDetailState {
  const EventDetailSuccess({
    required this.eventDetail,
    this.isJoining = false,
    this.isUpdating = false,
  });

  final EventDetailResponse eventDetail;
  final bool isJoining;
  final bool isUpdating;

  EventDetailSuccess copyWith({
    EventDetailResponse? eventDetail,
    bool? isJoining,
    bool? isUpdating,
  }) {
    return EventDetailSuccess(
      eventDetail: eventDetail ?? this.eventDetail,
      isJoining: isJoining ?? this.isJoining,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object> get props => [eventDetail, isJoining, isUpdating];
}

class EventDetailImporting extends EventDetailState {
  const EventDetailImporting({
    required this.jobId,
    required this.progress,
    this.totalRecords,
    this.processedCount,
    this.successCount,
    this.skippedCount,
    this.status,
  });

  final int jobId;
  final double progress; // 0.0 to 1.0
  final int? totalRecords;
  final int? processedCount;
  final int? successCount;
  final int? skippedCount;
  final String? status;

  @override
  List<Object?> get props => [
    jobId,
    progress,
    totalRecords,
    processedCount,
    successCount,
    skippedCount,
    status,
  ];
}

class EventDetailImportSuccess extends EventDetailState {
  const EventDetailImportSuccess(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class EventDetailImportFailure extends EventDetailState {
  const EventDetailImportFailure(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

class EventDetailError extends EventDetailState {
  const EventDetailError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

class EventDetailExporting extends EventDetailState {
  const EventDetailExporting(this.eventDetail);

  final EventDetailResponse eventDetail;

  @override
  List<Object> get props => [eventDetail];
}

class EventDetailExportSuccess extends EventDetailState {
  const EventDetailExportSuccess({
    required this.eventDetail,
    required this.filePath,
    required this.message,
    required this.timestamp,
  });

  final EventDetailResponse eventDetail;
  final String filePath;
  final String message;
  final int timestamp;

  @override
  List<Object> get props => [eventDetail, filePath, message, timestamp];
}

class EventDetailExportFailure extends EventDetailState {
  const EventDetailExportFailure({
    required this.eventDetail,
    required this.error,
  });

  final EventDetailResponse eventDetail;
  final String error;

  @override
  List<Object> get props => [eventDetail, error];
}
