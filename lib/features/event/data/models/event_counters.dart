import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_counters.g.dart';

@JsonSerializable(createToJson: false)
class EventCounters extends Equatable {
  const EventCounters({
    required this.upcoming,
    required this.ongoing,
    required this.completed,
    required this.cancelled,
    required this.manage,
  });

  factory EventCounters.fromJson(Map<String, dynamic> json) =>
      _$EventCountersFromJson(json);

  @JsonKey(name: 'UPCOMING')
  final int upcoming;

  @JsonKey(name: 'ONGOING')
  final int ongoing;

  @JsonKey(name: 'COMPLETED')
  final int completed;

  @JsonKey(name: 'CANCELLED')
  final int cancelled;

  @JsonKey(name: 'MANAGE')
  final int manage;

  @override
  List<Object> get props => [upcoming, ongoing, completed, cancelled, manage];
}
