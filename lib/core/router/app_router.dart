import 'package:event_management/core/di/injection_container.dart';
import 'package:event_management/features/auth/presentation/bloc/login_bloc.dart';
import 'package:event_management/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
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
  ],
);
