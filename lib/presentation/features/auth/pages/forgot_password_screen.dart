import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final RegExp _emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  ); // RegEx kiểm tra email cơ bản

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liên kết đặt lại mật khẩu đã được gửi')),
      );

      // Sau khi gửi thành công → chuyển qua màn hình đặt lại mật khẩu
      Navigator.pushNamed(context, '/reset-password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.background),
        width: double.infinity,
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
                  Text(
                    'Quên mật khẩu VKU Events',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.vkuBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spaceXL),

                  // ===== Khung form =====
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
                          Text(
                            'Đặt lại mật khẩu',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.coolGray900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceXM),
                          Text(
                            'Nhập email hoặc tài khoản để nhận liên kết đặt lại.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.coolGray500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spaceLG),

                          // ===== Ô nhập email =====
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              labelText: 'Email hoặc tài khoản',
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
                          const SizedBox(height: AppSpacing.spaceLG),

                          // ===== Nút gửi yêu cầu =====
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _onSendPressed,
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
                              child: const Text(
                                'Gửi liên kết đặt lại',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Quay lại đăng nhập =====
                  TextButton(
                    onPressed: () => Navigator.pop(context),
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
  }
}
