import 'package:flutter/material.dart';

enum TickAlignment { center, outer, inner }

class TickStyle {
  final Color tickColor;
  final int tickCount;
  final double tickOffsetFromCenter;
  final double tickLength;
  final double tickWidth;
  final double majorTickLength;
  final int majorTickInterval;
  final TickAlignment tickAlignment;

  const TickStyle({
    this.tickColor = Colors.white24,
    this.tickCount = 24,
    this.tickOffsetFromCenter = 32.0,
    this.tickLength = 5.0,
    this.tickWidth = 2.0,
    this.majorTickLength = 10.0,
    this.majorTickInterval = 6,
    this.tickAlignment = TickAlignment.outer,
  });
}

class TimePickerStyle {
  final Color trackColor;
  final List<Color> rangeGradient;
  final double strokeWidth;
  final double handlerRadius;
  final Color handlerColor;
  final Widget? startHandlerWidget;
  final Widget? endHandlerWidget;
  final TickStyle? tickStyle;

  const TimePickerStyle({
    this.trackColor = Colors.white10,
    this.rangeGradient = const [Colors.indigoAccent, Colors.deepOrangeAccent],
    this.strokeWidth = 40.0,
    this.handlerRadius = 25.0,
    this.handlerColor = Colors.white,
    this.startHandlerWidget,
    this.endHandlerWidget,
    this.tickStyle,
  });
}