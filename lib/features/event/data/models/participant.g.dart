// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantInfo _$ParticipantInfoFromJson(Map<String, dynamic> json) =>
    ParticipantInfo(
      userId: (json['user_id'] as num).toInt(),
      userName: json['user_name'] as String,
      joinedAt: const UnixTimestampConverter().fromJson(json['joined_at']),
      userEmail: json['user_email'] as String?,
      userPhone: json['user_phone'] as String?,
      checkedTime: const UnixTimestampConverter().fromJson(
        json['checked_time'],
      ),
      isCheckedIn: json['is_checked_in'] as bool?,
    );
