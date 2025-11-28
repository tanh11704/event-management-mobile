import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Chào mừng đến với VKU Events',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.vkuBlue,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spaceXM),
        Text(
          'Tạo tài khoản để theo dõi sự kiện, nhận thông báo\n'
          'và tham gia bình chọn thú vị.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.coolGray700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
