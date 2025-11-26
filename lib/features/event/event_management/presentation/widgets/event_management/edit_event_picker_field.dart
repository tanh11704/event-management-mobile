import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EditEventPickerField extends StatelessWidget {
  const EditEventPickerField({
    required this.label,
    required this.text,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: text),
      readOnly: true,
      onTap: onTap,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.coolGray900),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.coolGray700,
        ),
        prefixIcon: Icon(icon, color: AppColors.vkuBlue, size: 22),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.vkuBlue, width: 2),
        ),
      ),
    );
  }
}
