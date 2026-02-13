import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circular_time_range_picker/src/utils/math_helper.dart';
import 'package:circular_time_range_picker/src/core/snap_strategy.dart';

void main() {
  group('MathHelper - 시간과 각도 변환 테스트', () {
    test('12시(00:00)는 -pi/2 각도여야 한다', () {
      const time = TimeOfDay(hour: 0, minute: 0);
      final angle = MathHelper.timeToAngle(time);
      expect(angle, closeTo(-pi / 2, 0.01));
    });

    test('6시(06:00)는 0 각도여야 한다', () {
      const time = TimeOfDay(hour: 6, minute: 0);
      final angle = MathHelper.timeToAngle(time);
      expect(angle, closeTo(0, 0.01));
    });

    test('각도 0을 시간으로 변환하면 06:00이어야 한다', () {
      final time = MathHelper.angleToTime(0, minuteInterval: 1, snapStrategy: SnapStrategy.none);
      expect(time.hour, 6);
      expect(time.minute, 0);
    });

    test('24시간 한 바퀴를 돌면 원래 시간으로 돌아와야 한다', () {
      const originalTime = TimeOfDay(hour: 22, minute: 30);
      final angle = MathHelper.timeToAngle(originalTime);
      final resultTime = MathHelper.angleToTime(angle, minuteInterval: 1, snapStrategy: SnapStrategy.none);
      
      expect(resultTime.hour, originalTime.hour);
      expect(resultTime.minute, originalTime.minute);
    });
  });
}