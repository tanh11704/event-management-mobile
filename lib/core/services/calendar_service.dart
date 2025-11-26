import 'dart:async';

import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:event_management/features/event/shared/data/models/event_detail_response.dart';
import 'package:flutter/foundation.dart';

class CalendarService {
  CalendarService._();

  static Future<bool> addEventDetailToCalendar(
    EventDetailResponse eventDetail,
  ) async {
    try {
      final calendarEvent = add2cal.Event(
        title: eventDetail.title,
        description: eventDetail.description ?? '',
        location: eventDetail.location ?? '',
        startDate: eventDetail.startTime,
        endDate: eventDetail.endTime,
        iosParams: const add2cal.IOSParams(reminder: Duration(hours: 1)),
        androidParams: const add2cal.AndroidParams(emailInvites: []),
      );

      if (kDebugMode) {
        print('CalendarService: Đang mở dialog "Thêm vào lịch" ...');
      }

      await add2cal.Add2Calendar.addEvent2Cal(
        calendarEvent,
      ).timeout(const Duration(seconds: 5));

      if (kDebugMode) {
        print('CalendarService: Dialog đã được gọi mà không có lỗi.');
      }
      return true;
    } catch (e) {
      if (e is TimeoutException) {
        if (kDebugMode) {
          print('CalendarService: Plugin bị timeout, giả định là thành công.');
        }
        return true;
      }

      if (kDebugMode) {
        print('CalendarService: Lỗi khi thêm vào lịch. $e');
      }
      return false;
    }
  }
}
