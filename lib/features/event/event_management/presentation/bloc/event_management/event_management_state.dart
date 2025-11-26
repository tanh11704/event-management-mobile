import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class EventManagementState extends Equatable {
  const EventManagementState();

  @override
  List<Object?> get props => [];
}

class EventManagementInitial extends EventManagementState {}

class EventManagementQrCheckLoading extends EventManagementState {
  const EventManagementQrCheckLoading({this.isRefreshing = false});

  final bool isRefreshing;

  @override
  List<Object?> get props => [isRefreshing];
}

class EventManagementQrCheckSuccess extends EventManagementState {
  const EventManagementQrCheckSuccess({required this.qrCodeBytes});

  final Uint8List qrCodeBytes;

  @override
  List<Object> get props => [qrCodeBytes];
}

class EventManagementQrCheckError extends EventManagementState {
  const EventManagementQrCheckError({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}
