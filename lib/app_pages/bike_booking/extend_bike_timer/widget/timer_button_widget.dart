import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app_themes/app_colors.dart';

class TimerButtonWidget extends StatefulWidget {
  final List data;
  const TimerButtonWidget({super.key, required this.data});

  @override
  State<TimerButtonWidget> createState() => _TimerButtonWidgetState();
}

class _TimerButtonWidgetState extends State<TimerButtonWidget> {
  String formattedMinutes = "";
  String formattedSeconds = "";
  Timer? countdownTimer;
  int _start = 0;
  bool enableChasingTime = false;

  @override
  void initState() {
    getBlockDetails();
    super.initState();
  }
  @override
  void dispose() {
    debugPrint("---- End Time Button Widget ---");
    countdownTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: enableChasingTime
              ? const Color(0xffFB8F80)
              : const Color(0xffE1FFE6),
          side: const BorderSide(color: Color(0xffE1FFE6), width: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          "$formattedMinutes:$formattedSeconds Minute to Ride Time!",
          style: TextStyle(
            color: enableChasingTime ? Colors.white : AppColors.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  getBlockDetails() {
    _cancelTimer();
    List block = widget.data;
    var time1 = DateTime.parse(block[0]['blockedOn'].toString());
    var time2 = DateTime.parse(block[0]['blockedTill'].toString());
    Duration difference = time2.difference(time1);
    Duration remainingTime = const Duration();
    _start = difference.inMinutes * 60;
    double percentage = _start * 0.20;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      DateTime targetDateTime = DateTime.parse(time2.toString()).toLocal();
      remainingTime = targetDateTime.difference(DateTime.now());
      int minutes = remainingTime.inMinutes % 60;
      int seconds = remainingTime.inSeconds % 60;
      int remainInSec = remainingTime.inMinutes * 60;
      formattedMinutes = minutes.toString().padLeft(2, '0');
      formattedSeconds = seconds.toString().padLeft(2, '0');
      if (percentage > remainInSec) {
        enableChasingTime = true;
      }
      if (remainingTime.isNegative) {
        countdownTimer?.cancel();
      }
      if ("$formattedMinutes:$formattedSeconds" == "00:00") {
        countdownTimer?.cancel();
        Navigator.pushReplacementNamed(context, "error_bike");
      }
      setState(() {});
    });
  }

  void _cancelTimer() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
  }
}
