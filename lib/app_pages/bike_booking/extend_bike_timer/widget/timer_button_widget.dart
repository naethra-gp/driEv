import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app_config/app_constants.dart';
import '../../../../app_themes/app_colors.dart';

class TimerButtonWidget extends StatefulWidget {
  final List data;
  const TimerButtonWidget({super.key, required this.data});

  @override
  State<TimerButtonWidget> createState() => _TimerButtonWidgetState();
}

class _TimerButtonWidgetState extends State<TimerButtonWidget>
    with WidgetsBindingObserver {
  String formattedMinutes = "";
  String formattedSeconds = "";
  Timer? countdownTimer;
  int _start = 0;
  bool enableChasingTime = false;

  int _remainingSeconds = 0;
  bool isOnCounter = false;

  @override
  void initState() {
    // getBlockDetails();
    WidgetsBinding.instance.addObserver(this);
    _stopTimer();
    _getBlockBike();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint("---- End Time Button Widget ---");
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
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
        child: getTimeCount(minutes, seconds),
      ),
    );
  }

  _getBlockBike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List block = widget.data;
    prefs.setString(Constants.blockedTill, block[0]['blockedTill'].toString());
    prefs.setString(Constants.blockedOn, block[0]['blockedOn'].toString());
    startCountdown();
  }

  startCountdown() async {
    log("--- START TIMER ---");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String blockTime = prefs.getString(Constants.blockedTill) ?? "";
    String blockedOn = prefs.getString(Constants.blockedOn) ?? "";
    log("blockedOn Time: $blockedOn");
    log("blockedTill Time: $blockTime");
    if (blockTime.toString().isEmpty) return;
    // DATE PARSE AND CONVERT STRING TO TIME
    DateTime blockedTime = DateTime.parse(blockTime);
    // GET CURRENT TIME
    DateTime currentTime = DateTime.now();
    Duration difference = blockedTime.difference(currentTime);
    int sec = difference.inSeconds;
    setState(() {
      _remainingSeconds = sec;
      isOnCounter = true;
    });

    /// CALCULATING PERCENTAGE
    DateTime bo = DateTime.parse(blockedOn);
    Duration diff = blockedTime.difference(bo);
    double percentage = diff.inSeconds * 0.25;
    print("_remainingSeconds $_remainingSeconds");
    print("percentage $percentage");

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        if (int.parse(percentage.toStringAsFixed(0)) > _remainingSeconds) {
          enableChasingTime = true;
        }
        debugPrint('Remaining Seconds: $_remainingSeconds');
      } else {
        countdownTimer?.cancel();
        prefs.setString(Constants.blockedTill, "");
        setState(() {
          _remainingSeconds = 0;
          isOnCounter = false;
          enableChasingTime = false;
        });
        _showAlertDialog(context);
      }
    });
  }

  Future<void> _stopTimer() async {
    if (countdownTimer!.isActive) {
      countdownTimer?.cancel();
      setState(() {
        _remainingSeconds = 0;
        isOnCounter = false;
        enableChasingTime = false;
      });
      debugPrint("--- TIMER STOPPED ---");
    }
  }

  _showAlertDialog(context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                'Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto-Bold",
                ),
              ),
              content: const Text(
                'The timer has stopped. The app will now redirect to the Home Page.',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: "Roboto-Bold",
                  fontSize: 14,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    // if (viaApi) {
                    //   Navigator.pushNamed(context, "home");
                    // }
                    // if (viaApp) {
                    //   // TODO: CHANGE NAVIGATION IN SELECT VEHICLE
                    //   Navigator.pushNamed(
                    //     context,
                    //     "select_vehicle",
                    //     arguments: widget.data[0]['homeData'],
                    //   );
                    // }
                    Navigator.pushNamedAndRemoveUntil(
                        context, "home", (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log('App is paused');
      _stopTimer();
      startCountdown();
    } else if (state == AppLifecycleState.resumed) {
      log('App is resumed');
      _stopTimer();
      startCountdown();
    } else if (state == AppLifecycleState.detached) {
      log('App is detached');
      _stopTimer();
      startCountdown();
    }
  }

  getTimeCount(minutes, seconds) {
    String mins = minutes.toString().padLeft(2, '0');
    String secs = seconds.toString().padLeft(2, '0');

    if (mins != "00") {
      return Text(
        "$mins:$secs Minutes to Ride Time!",
        style: TextStyle(
          color: enableChasingTime ? Colors.white : AppColors.primary,
          fontSize: 14,
        ),
      );
    } else {
      return Text(
        "$mins:$secs Seconds to Ride Time!",
        style: TextStyle(
          color: enableChasingTime ? Colors.white : AppColors.primary,
          fontSize: 14,
        ),
      );
    }
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
