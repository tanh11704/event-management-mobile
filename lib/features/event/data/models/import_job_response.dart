import 'package:equatable/equatable.dart';
import 'package:event_management/core/utils/json_converters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_job_response.g.dart';

@JsonSerializable(createToJson: false)
class ImportJobResponse extends Equatable {
  const ImportJobResponse({
    required this.id,
    required this.eventId,
    required this.createdBy,
    required this.fileName,
    required this.status,
    required this.createdAt,
    this.totalRecords,
    this.processedCount,
    this.successCount,
    this.skippedCount,
    this.errorMessage,
    this.resultDetails,
    this.updatedAt,
    this.progressPercentageFromBackend,
  });

  factory ImportJobResponse.fromJson(Map<String, dynamic> json) {
    try {
      return _$ImportJobResponseFromJson(json);
    } catch (e) {
      // Fallback parsing if generated code fails (e.g., null values)
      return ImportJobResponse(
        id: _intFromJson(json['id']) ?? 0,
        eventId: _intFromJson(json['event_id']) ?? 0,
        createdBy: (json['created_by'] as String?) ?? '',
        fileName: (json['file_name'] as String?) ?? '',
        status: _parseStatus(json['status']),
        createdAt: _parseDateTime(json['created_at']),
        totalRecords: _intFromJson(json['total_records']),
        processedCount: _intFromJson(json['processed_count']),
        successCount: _intFromJson(json['success_count']),
        skippedCount: _intFromJson(json['skipped_count']),
        errorMessage: json['error_message'] as String?,
        resultDetails: json['result_details'] as String?,
        updatedAt: _parseNullableDateTime(json['updated_at']),
        progressPercentageFromBackend: _doubleFromJson(
          json['progress_percentage'],
        ),
      );
    }
  }

  static ImportJobStatus _parseStatus(dynamic value) {
    if (value == null) return ImportJobStatus.pending;
    final str = value.toString().toUpperCase();
    switch (str) {
      case 'PENDING':
        return ImportJobStatus.pending;
      case 'PROCESSING':
        return ImportJobStatus.processing;
      case 'COMPLETED':
        return ImportJobStatus.completed;
      case 'FAILED':
        return ImportJobStatus.failed;
      default:
        return ImportJobStatus.pending;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
    }
    return null;
  }

  final int id;

  @JsonKey(name: 'event_id')
  final int eventId;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'file_name')
  final String fileName;

  final ImportJobStatus status;

  @JsonKey(name: 'total_records', fromJson: _intFromJson)
  final int? totalRecords;

  @JsonKey(name: 'processed_count', fromJson: _intFromJson)
  final int? processedCount;

  @JsonKey(name: 'success_count', fromJson: _intFromJson)
  final int? successCount;

  @JsonKey(name: 'skipped_count', fromJson: _intFromJson)
  final int? skippedCount;

  static int? _intFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  @JsonKey(name: 'error_message')
  final String? errorMessage;

  @JsonKey(name: 'result_details')
  final String? resultDetails;

  @TimestampConverter()
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @NullableTimestampConverter()
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Progress percentage from backend (0-100), if available
  @JsonKey(name: 'progress_percentage', fromJson: _doubleFromJson)
  final double? progressPercentageFromBackend;

  static double? _doubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return null;
  }

  /// Returns progress as a value between 0.0 and 1.0
  double get progress {
    // Use backend's progress_percentage if available, otherwise calculate
    if (progressPercentageFromBackend != null) {
      return (progressPercentageFromBackend! / 100.0).clamp(0.0, 1.0);
    }
    if (totalRecords == null || totalRecords == 0) {
      return 0;
    }
    final processed = processedCount ?? 0;
    return (processed / totalRecords!).clamp(0.0, 1.0);
  }

  /// Returns progress percentage (0-100) matching backend's getProgressPercentage()
  double get progressPercentage {
    // Use backend's progress_percentage if available
    if (progressPercentageFromBackend != null) {
      return progressPercentageFromBackend!.clamp(0.0, 100.0);
    }
    // Otherwise calculate from processedCount/totalRecords
    if (totalRecords == null || totalRecords == 0) {
      return 0;
    }
    final processed = processedCount ?? 0;
    return ((processed * 100.0) / totalRecords!).clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    createdBy,
    fileName,
    status,
    totalRecords,
    processedCount,
    successCount,
    skippedCount,
    errorMessage,
    resultDetails,
    createdAt,
    updatedAt,
    progressPercentageFromBackend,
  ];
}

enum ImportJobStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('PROCESSING')
  processing,

  @JsonValue('COMPLETED')
  completed,

  @JsonValue('FAILED')
  failed,
}
