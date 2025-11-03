import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:event_management/features/auth/presentation/bloc/forgot_password/forgot_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordSubmitted(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (context, state) {
        final isLoading = state is ForgotPasswordLoading;
        final isSuccess = state is ForgotPasswordSuccess;

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

                      // ===== Tiêu đề ứng dụng =====
                      Text(
                        'Quản Lý Sự Kiện VKU',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.vkuBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ===== Tiêu đề =====
                              Text(
                                'Quên mật khẩu?',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.coolGray900,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.spaceXM),
                              Text(
                                isSuccess
                                    ? 'Chúng tôi đã gửi liên kết đặt lại mật khẩu đến email của bạn. Vui lòng kiểm tra hộp thư.'
                                    : 'Nhập email của bạn để nhận liên kết đặt lại mật khẩu',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.coolGray500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.spaceLG),

                              if (!isSuccess) ...[
                                // ===== Email =====
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !isLoading,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined),
                                    labelText: 'Nhập email của bạn',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập email';
                                    }
                                    if (!_emailRegex.hasMatch(value.trim())) {
                                      return 'Email không hợp lệ';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.spaceMD),

                                // ===== Nút gửi =====
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: isLoading
                                        ? null
                                        : AppColors.primaryGradient,
                                    color: isLoading
                                        ? AppColors.coolGray50
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : _onSubmitPressed,
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.spaceMD,
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: AppColors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : const Text(
                                            'Gửi yêu cầu',
                                            style: TextStyle(
                                              color: AppColors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceLG),

                      // ===== Quay lại đăng nhập =====
                      if (!isSuccess)
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.pop();
                                },
                          child: Text(
                            'Quay lại đăng nhập',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.vkuBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
        if (state is ForgotPasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}
