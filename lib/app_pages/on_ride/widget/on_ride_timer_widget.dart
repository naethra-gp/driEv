import 'dart:async';

import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';

class OnRideTimerWidget extends StatefulWidget {
  final List rd;
  const OnRideTimerWidget({
    super.key,
    required this.rd,
  });

  @override
  State<OnRideTimerWidget> createState() => _OnRideTimerWidgetState();
}

class _OnRideTimerWidgetState extends State<OnRideTimerWidget> {
  // TIMER
  late Timer _timer;
  late DateTime _startTime;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    int milliseconds = widget.rd[0]['durationTime'];
    Duration duration = Duration(milliseconds: milliseconds);

    _startTime = DateTime.now().subtract(Duration(milliseconds: milliseconds));
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _calculateElapsedTime();
      });
    });
    _calculateElapsedTime();
  }

  void _calculateElapsedTime() {
    DateTime now = DateTime.now();
    _elapsedTime = now.difference(_startTime);
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = countTimer(_elapsedTime);
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.timer_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(width: 5),
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Ride Duration',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff7E7E7E),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  String countTimer(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
