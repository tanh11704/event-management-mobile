import 'package:equatable/equatable.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterUnitsLoaded extends RegisterState {
  const RegisterUnitsLoaded({
    required this.allUnits,
    required this.accountTypes,
    required this.filteredUnits,
    this.selectedAccountTypeId,
  });
  final List<UnitEntity> allUnits;
  final List<UnitEntity> accountTypes;
  final List<UnitEntity> filteredUnits;
  final int? selectedAccountTypeId;

  RegisterUnitsLoaded copyWith({
    List<UnitEntity>? allUnits,
    List<UnitEntity>? accountTypes,
    List<UnitEntity>? filteredUnits,
    int? selectedAccountTypeId,
  }) {
    return RegisterUnitsLoaded(
      allUnits: allUnits ?? this.allUnits,
      accountTypes: accountTypes ?? this.accountTypes,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      selectedAccountTypeId:
          selectedAccountTypeId ?? this.selectedAccountTypeId,
    );
  }

  @override
  List<Object?> get props => [
    allUnits,
    accountTypes,
    filteredUnits,
    selectedAccountTypeId,
  ];
}

class RegisterFailure extends RegisterState {
  const RegisterFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
