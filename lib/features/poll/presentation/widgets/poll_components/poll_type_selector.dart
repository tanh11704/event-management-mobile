import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/poll/domain/entities/poll_type.dart';
import 'package:flutter/material.dart';

/// Widget chọn loại poll (Single/Multiple choice)
class PollTypeSelector extends StatelessWidget {
  const PollTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
    super.key,
  });

  final PollType selectedType;
  final ValueChanged<PollType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PollTypeOption(
              type: PollType.singleChoice,
              isSelected: selectedType == PollType.singleChoice,
              onTap: () => onTypeChanged(PollType.singleChoice),
            ),
          ),
          Expanded(
            child: _PollTypeOption(
              type: PollType.multipleChoice,
              isSelected: selectedType == PollType.multipleChoice,
              onTap: () => onTypeChanged(PollType.multipleChoice),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollTypeOption extends StatelessWidget {
  const _PollTypeOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final PollType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.spaceMD,
          horizontal: AppSpacing.spaceMD,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vkuBlue.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.vkuBlue, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == PollType.singleChoice
                  ? Icons.radio_button_checked
                  : Icons.check_box,
              color: isSelected ? AppColors.vkuBlue : AppColors.coolGray500,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.spaceXS),
            Text(
              type.label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.vkuBlue : AppColors.coolGray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
