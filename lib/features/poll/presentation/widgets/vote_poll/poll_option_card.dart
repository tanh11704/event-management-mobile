import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/poll/data/models/option_response.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị một option trong poll với design đẹp
class PollOptionCard extends StatelessWidget {
  const PollOptionCard({
    required this.option,
    required this.isSelected,
    required this.pollType,
    required this.onTap,
    super.key,
  });

  final OptionResponse option;
  final bool isSelected;
  final PollType pollType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.spaceMD),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue50 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.vkuBlue : AppColors.border,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.vkuBlue.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.coolGray900.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: pollType == PollType.singleChoice
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: pollType == PollType.singleChoice
                    ? null
                    : BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.vkuBlue : AppColors.coolGray500,
                  width: 2,
                ),
                color: isSelected ? AppColors.vkuBlue : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      pollType == PollType.singleChoice
                          ? Icons.check_rounded
                          : Icons.check_rounded,
                      color: AppColors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.spaceMD),

            // Option text
            Expanded(
              child: Text(
                option.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.vkuBlue : AppColors.coolGray900,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Selected indicator icon
            if (isSelected)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.vkuBlue,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
