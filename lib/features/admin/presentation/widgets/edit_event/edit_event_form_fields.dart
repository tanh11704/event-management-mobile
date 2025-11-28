import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_html_editor.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_modern_text_field.dart';
import 'package:flutter/material.dart';

/// Widget chứa các form fields cơ bản cho edit event
class EditEventFormFields extends StatelessWidget {
  const EditEventFormFields({
    required this.titleController,
    required this.descriptionHtml,
    required this.htmlEditorKey,
    required this.locationController,
    required this.maxParticipantsController,
    required this.urlDocsController,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onLocationChanged,
    this.onMaxParticipantsChanged,
    this.onUrlDocsChanged,
    this.onAiGenerate,
    this.isGeneratingDescription = false,
    super.key,
  });

  final TextEditingController titleController;
  final String descriptionHtml;
  final GlobalKey htmlEditorKey;
  final TextEditingController locationController;
  final TextEditingController maxParticipantsController;
  final TextEditingController urlDocsController;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onDescriptionChanged;
  final ValueChanged<String>? onLocationChanged;
  final ValueChanged<String>? onMaxParticipantsChanged;
  final ValueChanged<String>? onUrlDocsChanged;
  final VoidCallback? onAiGenerate;
  final bool isGeneratingDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditEventModernTextField(
          controller: titleController,
          label: 'Tên sự kiện',
          icon: Icons.event_rounded,
          onChanged: onTitleChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên sự kiện';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        // Mô tả với AI generator
        Row(
          children: [
            Expanded(
              child: Text(
                'Mô tả sự kiện',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.coolGray700,
                ),
              ),
            ),
            if (onAiGenerate != null)
              OutlinedButton.icon(
                onPressed:
                    (isGeneratingDescription ||
                        titleController.text.trim().isEmpty)
                    ? null
                    : onAiGenerate,
                icon: isGeneratingDescription
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.vkuBlue,
                          ),
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(
                  isGeneratingDescription ? 'Đang tạo...' : 'Tạo với AI',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vkuBlue,
                  side: const BorderSide(color: AppColors.vkuBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceMD,
                    vertical: AppSpacing.spaceXS,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceXS),
        EditEventHtmlEditor(
          key: htmlEditorKey,
          initialValue: descriptionHtml,
          onChanged: onDescriptionChanged ?? (_) {},
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả sự kiện';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        EditEventModernTextField(
          controller: locationController,
          label: 'Địa điểm',
          icon: Icons.location_on_rounded,
          onChanged: onLocationChanged,
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        EditEventModernTextField(
          controller: maxParticipantsController,
          label: 'Số lượng tối đa',
          icon: Icons.people_rounded,
          keyboardType: TextInputType.number,
          onChanged: onMaxParticipantsChanged,
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        EditEventModernTextField(
          controller: urlDocsController,
          label: 'Link tài liệu (tùy chọn)',
          icon: Icons.link_rounded,
          keyboardType: TextInputType.url,
          onChanged: onUrlDocsChanged,
        ),
      ],
    );
  }
}
