import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart' as app_spacing;
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/cupertino.dart';

class VKULogo extends StatelessWidget {
  const VKULogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(app_spacing.AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.vkuBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'VKU',
        style: AppTextStyles.heading1.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.vkuBlue,
        ),
      ),
    );
  }
}
