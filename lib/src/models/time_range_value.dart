import 'package:flutter/material.dart';

/// Represents a range of time with a start and end [TimeOfDay].
class TimeRangeValue {
  /// The beginning of the time range.
  final TimeOfDay start;

  /// The end of the time range.
  final TimeOfDay end;

  const TimeRangeValue({required this.start, required this.end});

  /// Returns the total duration between [start] and [end].
  /// 
  /// This getter accounts for ranges that cross midnight (e.g., 11 PM to 1 AM).
  Duration get duration {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    int totalMinutes = endMinutes - startMinutes;
    if (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }
    
    return Duration(minutes: totalMinutes);
  }
}
