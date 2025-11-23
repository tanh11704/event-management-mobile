import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Search bar widget dành riêng cho admin dashboard
class AdminEventSearchBar extends StatelessWidget {
  const AdminEventSearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.coolGray500.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sự kiện...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.coolGray500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.coolGray500.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
