import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/features/event/shared/data/models/event_counters.dart';
import 'package:event_management/features/event/shared/data/models/event_status.dart';
import 'package:event_management/features/event/event_list/presentation/widgets/event_filter_chip.dart';
import 'package:flutter/material.dart';

class EventListFilterChips extends StatelessWidget {
  const EventListFilterChips({
    required this.counters,
    required this.selectedStatus,
    required this.onStatusChanged,
    super.key,
  });

  final EventCounters counters;
  final EventStatus? selectedStatus;
  final ValueChanged<EventStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceMD,
        0,
        AppSpacing.spaceMD,
        AppSpacing.spaceMD,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            EventFilterChip(
              label: 'Đang diễn ra',
              count: counters.ongoing,
              isSelected: selectedStatus == EventStatus.ongoing,
              onTap: () => onStatusChanged(EventStatus.ongoing),
              color: AppColors.green500,
            ),
            const SizedBox(width: AppSpacing.spaceXM),
            EventFilterChip(
              label: 'Sắp diễn ra',
              count: counters.upcoming,
              isSelected: selectedStatus == EventStatus.upcoming,
              onTap: () => onStatusChanged(EventStatus.upcoming),
              color: AppColors.vkuBlue,
            ),
            const SizedBox(width: AppSpacing.spaceXM),
            EventFilterChip(
              label: 'Đã kết thúc',
              count: counters.completed,
              isSelected: selectedStatus == EventStatus.completed,
              onTap: () => onStatusChanged(EventStatus.completed),
              color: AppColors.coolGray700,
            ),
            const SizedBox(width: AppSpacing.spaceXM),
            EventFilterChip(
              label: 'Đã hủy',
              count: counters.cancelled,
              isSelected: selectedStatus == EventStatus.cancelled,
              onTap: () => onStatusChanged(EventStatus.cancelled),
              color: AppColors.red500,
            ),
          ],
        ),
      ),
    );
  }
}
