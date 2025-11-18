import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    required this.hintText,
    required this.obscureText,
    required this.onToggleVisibility,
    super.key,
    this.controller,
    this.labelText,
    this.icon = Icons.lock_outline_rounded,
    this.validator,
    this.onChanged,
  });

  final String hintText;
  final String? labelText;
  final IconData icon;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.coolGray900,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.coolGray700,
          fontWeight: FontWeight.w600,
        ),
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.coolGray500,
        ),
        prefixIcon: Icon(icon, color: AppColors.coolGray500),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.coolGray500,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.vkuBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.red500, width: 2),
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red500),
      ),
    );
  }
}
