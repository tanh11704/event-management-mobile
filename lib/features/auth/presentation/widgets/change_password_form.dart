import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/widgets/password_text_field.dart';
import 'package:flutter/material.dart';

/// Form đổi mật khẩu
class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PasswordTextField(
          hintText: 'Mật khẩu hiện tại',
          icon: Icons.lock_outline,
          isPasswordVisible: _isCurrentPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
            });
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        PasswordTextField(
          hintText: 'Mật khẩu mới',
          icon: Icons.lock,
          isPasswordVisible: _isNewPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isNewPasswordVisible = !_isNewPasswordVisible;
            });
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        PasswordTextField(
          hintText: 'Xác nhận mật khẩu mới',
          icon: Icons.lock_outline,
          isPasswordVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        const SizedBox(height: AppSpacing.spaceXL),
        _buildChangePasswordButton(),
        const SizedBox(height: AppSpacing.spaceMD),
        _buildBackToLoginLink(),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement change password logic
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vkuBlue,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceMD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(
        'Đổi mật khẩu',
        style: AppTextStyles.heading5.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Quay lại trang ', style: AppTextStyles.bodyMedium),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to login screen
          },
          child: Text(
            'Đăng nhập',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.vkuBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
