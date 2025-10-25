import 'package:dio/dio.dart';
import 'package:event_management/features/auth/data/repository/auth_repository_impl.dart';
import 'package:event_management/features/auth/presentation/bloc/register_bloc.dart';
import 'package:event_management/features/auth/presentation/widgets/register_form.dart';
import 'package:event_management/features/auth/presentation/widgets/register_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(AuthRepositoryImpl(),
      child: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [RegisterHeader(), SizedBox(height: 24), RegisterForm()],
          ),
        ),
      ),
    );
  }
}
