import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/event_management/presentation/widgets/event_management/edit_event_modern_text_field.dart';
import 'package:flutter/material.dart';

/// Widget chứa các form fields cơ bản cho edit event
class EditEventFormFields extends StatelessWidget {
  const EditEventFormFields({
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.maxParticipantsController,
    required this.urlDocsController,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onLocationChanged,
    this.onMaxParticipantsChanged,
    this.onUrlDocsChanged,
    super.key,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController maxParticipantsController;
  final TextEditingController urlDocsController;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onDescriptionChanged;
  final ValueChanged<String>? onLocationChanged;
  final ValueChanged<String>? onMaxParticipantsChanged;
  final ValueChanged<String>? onUrlDocsChanged;

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
        TextFormField(
          controller: descriptionController,
          onChanged: onDescriptionChanged,
          decoration: const InputDecoration(
            labelText: 'Mô tả sự kiện',
            prefixIcon: Icon(Icons.description),
            hintText: 'Nhập mô tả chi tiết về sự kiện',
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
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
