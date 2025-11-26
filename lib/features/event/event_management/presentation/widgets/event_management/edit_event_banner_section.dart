import 'dart:io';

import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/services/cloudinary_image_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditEventBannerSection extends StatelessWidget {
  const EditEventBannerSection({
    required this.bannerImage,
    required this.bannerImageFile,
    required this.bannerUrl,
    required this.onPickImage,
    super.key,
  });

  final File? bannerImage;
  final XFile? bannerImageFile;
  final String? bannerUrl;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final hasImage = bannerImageFile != null || bannerImage != null;
    final hasUrl =
        bannerUrl != null &&
        bannerUrl!.isNotEmpty &&
        bannerUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: onPickImage,
      borderRadius: BorderRadius.zero,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: !hasImage && !hasUrl
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.vkuBlue.withOpacity(0.05),
                    AppColors.coolGray50,
                  ],
                )
              : null,
          borderRadius: BorderRadius.zero,
          border: !hasImage && !hasUrl
              ? const Border(bottom: BorderSide(color: AppColors.border))
              : null,
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    child: kIsWeb
                        ? Image.network(
                            bannerImageFile!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderContent(),
                          )
                        : Image.file(
                            bannerImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderContent(),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            : hasUrl
            ? Stack(
                children: [
                  ClipRRect(
                    child: Image.network(
                      CloudinaryImageService.getBannerUrl(bannerUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const ColoredBox(
                          color: AppColors.coolGray50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderContent();
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            : _buildPlaceholderContent(),
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.vkuBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppColors.vkuBlue,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tải lên ảnh Banner',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.coolGray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Nhấn để chọn ảnh từ thư viện',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray500),
        ),
      ],
    );
  }
}
