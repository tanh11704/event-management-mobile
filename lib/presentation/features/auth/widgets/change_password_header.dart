import 'package:event_management/core/config/app_colors.dart' as app_colors;
import 'package:event_management/core/config/app_spacing.dart' as app_spacing;
import 'package:event_management/core/config/app_text_styles.dart'
    as app_text_styles;
import 'package:flutter/cupertino.dart';

class CardHeader extends StatelessWidget {
  const CardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Đổi mật khẩu',
          style: app_text_styles.AppTextStyles.heading2.copyWith(
            color: app_colors.AppColors.coolGray900,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: app_spacing.AppSpacing.spaceXM),
        Text(
          'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới',
          style: app_text_styles.AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
