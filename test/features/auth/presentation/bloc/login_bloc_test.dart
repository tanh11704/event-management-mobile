import 'package:bloc_test/bloc_test.dart';
import 'package:event_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_event.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginBloc loginBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginBloc = LoginBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    loginBloc.close();
  });

  // Test 1: Kiểm tra trạng thái khởi tạo
  test('Trạng thái khởi tạo của BLoC phải là LoginInitial', () {
    expect(loginBloc.state, equals(const LoginInitial()));
  });

  // Test 2: Nhóm các test cho sự kiện LoginSubmitted
  group('LoginSubmitted Event', () {
    const tEmail = 'anhtp.22it@vku.udn.vn';
    const tPassword = '1234567';

    // Test 2a: Kịch bản ĐĂNG NHẬP THÀNH CÔNG
    blocTest<LoginBloc, LoginState>(
      'phát ra [LoginLoading, LoginSuccess] khi đăng nhập thành công',
      setUp: () {
        when(
          mockAuthRepository.login(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => Future.value());
      },

      build: () => loginBloc,
      act: (bloc) =>
          bloc.add(const LoginSubmitted(email: tEmail, password: tPassword)),
      expect: () => <LoginState>[const LoginLoading(), const LoginSuccess()],
      verify: (_) {
        verify(
          mockAuthRepository.login(email: tEmail, password: tPassword),
        ).called(1);
      },
    );

    // Test 2b: Kịch bản ĐĂNG NHẬP THẤT BẠI
    blocTest<LoginBloc, LoginState>(
      'phát ra [LoginLoading, LoginFailure] khi đăng nhập thất bại',
      setUp: () {
        when(
          mockAuthRepository.login(email: tEmail, password: tPassword),
        ).thenThrow(Exception('Sai thông tin đăng nhập'));
      },
      build: () => loginBloc,
      act: (bloc) =>
          bloc.add(const LoginSubmitted(email: tEmail, password: tPassword)),
      expect: () => <LoginState>[
        const LoginLoading(),
        const LoginFailure('Sai thông tin đăng nhập'),
      ],
      verify: (_) {
        verify(
          mockAuthRepository.login(email: tEmail, password: tPassword),
        ).called(1);
      },
    );
  });
}
