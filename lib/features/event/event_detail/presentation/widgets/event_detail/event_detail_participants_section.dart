import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/shared/data/models/participant.dart';
import 'package:flutter/material.dart';

class EventDetailParticipantsSection extends StatelessWidget {
  const EventDetailParticipantsSection({
    required this.participants,
    this.maxParticipants,
    super.key,
  });

  final List<ParticipantInfo> participants;
  final int? maxParticipants;

  @override
  Widget build(BuildContext context) {
    final participantCount = participants.length;
    final maxCount = maxParticipants ?? 0;
    final percentage = maxCount > 0
        ? (participantCount / maxCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMD),
      padding: const EdgeInsets.all(AppSpacing.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray500.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amber400.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: AppColors.amber600,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Text('Người tham gia', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$participantCount${maxCount > 0 ? ' / $maxCount' : ''} người',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (maxCount > 0)
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.coolGray500,
                  ),
                ),
            ],
          ),
          if (maxCount > 0) ...[
            const SizedBox(height: AppSpacing.spaceXM),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: AppColors.coolGray50,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage >= 0.9
                      ? AppColors.red500
                      : percentage >= 0.7
                      ? AppColors.amber400
                      : AppColors.green500,
                ),
              ),
            ),
          ],
          if (participants.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spaceMD),
            Row(
              children: [
                _AvatarStack(participants: participants.take(5).toList()),
                const SizedBox(width: AppSpacing.spaceMD),
                if (participants.length > 5)
                  Expanded(
                    child: Text(
                      '+${participants.length - 5} người khác',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.coolGray500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.participants});

  final List<ParticipantInfo> participants;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (participants.length * 28.0) + 12,
      height: 44,
      child: Stack(
        children: List.generate(
          participants.length > 5 ? 5 : participants.length,
          (index) {
            final participant = participants[index];
            return Positioned(
              left: index * 28.0,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coolGray500.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _AvatarPlaceholder(name: participant.userName),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.heading5.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
