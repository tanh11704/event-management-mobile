import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_modern_text_field.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:flutter/material.dart';

class EditEventLocationSection extends StatelessWidget {
  const EditEventLocationSection({
    required this.locationController,
    required this.maxParticipantsController,
    required this.urlDocsController,
    super.key,
  });

  final TextEditingController locationController;
  final TextEditingController maxParticipantsController;
  final TextEditingController urlDocsController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.spaceMD),
        EditEventModernTextField(
          controller: locationController,
          label: 'Địa điểm',
          icon: Icons.location_on_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập địa điểm';
            }
            return null;
          },
        ),
        const EditEventSectionHeader(title: 'Tùy chọn bổ sung'),
        EditEventModernTextField(
          controller: maxParticipantsController,
          label: 'Số lượng tối đa',
          icon: Icons.people_rounded,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số lượng';
            }
            final num = int.tryParse(value);
            if (num == null || num <= 0) {
              return 'Số lượng phải lớn hơn 0';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        EditEventModernTextField(
          controller: urlDocsController,
          label: 'Link tài liệu (tùy chọn)',
          icon: Icons.link_rounded,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}
