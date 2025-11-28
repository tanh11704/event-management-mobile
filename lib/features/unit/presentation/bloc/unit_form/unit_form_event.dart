import 'package:equatable/equatable.dart';
import 'package:event_management/features/unit/data/model/unit_request_dto.dart';

abstract class UnitFormEvent extends Equatable {
  const UnitFormEvent();

  @override
  List<Object?> get props => [];
}

class UnitFormInitialized extends UnitFormEvent {
  const UnitFormInitialized(this.unitId);

  final int? unitId;

  @override
  List<Object?> get props => [unitId];
}

class UnitFormSubmitted extends UnitFormEvent {
  const UnitFormSubmitted({required this.dto, this.unitId});

  final UnitRequestDto dto;
  final int? unitId;

  @override
  List<Object?> get props => [dto, unitId];
}

class UnitFormReset extends UnitFormEvent {
  const UnitFormReset();
}
