import 'package:equatable/equatable.dart';

abstract class EditEventState extends Equatable {
  const EditEventState();
  @override
  List<Object> get props => [];
}

/// Trạng thái ban đầu, chờ người dùng chỉnh sửa
class EditEventInitial extends EditEventState {}

/// Trạng thái đang gửi dữ liệu lên server
class EditEventLoading extends EditEventState {}

/// Trạng thái cập nhật thành công
class EditEventSuccess extends EditEventState {}

/// Trạng thái cập nhật thất bại
class EditEventFailure extends EditEventState {
  final String error;
  const EditEventFailure(this.error);
  @override
  List<Object> get props => [error];
}
