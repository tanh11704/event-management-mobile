import 'package:event_management/core/di/injection_container.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/auth/presentation/pages/change_password_sceen.dart';
import 'package:event_management/features/auth/presentation/pages/login_screen.dart';
import 'package:event_management/features/auth/presentation/pages/register_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String register = '/register';
  static const String changePassword = '/change-password';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<LoginBloc>(),
          child: const LoginScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      name: AppRoutes.register,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<RegisterBloc>(),
          child: const RegisterScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      name: AppRoutes.changePassword,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<ChangePasswordBloc>(),
          child: const ChangePasswordScreen(),
        );
      },
    ),
  ],
);
