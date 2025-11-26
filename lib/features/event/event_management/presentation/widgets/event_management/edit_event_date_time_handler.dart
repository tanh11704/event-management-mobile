import 'package:event_management/core/config/app_colors.dart';
import 'package:flutter/material.dart';

/// Helper class để xử lý date/time picking logic
class EditEventDateTimeHandler {
  EditEventDateTimeHandler._();

  /// Chọn ngày bắt đầu
  static Future<DateTime?> selectStartDate({
    required BuildContext context,
    required DateTime initialDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    return picked;
  }

  /// Chọn giờ bắt đầu
  static Future<TimeOfDay?> selectStartTime({
    required BuildContext context,
    required DateTime initialDate,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.vkuBlue),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  /// Chọn ngày kết thúc
  static Future<DateTime?> selectEndDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime startDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('vi', 'VN'),
    );
    return picked;
  }

  /// Chọn giờ kết thúc
  static Future<TimeOfDay?> selectEndTime({
    required BuildContext context,
    required DateTime initialDate,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.vkuBlue),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }
}
