import 'package:equatable/equatable.dart';

abstract class EditEventEvent extends Equatable {
  const EditEventEvent();
  @override
  List<Object> get props => [];
}

/// Event được gọi khi người dùng nhấn nút "Lưu thay đổi"
class EditEventSubmitted extends EditEventEvent {
  // ... Thêm các trường dữ liệu mới khác

  const EditEventSubmitted({
    required this.eventId,
    required this.newName,
    // ...
  });
  final String eventId;
  final String newName;

  @override
  List<Object> get props => [eventId, newName];
}
