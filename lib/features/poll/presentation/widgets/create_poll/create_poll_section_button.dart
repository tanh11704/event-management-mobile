import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/poll/presentation/widgets/create_poll/create_poll_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Section widget với button để mở bottom sheet tạo poll
class CreatePollSectionButton extends StatelessWidget {
  const CreatePollSectionButton({
    required this.eventId,
    this.onPollCreated,
    super.key,
  });

  final int eventId;
  final VoidCallback? onPollCreated;

  void _showCreatePollBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CreatePollBottomSheet(eventId: eventId, onPollCreated: onPollCreated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray900.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amber100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.poll_rounded,
                  color: AppColors.amber600,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Poll',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tạo và quản lý các cuộc thăm dò ý kiến cho sự kiện',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.coolGray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceLG),
          const Divider(),
          const SizedBox(height: AppSpacing.spaceLG),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreatePollBottomSheet(context),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(
                'Tạo Poll mới',
                style: AppTextStyles.heading5.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vkuBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMD,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
