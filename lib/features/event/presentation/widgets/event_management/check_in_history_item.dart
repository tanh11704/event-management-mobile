import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/utils/date_time_formatter.dart';
import 'package:event_management/features/event/data/models/participant.dart';
import 'package:flutter/material.dart';

class CheckInHistoryItem extends StatefulWidget {
  const CheckInHistoryItem({
    required this.participant,
    required this.index,
    super.key,
  });

  final ParticipantInfo participant;
  final int index;

  @override
  State<CheckInHistoryItem> createState() => _CheckInHistoryItemState();
}

class _CheckInHistoryItemState extends State<CheckInHistoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Delay animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMD,
            vertical: AppSpacing.spaceXS,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.green500.withOpacity(0.1),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.green500,
              size: 20,
            ),
          ),
          title: Text(
            widget.participant.userName,
            style: AppTextStyles.heading5,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.participant.userEmail != null) ...[
                Text(
                  widget.participant.userEmail!,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.spaceXS),
              ],
              Text(
            widget.participant.checkedTime != null
                ? 'Check-in lúc ${DateTimeFormatter.formatTime(widget.participant.checkedTime!)}'
                : 'Đã check-in',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.coolGray500,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceXM,
              vertical: AppSpacing.spaceXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.green500,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
