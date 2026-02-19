import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circular_time_range_picker/src/utils/math_helper.dart';
import 'package:circular_time_range_picker/src/core/snap_strategy.dart';

void main() {
  group('MathHelper - Time and Angle Conversion Tests', () {
    test('Midnight (00:00) should result in -π/2 radians', () {
      const time = TimeOfDay(hour: 0, minute: 0);
      final angle = MathHelper.timeToAngle(time);
      expect(angle, closeTo(-pi / 2, 0.01));
    });

    test('06:00 should result in 0 radians', () {
      const time = TimeOfDay(hour: 6, minute: 0);
      final angle = MathHelper.timeToAngle(time);
      expect(angle, closeTo(0, 0.01));
    });

    test('Converting angle 0 should result in 06:00', () {
      final time = MathHelper.angleToTime(0, minuteInterval: 1, snapStrategy: SnapStrategy.none);
      expect(time.hour, 6);
      expect(time.minute, 0);
    });

    test('A full 24-hour rotation should return to the original time', () {
      const originalTime = TimeOfDay(hour: 22, minute: 30);
      final angle = MathHelper.timeToAngle(originalTime);
      final resultTime = MathHelper.angleToTime(angle, minuteInterval: 1, snapStrategy: SnapStrategy.none);
      
      expect(resultTime.hour, originalTime.hour);
      expect(resultTime.minute, originalTime.minute);
    });
  });
}