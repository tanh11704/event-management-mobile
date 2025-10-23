import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    required this.hintText,
    required this.icon,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    super.key,
    this.controller,
  });

  final String hintText;
  final IconData icon;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.coolGray900),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.coolGray500,
        ),
        prefixIcon: Icon(icon, color: AppColors.coolGray500),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.coolGray500,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.vkuBlue, width: 2),
        ),
      ),
    );
  }
}
