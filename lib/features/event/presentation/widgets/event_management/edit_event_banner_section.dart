import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/services/cloudinary_image_service.dart';
import 'package:flutter/material.dart';

class EditEventBannerSection extends StatelessWidget {
  const EditEventBannerSection({
    required this.bannerImage,
    required this.bannerUrl,
    required this.onPickImage,
    super.key,
  });

  final File? bannerImage;
  final String? bannerUrl;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.coolGray900.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (bannerImage != null)
              Image.file(
                bannerImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            else if (bannerUrl != null && bannerUrl!.isNotEmpty)
              Image.network(
                CloudinaryImageService.getBannerUrl(bannerUrl),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderBanner(),
              )
            else
              _buildPlaceholderBanner(),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: onPickImage,
                backgroundColor: AppColors.vkuBlue,
                child: const Icon(Icons.camera_alt, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_rounded, size: 48, color: AppColors.white),
            SizedBox(height: AppSpacing.spaceXS),
            Text('Thêm ảnh bìa', style: TextStyle(color: AppColors.white)),
          ],
        ),
      ),
    );
  }
}
