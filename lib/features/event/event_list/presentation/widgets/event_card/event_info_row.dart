import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventInfoRow extends StatelessWidget {
  const EventInfoRow({
    required this.icon,
    required this.text,
    required this.iconColor,
    super.key,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3), // Giảm từ 4 xuống 3
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 13, color: iconColor), // Giảm từ 14 xuống 13
        ),
        const SizedBox(
          width: AppSpacing.spaceXS + 2,
        ), // Giảm từ spaceXM xuống spaceXS + 2
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.coolGray700,
              fontWeight: FontWeight.w500,
              height: 1.3, // Giảm từ 1.4 xuống 1.3
              fontSize: 12, // Giảm từ 12.5 xuống 12
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
