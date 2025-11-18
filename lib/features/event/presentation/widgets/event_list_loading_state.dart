import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventListLoadingState extends StatelessWidget {
  const EventListLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.vkuBlue),
            ),
            const SizedBox(height: AppSpacing.spaceMD),
            Text('Đang tải sự kiện...', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
