import 'package:flutter/material.dart';

class TimeRangeValue {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRangeValue({required this.start, required this.end});

  Duration get duration {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    int totalMinutes = endMinutes - startMinutes;
    if (totalMinutes < 0) {
      totalMinutes += 24 * 60; // 자정을 넘어가는 경우
    }
    
    return Duration(minutes: totalMinutes);
  }
}