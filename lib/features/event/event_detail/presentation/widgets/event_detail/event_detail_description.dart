import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/utils/html_image_processor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EventDetailDescription extends StatefulWidget {
  const EventDetailDescription({required this.description, super.key});

  final String description;

  @override
  State<EventDetailDescription> createState() => _EventDetailDescriptionState();
}

class _EventDetailDescriptionState extends State<EventDetailDescription>
    with SingleTickerProviderStateMixin {
  static const double _collapsedHeight = 260;

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final processedHtml = HtmlImageProcessor.processHtmlImagesForView(
      widget.description,
    );

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
          // Nội dung mô tả với trạng thái Thu gọn / Mở rộng
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: _isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: _collapsedHeight),
              child: Stack(
                children: [
                  Html(
                    data: processedHtml,
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
                  if (!_isExpanded)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.white.withOpacity(0),
                                AppColors.white.withOpacity(0.9),
                                AppColors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXM),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 18,
              ),
              label: Text(
                _isExpanded ? 'Thu gọn' : 'Xem thêm',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.vkuBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceXS,
                  vertical: AppSpacing.spaceXS,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
