import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_picker_field.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_section_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEventDateTimeSection extends StatelessWidget {
  const EditEventDateTimeSection({
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelected,
    required this.onStartTimeSelected,
    required this.onEndDateSelected,
    required this.onEndTimeSelected,
    super.key,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartDateSelected;
  final VoidCallback onStartTimeSelected;
  final VoidCallback onEndDateSelected;
  final VoidCallback onEndTimeSelected;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'vi');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'vi');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditEventSectionHeader(title: 'Thời gian & Địa điểm'),
        Row(
          children: [
            Expanded(
              child: EditEventPickerField(
                label: 'Ngày bắt đầu',
                text: _dateFormat.format(startDate),
                icon: Icons.calendar_today_rounded,
                onTap: onStartDateSelected,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: EditEventPickerField(
                label: 'Giờ bắt đầu',
                text: _timeFormat.format(startDate),
                icon: Icons.access_time_rounded,
                onTap: onStartTimeSelected,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceMD),
        Row(
          children: [
            Expanded(
              child: EditEventPickerField(
                label: 'Ngày kết thúc',
                text: _dateFormat.format(endDate),
                icon: Icons.calendar_today_rounded,
                onTap: onEndDateSelected,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: EditEventPickerField(
                label: 'Giờ kết thúc',
                text: _timeFormat.format(endDate),
                icon: Icons.access_time_rounded,
                onTap: onEndTimeSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
