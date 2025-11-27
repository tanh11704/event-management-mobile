import 'package:event_management/core/di/injection_container.dart';
import 'package:event_management/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:event_management/features/admin/presentation/pages/edit_event_screen.dart';
import 'package:event_management/features/admin/presentation/pages/user_management_screen.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/auth/presentation/pages/change_password_sceen.dart';
import 'package:event_management/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:event_management/features/auth/presentation/pages/login_screen.dart';
import 'package:event_management/features/auth/presentation/pages/register_screen.dart';
import 'package:event_management/features/event/event_create/presentation/bloc/create_event_bloc.dart';
import 'package:event_management/features/event/event_create/presentation/pages/create_event_screen.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_bloc.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_event.dart';
import 'package:event_management/features/event/event_detail/presentation/bloc/event_detail_state.dart';
import 'package:event_management/features/event/event_detail/presentation/pages/event_detail_screen.dart';
import 'package:event_management/features/event/event_list/presentation/bloc/event_list_bloc.dart';
import 'package:event_management/features/event/event_list/presentation/pages/event_list_screen.dart';
import 'package:event_management/features/event/event_management/presentation/pages/event_management_screen.dart';
import 'package:event_management/features/poll/presentation/pages/vote_poll_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String admin = '/admin';
  static const String eventList = '/events';
  static const String eventDetail = '/events/:id';
  static const String register = '/register';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String createEvent = '/create-event';
  static const String userManagement = '/admin/user-management';
  static const String eventManagement = '/events/:id/manage';
  static const String adminEditEvent = '/admin/events/:id/edit';
  static const String votePoll = '/polls/:id/vote';
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
      path: AppRoutes.admin,
      name: AppRoutes.admin,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<EventListBloc>(),
          child: const AdminDashboardScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.eventList,
      name: AppRoutes.eventList,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<EventListBloc>(),
          child: const EventListScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.eventDetail,
      name: AppRoutes.eventDetail,
      builder: (context, state) {
        final eventId = int.parse(state.pathParameters['id']!);
        return BlocProvider(
          create: (context) =>
              sl<EventDetailBloc>()..add(EventDetailFetch(eventId: eventId)),
          child: EventDetailScreen(eventId: eventId),
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
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<ForgotPasswordBloc>(),
          child: const ForgotPasswordScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.createEvent,
      name: AppRoutes.createEvent,
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<CreateEventBloc>(),
          child: const CreateEventScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.userManagement,
      name: AppRoutes.userManagement,
      builder: (context, state) {
        return const UserManagementScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.eventManagement,
      name: AppRoutes.eventManagement,
      builder: (context, state) {
        final eventId = int.parse(state.pathParameters['id']!);
        // Check if came from admin by checking referrer or extra
        final cameFromAdmin =
            state.uri.toString().contains('/admin') ||
            state.extra == true ||
            (state.uri.queryParameters['from'] == 'admin');
        return BlocProvider(
          create: (context) =>
              sl<EventDetailBloc>()..add(EventDetailFetch(eventId: eventId)),
          child: BlocBuilder<EventDetailBloc, EventDetailState>(
            builder: (context, state) {
              if (state is EventDetailSuccess) {
                return EventManagementScreen(
                  eventDetail: state.eventDetail,
                  cameFromAdmin: cameFromAdmin,
                );
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.adminEditEvent,
      name: AppRoutes.adminEditEvent,
      builder: (context, state) {
        final eventId = int.parse(state.pathParameters['id']!);
        return BlocProvider(
          create: (context) =>
              sl<EventDetailBloc>()..add(EventDetailFetch(eventId: eventId)),
          child: BlocBuilder<EventDetailBloc, EventDetailState>(
            builder: (context, state) {
              if (state is EventDetailSuccess) {
                return EditEventScreen(eventDetail: state.eventDetail);
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.votePoll,
      name: AppRoutes.votePoll,
      builder: (context, state) {
        final pollId = int.parse(state.pathParameters['id']!);
        return VotePollScreen(pollId: pollId);
      },
    ),
  ],
);
