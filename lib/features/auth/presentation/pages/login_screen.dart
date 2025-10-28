import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/auth/presentation/bloc/login_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/login_event.dart';
import 'package:event_management/features/auth/presentation/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const int _minPasswordLength = 6;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  final RegExp _emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  ); // regex email đơn giản

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state is LoginLoading;

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
                              // ===== Chào mừng =====
                              Text(
                                'Chào mừng bạn đến với VKU Events!',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.coolGray900,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.spaceXM),
                              Text(
                                'Đăng nhập để quản lý sự kiện dễ dàng',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.coolGray500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.spaceLG),

                              // ===== Email =====
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email_outlined),
                                  labelText: 'Nhập email hoặc tài khoản',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập email hoặc tài khoản';
                                  }
                                  if (!_emailRegex.hasMatch(value.trim())) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.spaceMD),

                              // ===== Mật khẩu =====
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                enabled: !isLoading,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  labelText: 'Nhập mật khẩu',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.coolGray500,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu';
                                  }
                                  if (value.length < _minPasswordLength) {
                                    return 'Mật khẩu phải có ít nhất $_minPasswordLength ký tự';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.spaceMD),

                              // ===== Checkbox Nhớ tài khoản =====
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.vkuBlue,
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                  ),
                                  Text(
                                    'Nhớ tài khoản',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.coolGray700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.spaceMD),

                              // ===== Nút đăng nhập (Gradient xanh từ AppColors.primaryGradient) =====
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
                                  onPressed: isLoading ? null : _onLoginPressed,
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
                                          'Đăng nhập',
                                          style: TextStyle(
                                            color: AppColors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceLG),

                      // ===== Quên mật khẩu + Đăng ký =====
                      Column(
                        children: [
                          TextButton(
                            onPressed: isLoading ? null : () {},
                            child: Text(
                              'Quên mật khẩu?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.vkuBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chưa có tài khoản?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.coolGray700,
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading ? null : () {},
                                child: Text(
                                  'Đăng ký ngay',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.vkuBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
        if (state is LoginFailure) {
          // Nếu đăng nhập thất bại, hiển thị SnackBar lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor:
                  Colors.red, // (Bạn nên thêm màu này vào AppColors)
            ),
          );
        } else if (state is LoginSuccess) {
          // Nếu đăng nhập thành công, hiển thị SnackBar thành công
          // Hoặc điều hướng sang màn hình Home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor:
                  Colors.green, // (Bạn nên thêm màu này vào AppColors)
            ),
          );
        }
      },
    );
  }
}
