import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/services/cloudinary_image_service.dart';
import 'package:event_management/features/event/data/models/event.dart';
import 'package:event_management/features/event/presentation/widgets/event_card/event_status_badge.dart';
import 'package:flutter/material.dart';

class EventCardBanner extends StatelessWidget {
  const EventCardBanner({required this.event, super.key});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Banner Image
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: event.banner != null && event.banner!.isNotEmpty
              ? Image.network(
                  CloudinaryImageService.getThumbnailUrl(event.banner),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder(),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.coolGray900.withOpacity(0),
                  AppColors.coolGray900.withOpacity(0.1),
                  AppColors.coolGray900.withOpacity(0.7),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),

        Positioned(
          top: AppSpacing.spaceMD,
          right: AppSpacing.spaceMD,
          child: EventStatusBadge(status: event.status),
        ),

        Positioned(
          bottom: AppSpacing.spaceMD,
          left: AppSpacing.spaceMD,
          right: AppSpacing.spaceMD,
          child: Text(
            event.title,
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.white, // Chữ trắng
              fontWeight: FontWeight.w700,
              height: 1.25,
              fontSize: 16, // Tăng font size
              // Thêm shadow cho chữ
              shadows: [
                BoxShadow(
                  color: AppColors.coolGray900.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Icon(
          Icons.calendar_today_rounded,
          size: 48,
          color: AppColors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}
