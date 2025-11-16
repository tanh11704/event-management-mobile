import 'package:event_management/core/config/app_colors.dart';
import 'package:flutter/material.dart';

class EventDetailBanner extends StatelessWidget {
  const EventDetailBanner({required this.bannerUrl, super.key});

  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: bannerUrl != null && bannerUrl!.isNotEmpty
          ? Image.network(
              bannerUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const _PlaceholderBanner();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                );
              },
            )
          : const _PlaceholderBanner(),
    );
  }
}

class _PlaceholderBanner extends StatelessWidget {
  const _PlaceholderBanner();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.coolGray500,
      child: Center(child: Icon(Icons.event, size: 80, color: AppColors.white)),
    );
  }
}
