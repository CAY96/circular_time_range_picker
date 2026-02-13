import 'dart:math';
import 'package:flutter/material.dart';
import 'time_picker_style.dart';

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

    // 1. 배경 트랙
    final trackPaint = Paint()
      ..color = style.trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. 활성 범위 (Arc)
    // atan2는 [-π, π]를 반환하므로, 6시(π)를 넘으면 -π로 점프한다.
    // 두 각을 [0, 2π)로 정규화한 뒤 sweep를 구해야 호가 사라지는 버그가 없다.
    final double twoPi = 2 * pi;
    double norm(double a) {
      a = a % twoPi;
      if (a < 0) a += twoPi;
      return a;
    }
    final double startNorm = norm(startAngle);
    final double endNorm = norm(endAngle);
    double sweepAngle = (endNorm - startNorm + twoPi) % twoPi;
    if (sweepAngle == 0) sweepAngle = twoPi; // 동일 지점 = 전체 원

    // start ~ end 사이를 여러 조각의 Arc로 나눠
    // 각 조각마다 Color.lerp 를 적용해서 부드러운 그라디언트를 만든다.
    if (sweepAngle > 0) {
      // sweepAngle 크기에 따라 적당한 분할 개수 결정 (약 2~3도 단위)
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

    // 3. 핸들 (간단하게 원으로 표현, 위젯은 메인에서 Stack으로 처리 권장)
    _drawHandle(canvas, center, radius, startAngle);
    _drawHandle(canvas, center, radius, endAngle);
  }

  // 0.0 ~ 1.0 사이 t에 대해, style.rangeGradient 에 정의된 색들 사이를 보간
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

  void _drawHandle(Canvas canvas, Offset center, double radius, double angle) {
    final handleOffset = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    
    final paint = Paint()
      ..color = style.handlerColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(handleOffset, style.handlerRadius, paint);
    // 테두리 추가
    canvas.drawCircle(handleOffset, style.handlerRadius, Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant TimePickerPainter oldDelegate) => true;
}