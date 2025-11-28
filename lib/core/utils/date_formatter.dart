import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Format timestamp (DateTime) sang định dạng: "Thứ Năm, 27/02/2025 - 10:30"
  static String formatEventDateTime(DateTime dateTime) {
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy - HH:mm', 'vi');
    return dateFormat.format(dateTime);
  }

  /// Format chỉ ngày: "27/02/2025"
  static String formatDate(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy', 'vi');
    return dateFormat.format(dateTime);
  }

  /// Format chỉ giờ: "10:30"
  static String formatTime(DateTime dateTime) {
    final dateFormat = DateFormat('HH:mm', 'vi');
    return dateFormat.format(dateTime);
  }

  /// Format khoảng thời gian cho sự kiện.
  ///
  /// - Nếu cùng 1 ngày: "10:30 - 16:00, 27/02/2025"
  /// - Nếu khác ngày: "10:30 27/02/2025 → 16:00 28/02/2025"
  static String formatTimeRange(DateTime startTime, DateTime endTime) {
    final timeFormat = DateFormat('HH:mm', 'vi');
    final dateFormat = DateFormat('dd/MM/yyyy', 'vi');

    final sameDay =
        startTime.year == endTime.year &&
        startTime.month == endTime.month &&
        startTime.day == endTime.day;

    if (sameDay) {
      final startTimeStr = timeFormat.format(startTime);
      final endTimeStr = timeFormat.format(endTime);
      final dateStr = dateFormat.format(startTime);
      return '$startTimeStr - $endTimeStr, $dateStr';
    } else {
      final startStr =
          '${timeFormat.format(startTime)} ${dateFormat.format(startTime)}';
      final endStr =
          '${timeFormat.format(endTime)} ${dateFormat.format(endTime)}';
      return '$startStr → $endStr';
    }
  }
}
