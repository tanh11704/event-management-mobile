// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJobResponse _$ImportJobResponseFromJson(Map<String, dynamic> json) =>
    ImportJobResponse(
      id: (json['id'] as num).toInt(),
      eventId: (json['event_id'] as num).toInt(),
      createdBy: json['created_by'] as String,
      fileName: json['file_name'] as String,
      status: $enumDecode(_$ImportJobStatusEnumMap, json['status']),
      createdAt: const TimestampConverter().fromJson(
        (json['created_at'] as num).toDouble(),
      ),
      totalRecords: ImportJobResponse._intFromJson(json['total_records']),
      processedCount: ImportJobResponse._intFromJson(json['processed_count']),
      successCount: ImportJobResponse._intFromJson(json['success_count']),
      skippedCount: ImportJobResponse._intFromJson(json['skipped_count']),
      errorMessage: json['error_message'] as String?,
      resultDetails: json['result_details'] as String?,
      updatedAt: const NullableTimestampConverter().fromJson(
        (json['updated_at'] as num?)?.toDouble(),
      ),
      progressPercentageFromBackend: ImportJobResponse._doubleFromJson(
        json['progress_percentage'],
      ),
    );

const _$ImportJobStatusEnumMap = {
  ImportJobStatus.pending: 'PENDING',
  ImportJobStatus.processing: 'PROCESSING',
  ImportJobStatus.completed: 'COMPLETED',
  ImportJobStatus.failed: 'FAILED',
};
