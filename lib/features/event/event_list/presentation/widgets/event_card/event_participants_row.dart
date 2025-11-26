import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventParticipantsRow extends StatelessWidget {
  const EventParticipantsRow({
    super.key,
    this.currentParticipants,
    this.maxParticipants,
  });

  final int? currentParticipants;
  final int? maxParticipants;

  @override
  Widget build(BuildContext context) {
    final current = currentParticipants ?? 0;
    final max = maxParticipants ?? 0;
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.amber400.withOpacity(0.15),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(
            Icons.people_rounded,
            size: 13,
            color: AppColors.amber600,
          ),
        ),
        const SizedBox(width: AppSpacing.spaceXS + 2),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current / $max',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.coolGray700,
                  fontWeight: FontWeight.w500,

                  fontSize: 12,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // SỬA LỖI: Giảm SizedBox
              const SizedBox(
                height: AppSpacing.spaceXS, // (Giảm từ +2, tiết kiệm 2px)
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 4,
                  backgroundColor: AppColors.coolGray50,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 0.8
                        ? AppColors.red500
                        : percentage > 0.5
                        ? AppColors.amber400
                        : AppColors.green500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
