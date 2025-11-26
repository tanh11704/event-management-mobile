import 'package:event_management/features/event/shared/data/models/event.dart';
import 'package:event_management/features/event/shared/data/models/event_counters.dart';
import 'package:event_management/features/event/shared/data/models/page_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_page_with_counters_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class EventPageWithCountersResponseDto {
  const EventPageWithCountersResponseDto({
    required this.pagination,
    required this.counters,
  });

  factory EventPageWithCountersResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$EventPageWithCountersResponseDtoFromJson(json);

  final PageResponseDto<Event> pagination;
  final EventCounters counters;
}
