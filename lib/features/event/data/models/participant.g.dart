// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantInfo _$ParticipantInfoFromJson(Map<String, dynamic> json) =>
    ParticipantInfo(
      userId: (json['user_id'] as num).toInt(),
      userName: json['user_name'] as String,
      joinedAt: const TimestampConverter().fromJson(
        (json['joined_at'] as num).toDouble(),
      ),
      userEmail: json['user_email'] as String?,
      userPhone: json['user_phone'] as String?,
      checkedTime: const NullableTimestampConverter().fromJson(
        (json['checked_time'] as num?)?.toDouble(),
      ),
      isCheckedIn: json['is_checked_in'] as bool?,
    );
