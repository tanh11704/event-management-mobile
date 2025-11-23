import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/presentation/widgets/event_management/edit_event_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget để chọn ngày và giờ cho edit event
class EditEventDateTimePicker extends StatelessWidget {
  EditEventDateTimePicker({
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onStartTimeChanged,
    required this.onEndDateChanged,
    required this.onEndTimeChanged,
    super.key,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartDateChanged;
  final VoidCallback onStartTimeChanged;
  final VoidCallback onEndDateChanged;
  final VoidCallback onEndTimeChanged;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'vi');
  final DateFormat _timeFormat = DateFormat('HH:mm', 'vi');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: EditEventPickerField(
                label: 'Ngày bắt đầu',
                text: _dateFormat.format(startDate),
                icon: Icons.calendar_today_rounded,
                onTap: onStartDateChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: EditEventPickerField(
                label: 'Giờ bắt đầu',
                text: _timeFormat.format(startDate),
                icon: Icons.access_time_rounded,
                onTap: onStartTimeChanged,
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
                onTap: onEndDateChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceMD),
            Expanded(
              child: EditEventPickerField(
                label: 'Giờ kết thúc',
                text: _timeFormat.format(endDate),
                icon: Icons.access_time_rounded,
                onTap: onEndTimeChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
