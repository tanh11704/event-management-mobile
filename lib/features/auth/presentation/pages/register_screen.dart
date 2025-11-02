import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/register/register_state.dart';
import 'package:event_management/features/auth/presentation/widgets/register_form.dart';
import 'package:event_management/features/auth/presentation/widgets/register_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: AppColors.background),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.spaceLG),
                  child: Column(
                    children: [
                      // ===== Logo VKU =====
                      Image.asset('assets/images/vku_logo.png', height: 80),
                      const SizedBox(height: AppSpacing.spaceLG),

                      // ===== Tiêu đề =====
                      const RegisterHeader(),
                      const SizedBox(height: AppSpacing.spaceXL),

                      // ===== Form Container =====
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.spaceLG),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coolGray500.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const RegisterForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}
