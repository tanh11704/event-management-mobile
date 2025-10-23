import 'package:event_management/features/event_list/data/models/page_response_model.dart';
import 'package:event_management/features/event_list/domain/entities/event.dart';
import 'package:event_management/features/event_list/domain/entities/event_counters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_page_response_model.g.dart';

@JsonSerializable(createToJson: false)
class EventPageResponseModel {
  const EventPageResponseModel({
    required this.pagination,
    required this.counters,
  });

  factory EventPageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EventPageResponseModelFromJson(json);

  @JsonKey(name: 'pagination', fromJson: _paginationFromJson)
  final PageResponseModel<Event> pagination;
  final EventCounters counters;

  /// Hàm helper tĩnh giúp `json_serializable` parse đối tượng generic.
  static PageResponseModel<Event> _paginationFromJson(
    Map<String, dynamic> json,
  ) {
    return PageResponseModel.fromJson(
      json,
      (e) => Event.fromJson(e! as Map<String, dynamic>),
    );
  }
}
