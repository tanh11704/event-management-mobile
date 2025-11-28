import 'package:bloc/bloc.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_event.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_state.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository authRepository,
    required UnitRepository unitRepository,
  }) : _authRepository = authRepository,
       _unitRepository = unitRepository,
       super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterGetUnits>(_onFetchUnits);
    on<RegisterAccountTypeChanged>(_onAccountTypeChanged);
  }

  final AuthRepository _authRepository;
  final UnitRepository _unitRepository;

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      await _authRepository.register(
        RegisterRequestDto(
          name: event.name,
          email: event.email,
          phoneNumber: event.phoneNumber,
          password: event.password,
          confirmPassword: event.confirmPassword,
          unitId: event.unitId,
        ),
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }

  Future<void> _onFetchUnits(
    RegisterGetUnits event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    final result = await _unitRepository.getAllUnits();

    // Account types are units where parentId is null OR parentId equals its own id (self-reference)
    final accountTypes = result
        .where((u) => u.parentId == null || u.parentId == u.id)
        .toList();

    emit(
      RegisterUnitsLoaded(
        allUnits: result,
        accountTypes: accountTypes,
        filteredUnits: const [],
      ),
    );
  }

  Future<void> _onAccountTypeChanged(
    RegisterAccountTypeChanged event,
    Emitter<RegisterState> emit,
  ) async {
    if (state is RegisterUnitsLoaded) {
      final loaded = state as RegisterUnitsLoaded;
      // Filter units where parentId equals the selected account type id
      // and exclude self-referencing units (where parentId == id)
      final filtered = loaded.allUnits
          .where((u) => u.parentId == event.typeId && u.parentId != u.id)
          .toList();
      emit(
        loaded.copyWith(
          selectedAccountTypeId: event.typeId,
          filteredUnits: filtered,
        ),
      );
    }
  }
}
