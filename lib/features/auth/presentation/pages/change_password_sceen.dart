import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/router/app_router.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_state.dart';
import 'package:event_management/features/auth/presentation/widgets/change_password_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              // Gradient Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.vkuBlue,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.white,
                  ),
                  onPressed: appRouter.pop,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.spaceLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spaceXM),
                            Flexible(
                              child: Text(
                                'Đổi mật khẩu',
                                style: AppTextStyles.heading1.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spaceXS),
                            Flexible(
                              child: Text(
                                'Bảo mật tài khoản của bạn',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.spaceLG),
                  child: Center(
                    child: SingleChildScrollView(
                      child: ChangePasswordCard(isLoading: isLoading),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      listener: (context, state) {
        if (state is ChangePasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: AppSpacing.spaceMD),
                  Expanded(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(AppSpacing.spaceMD),
            ),
          );
        } else if (state is ChangePasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: AppSpacing.spaceMD),
                  Expanded(
                    child: Text(
                      'Đổi mật khẩu thành công!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.green500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(AppSpacing.spaceMD),
            ),
          );
          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              appRouter.pop();
            }
          });
        }
      },
    );
  }
}
