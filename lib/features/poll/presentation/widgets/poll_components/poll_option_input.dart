import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Widget input cho một poll option
class PollOptionInput extends StatelessWidget {
  const PollOptionInput({
    required this.controller,
    required this.index,
    required this.onDelete,
    this.isDeletable = true,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final int index;
  final VoidCallback onDelete;
  final bool isDeletable;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            validator: validator,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.coolGray900,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập lựa chọn ${index + 1}',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.coolGray500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.vkuBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.vkuBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.vkuBlue,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.red500,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (isDeletable) ...[
          const SizedBox(width: AppSpacing.spaceXM),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.red500,
                size: 20,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
