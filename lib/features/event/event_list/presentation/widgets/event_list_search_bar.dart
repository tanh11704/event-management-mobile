import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventListSearchBar extends StatelessWidget {
  const EventListSearchBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.vkuBlue.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.coolGray900.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sự kiện...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.coolGray500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isFocused ? AppColors.vkuBlue : AppColors.coolGray500,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  color: AppColors.coolGray500,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isFocused ? AppColors.vkuBlue : AppColors.border,
              width: isFocused ? 2 : 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isFocused ? AppColors.vkuBlue : AppColors.border,
              width: isFocused ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.vkuBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD,
            vertical: AppSpacing.spaceMD,
          ),
        ),
      ),
    );
  }
}
