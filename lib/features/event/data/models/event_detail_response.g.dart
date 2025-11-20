// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDetailResponse _$EventDetailResponseFromJson(Map<String, dynamic> json) =>
    EventDetailResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      startTime: const TimestampConverter().fromJson(
        (json['start_time'] as num).toDouble(),
      ),
      endTime: const TimestampConverter().fromJson(
        (json['end_time'] as num).toDouble(),
      ),
      status: $enumDecode(_$EventStatusEnumMap, json['status']),
      createdAt: const TimestampConverter().fromJson(
        (json['created_at'] as num).toDouble(),
      ),
      description: json['description'] as String?,
      location: json['location'] as String?,
      createBy: (json['create_by'] as num?)?.toInt(),
      banner: json['banner'] as String?,
      urlDocs: json['url_docs'] as String?,
      maxParticipants: (json['max_participants'] as num?)?.toInt(),
      qrJoinToken: json['qr_join_token'] as String?,
      updatedAt: const NullableTimestampConverter().fromJson(
        (json['updated_at'] as num?)?.toDouble(),
      ),
      isUserRegistered: json['is_user_registered'] as bool?,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => ParticipantInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      manager:
          (json['manager'] as List<dynamic>?)
              ?.map((e) => ManagerInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      secretaries:
          (json['secretaries'] as List<dynamic>?)
              ?.map((e) => SecretaryInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

const _$EventStatusEnumMap = {
  EventStatus.upcoming: 'UPCOMING',
  EventStatus.ongoing: 'ONGOING',
  EventStatus.completed: 'COMPLETED',
  EventStatus.cancelled: 'CANCELLED',
};
