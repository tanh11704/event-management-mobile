import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_counters.g.dart';

@JsonSerializable()
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

  final int upcoming;
  final int ongoing;
  final int completed;
  final int cancelled;
  final int manage;

  @override
  List<Object> get props => [upcoming, ongoing, completed, cancelled, manage];
}
