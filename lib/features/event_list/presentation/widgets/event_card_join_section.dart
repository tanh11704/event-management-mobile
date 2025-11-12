import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event_list/data/models/event.dart';
import 'package:event_management/features/event_list/data/models/event_status.dart';
import 'package:flutter/material.dart';

class EventCardJoinSection extends StatelessWidget {
  const EventCardJoinSection({
    required this.event,
    this.onJoinTap,
    this.isJoined = false,
    this.isJoining = false,
    super.key,
  });

  final Event event;
  final VoidCallback? onJoinTap;
  final bool isJoined;
  final bool isJoining;

  @override
  Widget build(BuildContext context) {
    final status = event.status;
    final current = event.currentParticipants ?? 0;
    final max = event.maxParticipants ?? 0;
    final isFull = max > 0 && current >= max;
    final canJoin =
        (status == EventStatus.upcoming || status == EventStatus.ongoing) &&
        !isFull &&
        !isJoined;

    Color buttonColor;
    Gradient? buttonGradient;
    String label;
    IconData icon;
    Color labelColor;
    final enabled = canJoin && onJoinTap != null && !isJoining;

    if (isJoined) {
      buttonColor = AppColors.green500;
      label = 'Đã tham gia';
      icon = Icons.check_rounded;
      labelColor = AppColors.white;
    } else if (isFull) {
      buttonColor = AppColors.coolGray50;
      label = 'Đã đủ chỗ';
      icon = Icons.event_busy_rounded;
      labelColor = AppColors.coolGray700;
    } else if (status == EventStatus.completed) {
      buttonColor = AppColors.coolGray50;
      label = 'Đã kết thúc';
      icon = Icons.flag_rounded;
      labelColor = AppColors.coolGray700;
    } else if (status == EventStatus.cancelled) {
      buttonColor = AppColors.coolGray50;
      label = 'Đã hủy';
      icon = Icons.cancel_rounded;
      labelColor = AppColors.coolGray700;
    } else {
      buttonColor = AppColors.vkuBlue;
      buttonGradient = AppColors.primaryGradient;
      label = 'Tham gia';
      icon = Icons.how_to_reg_rounded;
      labelColor = AppColors.white;
    }

    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.spaceXS,
        bottom: AppSpacing.spaceMD,
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              height: 40,
              decoration: BoxDecoration(
                color: buttonGradient == null ? buttonColor : null,
                gradient: buttonGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (enabled || isJoined)
                    BoxShadow(
                      color:
                          (buttonGradient != null
                                  ? AppColors.vkuBlue
                                  : buttonColor)
                              .withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  BoxShadow(
                    color: AppColors.coolGray900.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: enabled || isJoined
                      ? Colors.transparent
                      : AppColors.border,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: enabled ? onJoinTap : null,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: isJoining
                          ? SizedBox(
                              key: const ValueKey('joining'),
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  labelColor,
                                ),
                                backgroundColor: labelColor.withOpacity(0.25),
                              ),
                            )
                          : Row(
                              key: const ValueKey('label'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 18, color: labelColor),
                                const SizedBox(width: 8),
                                Text(
                                  label,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: labelColor,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
