import 'dart:math';
import 'package:flutter/material.dart';
import 'time_picker_style.dart';

/// Paints the circular time range: background track, gradient arc, and start/end handles.
class TimePickerPainter extends CustomPainter {
  final double startAngle;
  final double endAngle;
  final TimePickerStyle style;

  TimePickerPainter({
    required this.startAngle,
    required this.endAngle,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - (style.strokeWidth / 2);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = style.trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw ticks if enabled
    if (style.tickStyle != null) {
      _drawTicks(canvas, center, radius, style.tickStyle!);
    }

    // Normalize to [0, 2π) so sweep is correct (atan2 returns [-π, π], which can make the arc disappear).
    final double twoPi = 2 * pi;
    double norm(double a) {
      a = a % twoPi;
      if (a < 0) a += twoPi;
      return a;
    }
    final double startNorm = norm(startAngle);
    final double endNorm = norm(endAngle);
    double sweepAngle = (endNorm - startNorm + twoPi) % twoPi;
    if (sweepAngle == 0) sweepAngle = twoPi;

    if (sweepAngle > 0) {
      final segmentCount = max(12, (sweepAngle * 180 / pi / 3).round());
      for (int i = 0; i < segmentCount; i++) {
        final t0 = i / segmentCount;
        final t1 = (i + 1) / segmentCount;
        final tMid = (t0 + t1) / 2;

        final color = _evaluateGradientColor(tMid);
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = style.strokeWidth;

        final segmentStart = startNorm + sweepAngle * t0;
        final segmentSweep = sweepAngle * (t1 - t0);

        canvas.drawArc(
          arcRect,
          segmentStart,
          segmentSweep,
          false,
          paint,
        );
      }
    }

    _drawHandle(canvas, center, radius, startAngle);
    _drawHandle(canvas, center, radius, endAngle);
  }

  /// Interpolates [style.rangeGradient] colors for t in [0, 1].
  Color _evaluateGradientColor(double t) {
    final colors = style.rangeGradient;
    if (colors.isEmpty) return Colors.transparent;
    if (colors.length == 1) return colors.first;

    t = t.clamp(0.0, 1.0);
    final segmentCount = colors.length - 1;
    final scaled = t * segmentCount;
    final index = scaled.floor().clamp(0, segmentCount - 1);
    final localT = scaled - index;

    final Color a = colors[index];
    final Color b = colors[index + 1];
    return Color.lerp(a, b, localT)!;
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, TickStyle tickStyle) {
    final tickRadius = radius - tickStyle.tickOffsetFromCenter;
    final tickPaint = Paint()
      ..color = tickStyle.tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = tickStyle.tickWidth;

    final angleStep = 2 * pi / tickStyle.tickCount;
    for (int i = 0; i < tickStyle.tickCount; i++) {
      final angle = i * angleStep;
      final currentTickLength = (i % tickStyle.majorTickInterval == 0) ? tickStyle.majorTickLength : tickStyle.tickLength;

      double innerRadius, outerRadius;
      switch (tickStyle.tickAlignment) {
        case TickAlignment.center:
          innerRadius = tickRadius - currentTickLength / 2;
          outerRadius = tickRadius + currentTickLength / 2;
          break;
        case TickAlignment.outer:
          outerRadius = tickRadius;
          innerRadius = tickRadius - currentTickLength;
          break;
        case TickAlignment.inner:
          innerRadius = tickRadius;
          outerRadius = tickRadius + currentTickLength;
          break;
      }

      final startOffset = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final endOffset = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      canvas.drawLine(startOffset, endOffset, tickPaint);
    }
  }

  void _drawHandle(Canvas canvas, Offset center, double radius, double angle) {
    final handleOffset = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    
    // Draw shadow for elevation effect
    final shadowOffset = Offset(0, 1);
    final shadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(handleOffset + shadowOffset, style.handlerRadius, shadowPaint);
    
    // Draw handle
    final paint = Paint()
      ..color = style.handlerColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(handleOffset, style.handlerRadius, paint);
  }

  @override
  bool shouldRepaint(covariant TimePickerPainter oldDelegate) => true;
}