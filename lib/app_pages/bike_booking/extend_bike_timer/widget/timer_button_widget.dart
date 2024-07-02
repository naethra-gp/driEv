import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  late Timer _timer;
  bool enableChasingTime = false;

  @override
  void initState() {
    getBlockDetails();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
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
    List block = widget.data;
    var time1 = DateTime.parse(block[0]['blockedOn'].toString());
    var time2 = DateTime.parse(block[0]['blockedTill'].toString());
    countDownTime(block[0]['blockedTill'].toString());
  }

  countDownTime(String blockedTill) {

    _cancelTimer();
    Duration remainingTime = const Duration();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      DateTime targetDateTime = DateTime.parse(blockedTill).toLocal();
      remainingTime = targetDateTime.difference(DateTime.now());
      int minutes = remainingTime.inMinutes % 60;
      int seconds = remainingTime.inSeconds % 60;
      formattedMinutes = minutes.toString().padLeft(2, '0');
      formattedSeconds = seconds.toString().padLeft(2, '0');
      print("Time : $formattedMinutes:$formattedSeconds");
      if (remainingTime.isNegative) {
        // formattedMinutes = "00";
        // formattedSeconds = "00";
        countdownTimer?.cancel();
      }
      if ("$formattedMinutes:$formattedSeconds" == "00:00") {
        print("--- Timer Stopped ---");
        countdownTimer?.cancel();
        Navigator.pushReplacementNamed(context, "error_bike");
      }
      setState(() {});
    });
  }

  void _startTimer() {
    double percentage = _start * 0.20;
    print("percentage $percentage");
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > 0) {
          _start--;
        } else {
          _timer.cancel();
        }
        if (percentage > _start) {
          enableChasingTime = true;
        }
        print("_start $_start");
        print("enableChasingTime $enableChasingTime");
      });
    });
  }

  void _cancelTimer() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
  }
}
