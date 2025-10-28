import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/widgets/vku_logo.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/widgets/change_password_card.dart';
import 'package:event_management/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Màn hình đổi mật khẩu
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChangePasswordBloc>(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.background),
          child: const SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.spaceLG),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VKULogo(),
                    SizedBox(height: AppSpacing.spaceXL),
                    ChangePasswordCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
