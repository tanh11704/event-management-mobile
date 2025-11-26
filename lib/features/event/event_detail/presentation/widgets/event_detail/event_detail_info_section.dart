import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/services/calendar_service.dart';
import 'package:event_management/core/utils/date_formatter.dart';
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
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
          // Nút thêm vào lịch
          _Divider(),
          _AddToCalendarTile(eventDetail: eventDetail),
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

class _AddToCalendarTile extends StatefulWidget {
  const _AddToCalendarTile({required this.eventDetail});

  final EventDetailResponse eventDetail;

  @override
  State<_AddToCalendarTile> createState() => _AddToCalendarTileState();
}

class _AddToCalendarTileState extends State<_AddToCalendarTile> {
  bool _isLoading = false;

  Future<void> _addToCalendar() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await CalendarService.addEventDetailToCalendar(widget.eventDetail);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.white),
                SizedBox(width: AppSpacing.spaceXM),
                Expanded(
                  child: Text('Đã thêm sự kiện vào lịch thành công'),
                ),
              ],
            ),
            backgroundColor: AppColors.green500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.white),
                SizedBox(width: AppSpacing.spaceXM),
                Expanded(
                  child: Text(
                    'Không thể thêm sự kiện vào lịch. Vui lòng cấp quyền truy cập Lịch.',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.white),
              SizedBox(width: AppSpacing.spaceXM),
              Expanded(
                child: Text('Đã xảy ra lỗi. Vui lòng thử lại.'),
              ),
            ],
          ),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _addToCalendar,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spaceMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.vkuBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.vkuBlue),
                        ),
                      )
                    : const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.vkuBlue,
                        size: 24,
                      ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thêm vào lịch',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.coolGray500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoading
                          ? 'Đang thêm...'
                          : 'Thêm sự kiện vào ứng dụng Lịch',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
