import 'package:equatable/equatable.dart';

abstract class CreatePollState extends Equatable {
  const CreatePollState();

  @override
  List<Object?> get props => [];
}

class CreatePollInitial extends CreatePollState {
  const CreatePollInitial();
}

class CreatePollLoading extends CreatePollState {
  const CreatePollLoading();
}

class CreatePollSuccess extends CreatePollState {
  const CreatePollSuccess();
}

class CreatePollFailure extends CreatePollState {
  const CreatePollFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
