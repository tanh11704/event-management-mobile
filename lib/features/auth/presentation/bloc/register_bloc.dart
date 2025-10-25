import 'package:bloc/bloc.dart';
import 'package:event_management/features/auth/data/models/register_request_dto.dart';
import 'package:event_management/features/auth/domain/repository/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/register_event.dart';
import 'package:event_management/features/auth/presentation/bloc/register_state.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this.authRepository) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }
  final AuthRepository authRepository;

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      await authRepository.register(
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
}
