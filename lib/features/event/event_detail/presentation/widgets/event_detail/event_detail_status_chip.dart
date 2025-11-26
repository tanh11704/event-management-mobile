import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:flutter/material.dart';

class EventDetailStatusChip extends StatelessWidget {
  const EventDetailStatusChip({required this.status, super.key});

  final EventStatus status;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, textColor, label, icon, gradient) =
        _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String, IconData, LinearGradient) _getStatusConfig(
    EventStatus status,
  ) {
    switch (status) {
      case EventStatus.completed:
        return (
          AppColors.coolGray500,
          AppColors.white,
          'ĐÃ KẾT THÚC',
          Icons.check_circle_rounded,
          const LinearGradient(
            colors: [AppColors.coolGray500, AppColors.coolGray700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EventStatus.upcoming:
        return (
          AppColors.green500,
          AppColors.white,
          'SẮP DIỄN RA',
          Icons.schedule_rounded,
          const LinearGradient(
            colors: [AppColors.green500, AppColors.green800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EventStatus.ongoing:
        return (
          AppColors.blue400,
          AppColors.white,
          'ĐANG DIỄN RA',
          Icons.play_circle_filled_rounded,
          const LinearGradient(
            colors: [AppColors.blue400, AppColors.vkuBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EventStatus.cancelled:
        return (
          AppColors.red500,
          AppColors.white,
          'ĐÃ HỦY',
          Icons.cancel_rounded,
          const LinearGradient(
            colors: [AppColors.red500, AppColors.red800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}
