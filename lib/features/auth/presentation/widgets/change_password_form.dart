import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/widgets/password_text_field.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_bloc.dart';
import 'package:event_management/features/auth/presentation/bloc/change_password/change_password_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({required this.isLoading, super.key});

  final bool isLoading;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _passwordStrength;
  Color? _passwordStrengthColor;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = null;
        _passwordStrengthColor = null;
      });
      return;
    }

    var strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp('[A-Z]').hasMatch(password)) strength++;
    if (RegExp('[a-z]').hasMatch(password)) strength++;
    if (RegExp('[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    setState(() {
      if (strength <= 2) {
        _passwordStrength = 'Yếu';
        _passwordStrengthColor = AppColors.red500;
      } else if (strength <= 4) {
        _passwordStrength = 'Trung bình';
        _passwordStrengthColor = AppColors.amber400;
      } else {
        _passwordStrength = 'Mạnh';
        _passwordStrengthColor = AppColors.green500;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Thông tin mật khẩu',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.coolGray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Text(
            'Nhập mật khẩu hiện tại và mật khẩu mới để bảo mật tài khoản',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.coolGray700,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXL),

          // Old Password
          PasswordTextField(
            controller: _oldPasswordController,
            labelText: 'Mật khẩu hiện tại',
            hintText: 'Nhập mật khẩu hiện tại',
            obscureText: _obscureOldPassword,
            onToggleVisibility: () {
              setState(() => _obscureOldPassword = !_obscureOldPassword);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu hiện tại';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.spaceLG),

          // New Password
          PasswordTextField(
            controller: _newPasswordController,
            labelText: 'Mật khẩu mới',
            hintText: 'Nhập mật khẩu mới',
            obscureText: _obscureNewPassword,
            onToggleVisibility: () {
              setState(() => _obscureNewPassword = !_obscureNewPassword);
            },
            onChanged: _validatePasswordStrength,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu mới';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              if (value == _oldPasswordController.text) {
                return 'Mật khẩu mới phải khác mật khẩu cũ';
              }
              return null;
            },
          ),

          // Password Strength Indicator
          if (_passwordStrength != null &&
              _newPasswordController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.spaceXM),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _passwordStrengthColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceXM),
                  Text(
                    'Độ mạnh: $_passwordStrength',
                    style: AppTextStyles.caption.copyWith(
                      color: _passwordStrengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.spaceLG),

          // Confirm Password
          PasswordTextField(
            controller: _confirmPasswordController,
            labelText: 'Xác nhận mật khẩu mới',
            hintText: 'Nhập lại mật khẩu mới',
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu mới';
              }
              if (value != _newPasswordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.spaceXL),

          // Submit Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            child: widget.isLoading
                ? Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.vkuBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ChangePasswordBloc>().add(
                          ChangePasswordSubmitted(
                            oldPassword: _oldPasswordController.text,
                            newPassword: _newPasswordController.text,
                            confirmPassword: _confirmPasswordController.text,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vkuBlue,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.spaceMD,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vkuBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_reset_rounded, size: 24),
                          const SizedBox(width: AppSpacing.spaceXM),
                          Text(
                            'Đổi mật khẩu',
                            style: AppTextStyles.heading5.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
