import 'package:equatable/equatable.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';

abstract class UnitFormState extends Equatable {
  const UnitFormState();

  @override
  List<Object?> get props => [];
}

class UnitFormInitial extends UnitFormState {
  const UnitFormInitial();
}

class UnitFormLoading extends UnitFormState {
  const UnitFormLoading();
}

class UnitFormLoadSuccess extends UnitFormState {
  const UnitFormLoadSuccess(this.unit);

  final UnitEntity unit;

  @override
  List<Object?> get props => [unit];
}

class UnitFormSuccess extends UnitFormState {
  const UnitFormSuccess(this.unit);

  final UnitEntity unit;

  @override
  List<Object?> get props => [unit];
}

class UnitFormError extends UnitFormState {
  const UnitFormError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
