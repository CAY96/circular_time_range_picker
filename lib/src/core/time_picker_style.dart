import 'package:flutter/material.dart';

enum TickAlignment { center, outer, inner }

class TickStyle {
  // Common settings
  final int tickCount;
  final double tickOffsetFromCenter;
  final TickAlignment tickAlignment;

  // Regular tick settings
  final Color tickColor;
  final double tickLength;
  final double tickWidth;

  // Major tick settings
  final bool enableMajorTicks;
  final int majorTickInterval;
  final Color? majorTickColor;
  final double majorTickLength;
  final double majorTickWidth;

  const TickStyle({
    this.tickCount = 24,
    this.tickOffsetFromCenter = 0.0,
    this.tickAlignment = TickAlignment.center,
    this.tickColor = Colors.white24,
    this.tickLength = 5.0,
    this.tickWidth = 2.0,
    this.enableMajorTicks = true,
    this.majorTickInterval = 6,
    this.majorTickColor = Colors.white60,
    this.majorTickLength = 12.0,
    this.majorTickWidth = 2.5,
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