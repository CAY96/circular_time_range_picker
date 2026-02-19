## circular_time_range_picker

A highly customizable circular time **range** picker for Flutter.  
Designed for use cases like sleep tracking, focus sessions, schedules, etc., where users select a start and end time on a 24‑hour clock.

### Features

- **Circular 24h time range selection**
- **Gradient arc** between start and end
- **Configurable snapping** (minute interval + snapping strategy)
- **Drag handles + arc drag**
  - Drag start handle
  - Drag end handle
  - Drag the arc itself to move the whole range
- **Custom handler widgets**
- Simple `TimeRangeValue` model with a computed `duration`

---


## Basic usage

```dart
import 'package:flutter/material.dart';
import 'package:circular_time_range_picker/circular_time_range_picker.dart';

class SleepTrackerExample extends StatefulWidget {
  const SleepTrackerExample({super.key});

  @override
  State<SleepTrackerExample> createState() => _SleepTrackerExampleState();
}

class _SleepTrackerExampleState extends State<SleepTrackerExample> {
  TimeRangeValue _sleepTime = const TimeRangeValue(
    start: TimeOfDay(hour: 23, minute: 0),
    end: TimeOfDay(hour: 7, minute: 0),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularTimeRangePicker(
        initialValue: _sleepTime,
        size: const Size(280, 280),
        onChanged: (range) {
          setState(() => _sleepTime = range);
        },
      ),
    );
  }
}
```

---

## API overview

### `CircularTimeRangePicker`

```dart
CircularTimeRangePicker({
  Key? key,
  Size size = const Size(250, 250),
  required TimeRangeValue initialValue,
  TimePickerStyle style = const TimePickerStyle(),
  required void Function(TimeRangeValue) onChanged,

  // Snapping
  int minuteInterval = 10,
  SnapStrategy snapStrategy = SnapStrategy.round,
})
```

- **`initialValue`**: initial start/end `TimeOfDay`.
- **`onChanged`**: called whenever the user drags a handle or arc.
- **`minuteInterval`**:
  - “snap step” in minutes (e.g. `1`, `5`, `10`, `15`, `30`, `60`).
  - Any `int >= 1` is allowed, but **divisors of 60** (1, 5, 10, 12, 15, 20, 30, 60) are recommended.
- **`snapStrategy`** (`SnapStrategy`):
  - `SnapStrategy.round` – snap to the nearest interval (default)
  - `SnapStrategy.floor` – always snap down
  - `SnapStrategy.ceil` – always snap up
  - `SnapStrategy.none` – **no snapping** (in this case `minuteInterval` is ignored)

Internally, both:
- the **displayed times** and
- the **handle positions (angles)**

are snapped according to these settings, so the UI and values stay perfectly in sync.

---

### `TimeRangeValue`

```dart
class TimeRangeValue {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRangeValue({required this.start, required this.end});

  Duration get duration;
}
```

- `start` / `end`: 24‑hour times.
- `duration`:
  - Computed as the forward difference from `start` to `end`.
  - Handles ranges that cross midnight (e.g. `23:00 → 07:00` = 8 hours).

---

### Styling with `TimePickerStyle`

```dart
class TimePickerStyle {
  final Color trackColor;
  final List<Color> rangeGradient;
  final double strokeWidth;
  final double handlerRadius;
  final Color handlerColor;
  final Widget? startHandlerWidget;
  final Widget? endHandlerWidget;

  const TimePickerStyle({
    this.trackColor = const Color(0xFFEEEEEE),
    this.rangeGradient = const [Colors.blue, Colors.lightBlueAccent],
    this.strokeWidth = 30.0,
    this.handlerRadius = 18.0,
    this.handlerColor = Colors.white,
    this.startHandlerWidget,
    this.endHandlerWidget,
  });
}
```

- **`trackColor`**: background ring color.
- **`rangeGradient`**: gradient along the active arc (start → end).
- **`strokeWidth`**: thickness of the ring.
- **`handlerRadius` / `handlerColor`**:
- base circular handlers drawn by the painter.
- **`startHandlerWidget` / `endHandlerWidget`**:
- Optional custom widgets rendered **on top of** the handles, positioned so that their centers sit exactly on the ring.

Example:

```dart
style: TimePickerStyle(
  trackColor: Colors.white10,
  rangeGradient: const [Colors.indigoAccent, Colors.orange],
  strokeWidth: 40,
  handlerRadius: 20,
  handlerColor: Colors.white,
  startHandlerWidget: const Icon(Icons.nights_stay, color: Colors.white),
  endHandlerWidget: const Icon(Icons.wb_sunny, color: Colors.white),
),
```

---

## Example: showing total duration in the center

The example app shows how to put the picker in a `Stack` and render the total duration inside the circle:

```dart
Stack(
  alignment: Alignment.center,
  children: [
    CircularTimeRangePicker(
      initialValue: _sleepTime,
      size: const Size(280, 280),
      onChanged: (newRange) {
        setState(() => _sleepTime = newRange);
      },
      style: const TimePickerStyle(
        trackColor: Colors.white10,
        rangeGradient: [Colors.indigoAccent, Colors.orange],
        strokeWidth: 40,
        handlerRadius: 20,
        handlerColor: Colors.white,
      ),
      minuteInterval: 10,
      snapStrategy: SnapStrategy.round,
    ),
    Text(
      _formatDuration(_sleepTime), // e.g. "8h", "4h 30m"
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
);
```

---

## Roadmap / ideas

- Expose more styling hooks (labels, ticks, etc.)
- Support theming helpers
- Additional presets for common use‑cases (sleep, focus timer, etc.)

---

## License

This package is distributed under the MIT License. See `LICENSE` for details.

<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
