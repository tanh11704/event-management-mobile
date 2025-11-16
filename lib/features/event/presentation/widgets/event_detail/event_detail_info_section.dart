import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/utils/date_formatter.dart';
import 'package:event_management/features/event/data/models/event_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailInfoSection extends StatelessWidget {
  const EventDetailInfoSection({required this.eventDetail, super.key});

  final EventDetailResponse eventDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMD),
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
        children: [
          // Thời gian
          _InfoTile(
            icon: Icons.calendar_today_rounded,
            iconColor: AppColors.vkuBlue,
            title: 'Thời gian',
            subtitle: DateFormatter.formatTimeRange(
              eventDetail.startTime,
              eventDetail.endTime,
            ),
          ),
          // Địa điểm
          if (eventDetail.location != null && eventDetail.location!.isNotEmpty)
            _Divider(),
          if (eventDetail.location != null && eventDetail.location!.isNotEmpty)
            _InfoTile(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.green500,
              title: 'Địa điểm',
              subtitle: eventDetail.location!,
              onTap: () async {
                final query = Uri.encodeComponent(eventDetail.location!);
                final uri = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$query',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          // Người tổ chức
          if (eventDetail.manager.isNotEmpty) ...[
            _Divider(),
            _InfoTile(
              icon: Icons.person_rounded,
              iconColor: AppColors.amber400,
              title: 'Người tổ chức',
              subtitle: eventDetail.manager[0].userName,
            ),
          ],
          // Thư ký
          if (eventDetail.secretaries.isNotEmpty) ...[
            if (eventDetail.manager.isNotEmpty) _Divider(),
            _InfoTile(
              icon: Icons.people_rounded,
              iconColor: AppColors.blue400,
              title: 'Thư ký',
              subtitle: eventDetail.secretaries
                  .map((s) => s.userName)
                  .join(', '),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coolGray500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.coolGray500,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMD),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.border.withOpacity(0.5),
      ),
    );
  }
}
