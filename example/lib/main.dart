import 'package:flutter/material.dart';
import 'package:circular_time_range_picker/circular_time_range_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: const Center(child: SleepTrackerExample()),
      ),
    );
  }
}

class SleepTrackerExample extends StatefulWidget {
  const SleepTrackerExample({super.key});

  @override
  State<SleepTrackerExample> createState() => _SleepTrackerExampleState();
}

class _SleepTrackerExampleState extends State<SleepTrackerExample> {
  // Initial setup: 11:00 PM to 07:00 AM
  TimeRangeValue _sleepTime = const TimeRangeValue(
    start: TimeOfDay(hour: 23, minute: 0),
    end: TimeOfDay(hour: 7, minute: 0),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularTimeRangePicker(
              initialValue: _sleepTime,
              size: const Size(280, 280),
              onChanged: (newRange) {
                setState(() => _sleepTime = newRange);
              },
              minuteInterval: 10,
              snapStrategy: SnapStrategy.round,
              style: TimePickerStyle(
                trackColor: Colors.white10,
                rangeGradient: [Colors.indigoAccent, Colors.deepOrangeAccent],
                strokeWidth: 40,
                handlerRadius: 25,
                handlerColor: Colors.white,
                startHandlerWidget: Icon(Icons.mode_night_rounded, color: Colors.indigo, size: 30),
                endHandlerWidget: Icon(Icons.sunny, color: Colors.orange, size: 30),
                tickStyle: const TickStyle(
                  tickColor: Colors.white54,
                  tickCount: 24,
                  tickOffsetFromCenter: 32.0,
                  tickLength: 5.0,
                  tickWidth: 2.0,
                  majorTickLength: 10.0,
                  majorTickInterval: 6,
                  tickAlignment: TickAlignment.outer,
                ),
              ),
            ),
            // Display total duration in the center
            Text(
              _formatDuration(_sleepTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        // Selected time information display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _timeInfo('Start Time', _sleepTime.start),
            _timeInfo('End Time', _sleepTime.end),
          ],
        ),
      ],
    );
  }

  /// Calculates and formats the total duration between start and end times.
  String _formatDuration(TimeRangeValue range) {
    final duration = range.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  Widget _timeInfo(String label, TimeOfDay time) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(
          time.format(context),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}