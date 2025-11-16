import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EventDetailDescription extends StatelessWidget {
  const EventDetailDescription({required this.description, super.key});

  final String description;

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.vkuBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: AppColors.vkuBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceMD),
              Text('Mô tả', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceMD),
          Html(
            data: description,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.6),
                color: AppColors.coolGray900,
              ),
              'p': Style(margin: Margins.only(bottom: 12)),
              'h1': Style(
                fontSize: FontSize(24),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 12),
              ),
              'h2': Style(
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 10),
              ),
              'h3': Style(
                fontSize: FontSize(18),
                fontWeight: FontWeight.w600,
                margin: Margins.only(bottom: 8),
              ),
              'img': Style(
                width: Width(MediaQuery.of(context).size.width - 64),
                margin: Margins.symmetric(vertical: 12),
                alignment: Alignment.center,
              ),
              'a': Style(
                color: AppColors.vkuBlue,
                textDecoration: TextDecoration.underline,
              ),
            },
          ),
        ],
      ),
    );
  }
}
