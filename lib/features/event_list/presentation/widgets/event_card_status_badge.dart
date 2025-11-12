import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event_list/data/models/event_status.dart';
import 'package:flutter/material.dart';

class EventCardStatusBadge extends StatelessWidget {
  const EventCardStatusBadge({required this.status, super.key});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case EventStatus.upcoming:
        backgroundColor = AppColors.vkuBlue;
        textColor = AppColors.white;
        label = 'Sắp diễn ra';
        icon = Icons.schedule_rounded;
      case EventStatus.ongoing:
        backgroundColor = AppColors.green500;
        textColor = AppColors.white;
        label = 'Đang diễn ra';
        icon = Icons.play_circle_filled_rounded;
      case EventStatus.completed:
        backgroundColor = AppColors.coolGray700;
        textColor = AppColors.white;
        label = 'Đã kết thúc';
        icon = Icons.check_circle_rounded;
      case EventStatus.cancelled:
        backgroundColor = AppColors.red500;
        textColor = AppColors.white;
        label = 'Đã hủy';
        icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
