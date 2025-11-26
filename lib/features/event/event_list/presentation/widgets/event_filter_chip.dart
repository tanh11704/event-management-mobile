import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventFilterChip extends StatelessWidget {
  const EventFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.gradient,
    this.color,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = color ?? AppColors.coolGray50;

    LinearGradient? chipGradient;
    if (isSelected && gradient != null) {
      chipGradient = gradient;
    } else if (isSelected && color != null) {
      Color? lightColor;
      switch (color) {
        case AppColors.vkuBlue:
          lightColor = AppColors.blue400;
        case AppColors.green500:
          lightColor = AppColors.green800;
        case AppColors.coolGray700:
          lightColor = AppColors.coolGray500;
        case AppColors.red500:
          lightColor = AppColors.red800;
        default:
          lightColor = color;
      }
      chipGradient = LinearGradient(
        colors: [color!, lightColor!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD + 2,
            vertical: AppSpacing.spaceMD,
          ),
          decoration: BoxDecoration(
            gradient: chipGradient,
            color: chipGradient == null && !isSelected ? backgroundColor : null,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
              width: isSelected ? 0 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (color ?? AppColors.vkuBlue).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: (color ?? AppColors.vkuBlue).withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.coolGray900.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label.isNotEmpty) ...[
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.white : AppColors.coolGray700,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.3)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.coolGray900.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  count.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.white : AppColors.coolGray700,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
