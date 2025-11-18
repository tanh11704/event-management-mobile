import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:flutter/material.dart';

class EventStatusBadge extends StatelessWidget {
  const EventStatusBadge({required this.status, super.key});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;
    LinearGradient? gradient;

    switch (status) {
      case EventStatus.upcoming:
        backgroundColor = AppColors.vkuBlue;
        textColor = AppColors.white;
        label = 'Sắp diễn ra';
        icon = Icons.schedule_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.vkuBlue, AppColors.blue400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EventStatus.ongoing:
        backgroundColor = AppColors.green500;
        textColor = AppColors.white;
        label = 'Đang diễn ra';
        icon = Icons.play_circle_filled_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.green500, AppColors.green800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EventStatus.completed:
        backgroundColor = AppColors.coolGray900;
        textColor = AppColors.white;
        label = 'Đã kết thúc';
        icon = Icons.check_circle_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.coolGray900, AppColors.coolGray700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EventStatus.cancelled:
        backgroundColor = AppColors.red500;
        textColor = AppColors.white;
        label = 'Đã hủy';
        icon = Icons.cancel_rounded;
        gradient = const LinearGradient(
          colors: [AppColors.red500, AppColors.red800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
