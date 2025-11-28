import 'package:bloc/bloc.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_form/unit_form_event.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_form/unit_form_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class UnitFormBloc extends Bloc<UnitFormEvent, UnitFormState> {
  UnitFormBloc(this._unitRepository) : super(const UnitFormInitial()) {
    on<UnitFormInitialized>(_onInitialized);
    on<UnitFormSubmitted>(_onSubmitted);
    on<UnitFormReset>(_onReset);
  }

  final UnitRepository _unitRepository;

  Future<void> _onInitialized(
    UnitFormInitialized event,
    Emitter<UnitFormState> emit,
  ) async {
    if (event.unitId == null) {
      return;
    }

    emit(const UnitFormLoading());

    try {
      final unit = await _unitRepository.getUnit(event.unitId!);
      emit(UnitFormLoadSuccess(unit));
    } catch (e) {
      emit(UnitFormError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSubmitted(
    UnitFormSubmitted event,
    Emitter<UnitFormState> emit,
  ) async {
    emit(const UnitFormLoading());

    try {
      final unit = event.unitId == null
          ? await _unitRepository.createUnit(event.dto)
          : await _unitRepository.updateUnit(event.unitId!, event.dto);
      emit(UnitFormSuccess(unit));
    } catch (e) {
      emit(UnitFormError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onReset(UnitFormReset event, Emitter<UnitFormState> emit) {
    emit(const UnitFormInitial());
  }
}
