import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:event_management/features/event/domain/repositories/event_repository.dart';

class GetEventDetailUseCase {
  GetEventDetailUseCase(this._repository);

  final EventRepository _repository;

  Future<EventDetailResponse> call(int eventId) async {
    return _repository.getEventDetail(eventId);
  }
}
