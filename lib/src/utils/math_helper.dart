import 'dart:math';
import 'package:flutter/material.dart';

import '../core/snap_strategy.dart';

/// Utilities for converting between angles and time.
///
/// - 00:00 (Midnight) = -π/2 (12 o'clock position)
/// - 06:00 = 0 (3 o'clock position)
/// - 24 hours = 2π radians
///
/// `angleToTime` supports minute-based snapping via [minuteInterval] and [SnapStrategy].
class MathHelper {
  static double timeToAngle(TimeOfDay time) {
    return ((time.hour % 24) * 60 + time.minute) / 1440 * (2 * pi) - (pi / 2);
  }

  /// Converts a given [angle] into [TimeOfDay].
  static TimeOfDay angleToTime(
    double angle, {
    int minuteInterval = 10,
    SnapStrategy snapStrategy = SnapStrategy.round,
  }) {
    double normalizedAngle = (angle + pi / 2) % (2 * pi);
    if (normalizedAngle < 0) normalizedAngle += 2 * pi;

    int totalMinutes = ((normalizedAngle / (2 * pi)) * 1440).round();
    totalMinutes = totalMinutes % (24 * 60);

    if (snapStrategy != SnapStrategy.none && minuteInterval > 1) {
      final interval = minuteInterval;
      switch (snapStrategy) {
        case SnapStrategy.floor:
          totalMinutes = (totalMinutes ~/ interval) * interval;
          break;
        case SnapStrategy.ceil:
          totalMinutes = ((totalMinutes + interval - 1) ~/ interval) * interval;
          break;
        case SnapStrategy.round:
          totalMinutes = ((totalMinutes / interval).round()) * interval;
          break;
        case SnapStrategy.none:
          // already handled in if
          break;
      }
      totalMinutes = totalMinutes % (24 * 60);
    }

    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;

    return TimeOfDay(hour: hour, minute: minute);
  }
}