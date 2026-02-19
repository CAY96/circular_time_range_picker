# circular_time_range_picker
A highly customizable circular time **range** picker for Flutter. 
Perfect for use cases like **sleep tracking, focus sessions, or scheduling**, where users select a start and end time on a 24-hour clock face.
<p align="center">
  <img src="https://raw.githubusercontent.com/CAY96/circular_time_range_picker/main/assets/demo_0.gif" width="30%" alt="Basic Demo" />
  <img src="https://raw.githubusercontent.com/CAY96/circular_time_range_picker/main/assets/demo_1.gif" width="30%" alt="Basic Demo" />
</p>

## Features

* **24h Circular Selection:** Intuitive 360-degree time range picking.
* **Flexible Interaction:** * Drag the **start handle** to adjust the beginning.
    * Drag the **end handle** to adjust the end.
    * Drag the **entire arc** to shift the whole time range at once.
* **Smart Snapping:** Fully configurable `minuteInterval` (e.g., 5, 10, 15, 30 min) with multiple snapping strategies (`round`, `floor`, `ceil`).
* **Highly Customizable UI:**
    * Support for **Gradients** on the range arc.
    * Use **Custom Widgets** (Icons, Images) as handles.
    * Adjustable stroke width, track colors, and handle sizes.
* **Midnight Logic:** Automatically calculates durations that cross the midnight threshold (e.g., 23:00 to 07:00).

---

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  circular_time_range_picker: ^0.1.0
```

Import it in your Dart code:

```dart
import 'package:circular_time_range_picker/circular_time_range_picker.dart';
```

---
## Usage

**Simple Example**
The most basic implementation requires an `initialValue` and an `onChanged` callback.
```dart
CircularTimeRangePicker(
  initialValue: const TimeRangeValue(
    start: TimeOfDay(hour: 22, minute: 0),
    end: TimeOfDay(hour: 6, minute: 0),
  ),
  onChanged: (newRange) {
    print("New Duration: ${newRange.duration.inHours} hours");
  },
)
```

**Advanced Styling & Snapping**
You can use `TimePickerStyle` and `SnapStrategy` to match your app's design and UX requirements.
```dart
CircularTimeRangePicker(
  initialValue: _myRange,
  size: const Size(280, 280),
  minuteInterval: 15, 
  snapStrategy: SnapStrategy.round,
  style: TimePickerStyle(
    trackColor: Colors.white10,
    rangeGradient: [Colors.indigoAccent, Colors.deepOrangeAccent],
    strokeWidth: 40,
    handlerRadius: 22,
    startHandlerWidget: const Icon(Icons.bed, color: Colors.indigo, size: 24),
    endHandlerWidget: const Icon(Icons.sunny, color: Colors.orange, size: 24),
  ),
  onChanged: (range) => setState(() => _myRange = range),
)
```

---

## API Reference

### `CircularTimeRangePicker`

```dart
CircularTimeRangePicker({
  Key? key,
  Size size = const Size(250, 250),
  required TimeRangeValue initialValue,
  TimePickerStyle style = const TimePickerStyle(),
  required void Function(TimeRangeValue) onChanged,
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

## FAQ

**Q: How do I display the total duration in the center?**
A: Wrap the `CircularTimeRangePicker` in a `Stack` and place a `Text` widget in the center. Since the picker's center is transparent, the text will be visible.

**Q: Does it support 12-hour or 24-hour formats?**
A: The picker always operates on a 24-hour logic (full circle), but you can format the output `TimeOfDay` to 12h or 24h format in your UI using `timeOfDay.format(context)`.

---

## Roadmap

- [ ] Tick marks and hour labels on the track.
- [ ] Vibrate feedback on snap.
- [ ] Support for non-linear time scales.

---

## License

This package is distributed under the MIT License. See `LICENSE` for details.
