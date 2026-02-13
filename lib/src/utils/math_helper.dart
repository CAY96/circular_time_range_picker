import 'dart:math';
import 'package:flutter/material.dart';

import '../core/snap_strategy.dart';

/// 각도 <-> 시간 변환과 관련된 유틸리티.
///
/// - 0시는 -pi/2 (12시 방향)
/// - 6시는 0 (3시 방향)
/// - 24시간 = 2π 라디안
///
/// `angleToTime` 에서는 minuteInterval / snapStrategy 로 분 단위 스냅을 지원한다.

class MathHelper {
  static double timeToAngle(TimeOfDay time) {
    return ((time.hour % 24) * 60 + time.minute) / 1440 * (2 * pi) - (pi / 2);
  }

  /// 각도를 시간으로 변환한다.
  ///
  /// [minuteInterval]:
  ///   - 분 단위를 몇 분 단위로 스냅할지 (기본 10분)
  ///   - 1 이상 아무 값이나 허용하지만, 60의 약수(1, 5, 10, 12, 15, 20, 30, 60)를 사용하는 것을 권장한다.
  ///
  /// [snapStrategy]:
  ///   - round: 가장 가까운 interval 로 반올림 (기본값)
  ///   - floor: 항상 아래 interval 로 내림
  ///   - ceil : 항상 위 interval 로 올림
  ///   - none : 스냅하지 않고 그대로 사용 (이 경우 [minuteInterval] 값은 무시된다)
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