import 'dart:math';
import 'package:flutter/material.dart';
import 'core/time_picker_painter.dart';
import 'core/time_picker_style.dart';
import 'core/snap_strategy.dart';
import 'models/time_range_value.dart';
import 'utils/math_helper.dart';

enum _DragTarget { start, end, arc, none } // 드래그 대상 구분

class CircularTimeRangePicker extends StatefulWidget {
  final Size size;
  final TimeRangeValue initialValue;
  final TimePickerStyle style;
  final Function(TimeRangeValue) onChanged;
  final int minuteInterval;
  final SnapStrategy snapStrategy;

  const CircularTimeRangePicker({
    super.key,
    this.size = const Size(250, 250),
    required this.initialValue,
    this.style = const TimePickerStyle(),
    required this.onChanged,
    this.minuteInterval = 10,
    this.snapStrategy = SnapStrategy.round,
  });

  @override
  State<CircularTimeRangePicker> createState() => _CircularTimeRangePickerState();
}

class _CircularTimeRangePickerState extends State<CircularTimeRangePicker> {
  late double _startAngle;
  late double _endAngle;
  _DragTarget _currentDragTarget = _DragTarget.none; // 현재 잡고 있는 핸들
  double _arcDragStartAngle = 0.0; // arc 드래그 시작 시 터치한 각도
  double _arcDragStartAngleStart = 0.0; // arc 드래그 시작 시 startAngle
  double _arcDragStartAngleEnd = 0.0; // arc 드래그 시작 시 endAngle

  @override
  void initState() {
    super.initState();
    _startAngle = MathHelper.timeToAngle(widget.initialValue.start);
    _endAngle = MathHelper.timeToAngle(widget.initialValue.end);
  }

  void _onPanStart(DragStartDetails details) {
    final center = Offset(widget.size.width / 2, widget.size.height / 2);
    final radius = widget.size.width / 2 - (widget.style.strokeWidth / 2);
    final position = details.localPosition;

    final startHandle = Offset(center.dx + radius * cos(_startAngle), center.dy + radius * sin(_startAngle));
    final endHandle = Offset(center.dx + radius * cos(_endAngle), center.dy + radius * sin(_endAngle));

    // 핸들 근처인지 확인 (핸들 반경 + 여유 공간)
    final handleTouchRadius = widget.style.handlerRadius + 10.0;
    final distToStartHandle = (position - startHandle).distance;
    final distToEndHandle = (position - endHandle).distance;

    if (distToStartHandle < handleTouchRadius || distToEndHandle < handleTouchRadius) {
      // 핸들 근처면 핸들 드래그
      _currentDragTarget = distToStartHandle < distToEndHandle ? _DragTarget.start : _DragTarget.end;
    } else {
      // 핸들이 아니면 arc 위에 있는지 확인
      final touchAngle = atan2(position.dy - center.dy, position.dx - center.dx);
      final distFromCenter = (position - center).distance;
      final arcRadius = radius;
      final arcThickness = widget.style.strokeWidth;

      // 원의 중심에서 거리가 arc 반경 근처인지 확인
      if ((distFromCenter - arcRadius).abs() < arcThickness / 2 + 10.0) {
        // 각도가 startAngle ~ endAngle 사이에 있는지 확인 (sweepAngle 고려)
        if (_isAngleInArcRange(touchAngle, _startAngle, _endAngle)) {
          _currentDragTarget = _DragTarget.arc;
          _arcDragStartAngle = touchAngle;
          _arcDragStartAngleStart = _startAngle;
          _arcDragStartAngleEnd = _endAngle;
        } else {
          _currentDragTarget = _DragTarget.none;
        }
      } else {
        _currentDragTarget = _DragTarget.none;
      }
    }
  }

  // 각도를 [0, 2π)로 정규화
  double _normalizeAngle(double angle) {
    angle = angle % (2 * pi);
    if (angle < 0) angle += 2 * pi;
    return angle;
  }

  // 주어진 각도가 startAngle ~ endAngle 사이의 arc 위에 있는지 확인
  bool _isAngleInArcRange(double angle, double startAngle, double endAngle) {
    final twoPi = 2 * pi;
    final startNorm = _normalizeAngle(startAngle);
    final endNorm = _normalizeAngle(endAngle);
    final angleNorm = _normalizeAngle(angle);

    double sweepAngle = (endNorm - startNorm + twoPi) % twoPi;
    if (sweepAngle == 0) sweepAngle = twoPi; // 전체 원

    // angleNorm이 startNorm부터 sweepAngle 범위 안에 있는지 확인
    if (sweepAngle >= twoPi) return true; // 전체 원이면 항상 true

    // startNorm부터 sweepAngle 범위를 확인 (2π 경계 넘어가는 경우 고려)
    if (startNorm + sweepAngle <= twoPi) {
      return angleNorm >= startNorm && angleNorm <= startNorm + sweepAngle;
    } else {
      // 2π 경계를 넘어가는 경우
      return angleNorm >= startNorm || angleNorm <= (startNorm + sweepAngle - twoPi);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentDragTarget == _DragTarget.none) return;

    final center = Offset(widget.size.width / 2, widget.size.height / 2);
    final position = details.localPosition;
    final angle = atan2(position.dy - center.dy, position.dx - center.dx);

    setState(() {
      if (_currentDragTarget == _DragTarget.start) {
        // 각도를 시간으로 변환하면서 분 단위를 스냅한 뒤,
        // 다시 각도로 변환하여 핸들 위치도 스냅된 각도로 맞춘다.
        final snappedTime = MathHelper.angleToTime(
          angle,
          minuteInterval: widget.minuteInterval,
          snapStrategy: widget.snapStrategy,
        );
        _startAngle = MathHelper.timeToAngle(snappedTime);
      } else if (_currentDragTarget == _DragTarget.end) {
        final snappedTime = MathHelper.angleToTime(
          angle,
          minuteInterval: widget.minuteInterval,
          snapStrategy: widget.snapStrategy,
        );
        _endAngle = MathHelper.timeToAngle(snappedTime);
      } else if (_currentDragTarget == _DragTarget.arc) {
        // arc 드래그: 호의 길이(sweepAngle)를 유지한 채로 전체 이동
        // 현재 터치 각도와 드래그 시작 각도의 차이를 계산
        final angleDelta = _normalizeAngle(angle - _arcDragStartAngle);
        // 2π 경계를 넘어가는 경우를 고려하여 최단 경로로 각도 차이 계산
        final shortestDelta = angleDelta > pi ? angleDelta - 2 * pi : angleDelta;
        
        // startAngle과 endAngle을 동시에 동일한 양만큼 이동
        _startAngle = _normalizeAngle(_arcDragStartAngleStart + shortestDelta);
        _endAngle = _normalizeAngle(_arcDragStartAngleEnd + shortestDelta);

        // arc 전체를 움직인 뒤, 양 끝을 각각 스냅된 시각에 맞춰 재정렬
        final snappedStart = MathHelper.angleToTime(
          _startAngle,
          minuteInterval: widget.minuteInterval,
          snapStrategy: widget.snapStrategy,
        );
        final snappedEnd = MathHelper.angleToTime(
          _endAngle,
          minuteInterval: widget.minuteInterval,
          snapStrategy: widget.snapStrategy,
        );
        _startAngle = MathHelper.timeToAngle(snappedStart);
        _endAngle = MathHelper.timeToAngle(snappedEnd);
      }
    });

    widget.onChanged(TimeRangeValue(
      start: MathHelper.angleToTime(
        _startAngle,
        minuteInterval: widget.minuteInterval,
        snapStrategy: widget.snapStrategy,
      ),
      end: MathHelper.angleToTime(
        _endAngle,
        minuteInterval: widget.minuteInterval,
        snapStrategy: widget.snapStrategy,
      ),
    ));
  }

  void _onPanEnd(DragEndDetails details) {
    _currentDragTarget = _DragTarget.none; // 드래그 종료 시 초기화
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: widget.size,
              painter: TimePickerPainter(
                startAngle: _startAngle,
                endAngle: _endAngle,
                style: widget.style,
              ),
            ),
            if (widget.style.startHandlerWidget != null)
              _buildHandlerWidget(widget.style.startHandlerWidget!, _startAngle),
            if (widget.style.endHandlerWidget != null)
              _buildHandlerWidget(widget.style.endHandlerWidget!, _endAngle),
          ],
        ),
      ),
    );
  }

  /// 스타일에 지정된 커스텀 핸들러 위젯을
  /// TimePickerPainter 가 사용하는 핸들 중심 반경에 정확히 맞춰 배치한다.
  Widget _buildHandlerWidget(Widget child, double angle) {
    // TimePickerPainter 에서 arc/핸들을 그릴 때 사용하는 반지름과 동일한 식:
    // radius = min(width, height) / 2 - strokeWidth / 2
    final ringRadius =
        min(widget.size.width, widget.size.height) / 2 - (widget.style.strokeWidth / 2);

    final dx = ringRadius * cos(angle);
    final dy = ringRadius * sin(angle);

    // Stack 은 중앙(0,0)에 child를 놓고, 여기서부터 실제 폴라 좌표만큼 Translate 시킨다.
    // 이렇게 하면 Alignment 의 -1..1 제한 없이 위젯의 "정중앙"이 정확히 링 위에 온다.
    return Transform.translate(
      offset: Offset(dx, dy),
      child: child,
    );
  }
}