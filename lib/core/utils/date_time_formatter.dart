import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

  static String formatDateTimeWithTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
