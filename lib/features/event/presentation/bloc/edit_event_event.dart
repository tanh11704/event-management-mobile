import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class EditEventEvent extends Equatable {
  const EditEventEvent();
  @override
  List<Object?> get props => [];
}

/// Event được gọi khi người dùng nhấn nút "Lưu thay đổi"
class EditEventSubmitted extends EditEventEvent {
  // Thêm đầy đủ các trường
  const EditEventSubmitted({
    required this.eventId,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.newBannerImage,
  });

  final int eventId;
  final String name;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;

  final XFile? newBannerImage;

  @override
  List<Object?> get props => [
    eventId,
    name,
    description,
    location,
    startDate,
    endDate,
    newBannerImage,
  ];
}
