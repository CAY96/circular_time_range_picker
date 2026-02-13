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
        appBar: AppBar(title: const Text('Circular Time Range Picker')),
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
  // 초기값 설정: 밤 11시 ~ 아침 7시
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
              style:  TimePickerStyle(
                trackColor: Colors.white10,
                rangeGradient: [Colors.indigoAccent, Colors.deepOrangeAccent],
                strokeWidth: 40,
                handlerRadius: 25,
                handlerColor: Colors.white,
                startHandlerWidget: Icon(Icons.bed, color: Colors.indigo, size: 30),
                endHandlerWidget: Icon(Icons.sunny, color: Colors.orange, size: 30),
              ),
            ),
            // 중앙에 총 시간 표시
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
        // 선택된 시간 표시부
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

  // 시작부터 끝까지의 총 시간을 계산하고 포맷팅
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