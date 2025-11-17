import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.gradient,
    required this.icon,
    this.total,
    this.isFullWidth = false,
    super.key,
  });

  final String title;
  final String value;
  final String? total;
  final double progress;
  final Gradient gradient;
  final IconData icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray900.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ),
              Icon(icon, color: AppColors.white, size: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.heading1.copyWith(color: AppColors.white),
              ),
              if (total != null) ...[
                const SizedBox(width: AppSpacing.spaceXS),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    total!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.isFinite && !progress.isNaN
                  ? progress.clamp(0.0, 1.0)
                  : 0.0,
              minHeight: 8,
              backgroundColor: AppColors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
