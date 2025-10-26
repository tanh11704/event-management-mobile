import 'package:event_management/core/config/app_theme.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password_screen.dart';
import 'package:event_management/features/auth/presentation/bloc/login_screen.dart';
import 'package:event_management/features/auth/presentation/bloc/reset_password_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,

      //  Khai báo route name chuẩn
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
