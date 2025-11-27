import 'package:equatable/equatable.dart';

abstract class UpdatePollState extends Equatable {
  const UpdatePollState();

  @override
  List<Object?> get props => [];
}

class UpdatePollInitial extends UpdatePollState {
  const UpdatePollInitial();
}

class UpdatePollLoading extends UpdatePollState {
  const UpdatePollLoading();
}

class UpdatePollSuccess extends UpdatePollState {
  const UpdatePollSuccess();
}

class UpdatePollFailure extends UpdatePollState {
  const UpdatePollFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
