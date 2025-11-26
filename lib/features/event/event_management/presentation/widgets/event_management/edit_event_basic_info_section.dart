import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_html_editor.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_modern_text_field.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:flutter/material.dart';

class EditEventBasicInfoSection extends StatelessWidget {
  const EditEventBasicInfoSection({
    required this.titleController,
    required this.descriptionHtml,
    required this.htmlEditorKey,
    required this.onDescriptionChanged,
    super.key,
  });

  final TextEditingController titleController;
  final String descriptionHtml;
  final GlobalKey htmlEditorKey;
  final ValueChanged<String> onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditEventSectionHeader(title: 'Thông tin cơ bản'),
        EditEventModernTextField(
          controller: titleController,
          label: 'Tên sự kiện',
          icon: Icons.event_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên sự kiện';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        const EditEventSectionHeader(title: 'Mô tả'),
        EditEventHtmlEditor(
          key: htmlEditorKey,
          initialValue: descriptionHtml,
          onChanged: onDescriptionChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả';
            }
            return null;
          },
        ),
      ],
    );
  }
}
