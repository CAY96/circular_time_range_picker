import 'package:flutter/material.dart';

class TimePickerStyle {
  final Color trackColor;
  final List<Color> rangeGradient;
  final double strokeWidth;
  final double handlerRadius;
  final Color handlerColor;
  final Widget? startHandlerWidget; // 커스텀 아이콘용
  final Widget? endHandlerWidget;

  const TimePickerStyle({
    this.trackColor = Colors.white10,
    this.rangeGradient = const [Colors.indigoAccent, Colors.deepOrangeAccent],
    this.strokeWidth = 30.0,
    this.handlerRadius = 18.0,
    this.handlerColor = Colors.white,
    this.startHandlerWidget,
    this.endHandlerWidget,
  });
}