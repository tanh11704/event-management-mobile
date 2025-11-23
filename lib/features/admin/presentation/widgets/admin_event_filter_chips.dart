import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_spacing.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/features/event/data/models/event_counters.dart';
import 'package:event_management/features/event/data/models/event_status.dart';
import 'package:flutter/material.dart';

/// Filter chips widget dành riêng cho admin dashboard
class AdminEventFilterChips extends StatelessWidget {
  const AdminEventFilterChips({
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            count: _getTotalCount(),
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          const SizedBox(width: AppSpacing.spaceXS),
          _FilterChip(
            label: 'Sắp tới',
            count: counters.upcoming,
            isSelected: selectedStatus == EventStatus.upcoming,
            onTap: () => onStatusChanged(EventStatus.upcoming),
          ),
          const SizedBox(width: AppSpacing.spaceXS),
          _FilterChip(
            label: 'Đang diễn ra',
            count: counters.ongoing,
            isSelected: selectedStatus == EventStatus.ongoing,
            onTap: () => onStatusChanged(EventStatus.ongoing),
          ),
          const SizedBox(width: AppSpacing.spaceXS),
          _FilterChip(
            label: 'Đã kết thúc',
            count: counters.completed,
            isSelected: selectedStatus == EventStatus.completed,
            onTap: () => onStatusChanged(EventStatus.completed),
          ),
          const SizedBox(width: AppSpacing.spaceXS),
          _FilterChip(
            label: 'Đã hủy',
            count: counters.cancelled,
            isSelected: selectedStatus == EventStatus.cancelled,
            onTap: () => onStatusChanged(EventStatus.cancelled),
          ),
        ],
      ),
    );
  }

  int _getTotalCount() {
    return counters.upcoming +
        counters.ongoing +
        counters.completed +
        counters.cancelled;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceMD,
          vertical: AppSpacing.spaceXS + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vkuBlue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.vkuBlue
                : AppColors.coolGray500.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.coolGray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.white.withOpacity(0.2)
                    : AppColors.coolGray500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.white : AppColors.coolGray700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
