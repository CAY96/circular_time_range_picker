import 'dart:math';
import 'package:flutter/material.dart';
import 'core/time_picker_painter.dart';
import 'core/time_picker_style.dart';
import 'core/snap_strategy.dart';
import 'models/time_range_value.dart';
import 'utils/math_helper.dart';

enum _DragTarget { start, end, arc, none }

/// A circular widget used to select a time range.
/// 
/// The picker allows users to select a start and end time by dragging
/// handlers around a circular track. It supports snapping to intervals
/// and highly customizable styling.
class CircularTimeRangePicker extends StatefulWidget {
  /// The size of the picker widget.
  final Size size;
  
  /// The initial time range value of the picker.
  final TimeRangeValue initialValue;

  /// The style for the time picker UI, such as colors and handler appearance.
  final TimePickerStyle style;
  
  /// Called when the user finishes or is in the process of changing the time range.
  final Function(TimeRangeValue) onChanged;
  
  /// The interval in minutes to which the selection snaps.
  /// 
  /// For example, if set to 15, the handlers will snap to 0, 15, 30, and 45 minutes.
  /// 
  /// While any value ≥ 1 is accepted, using divisors of 60 
  /// (1, 5, 10, 12, 15, 20, 30, 60) is recommended.
  final int minuteInterval;
  
  /// Strategy for snapping minutes to a fixed interval.
  /// Used together with [minuteInterval] to decide how a dragged time value 
  /// should be snapped.
  /// 
  ///   - round: Rounds to the nearest interval (default).
  ///   - floor: Always rounds down to the previous interval.
  ///   - ceil: Always rounds up to the next interval.
  ///   - none: Uses the raw value without snapping (ignores [minuteInterval]).
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
  _DragTarget _currentDragTarget = _DragTarget.none;
  double _arcDragStartAngle = 0.0;
  double _arcDragStartAngleStart = 0.0;
  double _arcDragStartAngleEnd = 0.0;

  @override
  void initState() {
    super.initState();
    _startAngle = MathHelper.timeToAngle(widget.initialValue.start);
    _endAngle = MathHelper.timeToAngle(widget.initialValue.end);
  }

  /// Hit-tests: handle proximity first, then arc; sets [_currentDragTarget] and arc-drag state.
  void _onPanStart(DragStartDetails details) {
    final center = Offset(widget.size.width / 2, widget.size.height / 2);
    final radius = widget.size.width / 2 - (widget.style.strokeWidth / 2);
    final position = details.localPosition;

    final startHandle = Offset(center.dx + radius * cos(_startAngle), center.dy + radius * sin(_startAngle));
    final endHandle = Offset(center.dx + radius * cos(_endAngle), center.dy + radius * sin(_endAngle));

    final handleTouchRadius = widget.style.handlerRadius + 10.0;
    final distToStartHandle = (position - startHandle).distance;
    final distToEndHandle = (position - endHandle).distance;

    if (distToStartHandle < handleTouchRadius || distToEndHandle < handleTouchRadius) {
      _currentDragTarget = distToStartHandle < distToEndHandle ? _DragTarget.start : _DragTarget.end;
    } else {
      final touchAngle = atan2(position.dy - center.dy, position.dx - center.dx);
      final distFromCenter = (position - center).distance;
      final arcRadius = radius;
      final arcThickness = widget.style.strokeWidth;

      if ((distFromCenter - arcRadius).abs() < arcThickness / 2 + 10.0) {
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

  /// Normalizes angle to [0, 2π).
  double _normalizeAngle(double angle) {
    angle = angle % (2 * pi);
    if (angle < 0) angle += 2 * pi;
    return angle;
  }

  /// Returns whether the given angle lies on the arc between [startAngle] and [endAngle].
  bool _isAngleInArcRange(double angle, double startAngle, double endAngle) {
    final twoPi = 2 * pi;
    final startNorm = _normalizeAngle(startAngle);
    final endNorm = _normalizeAngle(endAngle);
    final angleNorm = _normalizeAngle(angle);

    double sweepAngle = (endNorm - startNorm + twoPi) % twoPi;
    if (sweepAngle == 0) sweepAngle = twoPi;

    if (sweepAngle >= twoPi) return true;

    if (startNorm + sweepAngle <= twoPi) {
      return angleNorm >= startNorm && angleNorm <= startNorm + sweepAngle;
    } else {
      return angleNorm >= startNorm || angleNorm <= (startNorm + sweepAngle - twoPi);
    }
  }

  /// Updates start/end angles from drag; snaps to [minuteInterval] and applies [snapStrategy].
  void _onPanUpdate(DragUpdateDetails details) {
    if (_currentDragTarget == _DragTarget.none) return;

    final center = Offset(widget.size.width / 2, widget.size.height / 2);
    final position = details.localPosition;
    final angle = atan2(position.dy - center.dy, position.dx - center.dx);

    setState(() {
      if (_currentDragTarget == _DragTarget.start) {
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
        final angleDelta = _normalizeAngle(angle - _arcDragStartAngle);
        final shortestDelta = angleDelta > pi ? angleDelta - 2 * pi : angleDelta;

        _startAngle = _normalizeAngle(_arcDragStartAngleStart + shortestDelta);
        _endAngle = _normalizeAngle(_arcDragStartAngleEnd + shortestDelta);

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
    _currentDragTarget = _DragTarget.none;
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

  /// Places the custom handler widget from [style] on the same ring radius used by [TimePickerPainter].
  Widget _buildHandlerWidget(Widget child, double angle) {
    final ringRadius =
        min(widget.size.width, widget.size.height) / 2 - (widget.style.strokeWidth / 2);

    final dx = ringRadius * cos(angle);
    final dy = ringRadius * sin(angle);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: child,
    );
  }
}