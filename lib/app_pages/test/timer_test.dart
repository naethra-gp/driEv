import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../registration_page/widget/reg_text_form_widget.dart';

class TimerTest extends StatefulWidget {
  const TimerTest({super.key});

  @override
  State<TimerTest> createState() => _TimerTestState();
}

class _TimerTestState extends State<TimerTest> with WidgetsBindingObserver {
  TextEditingController timerCtrl = TextEditingController();
  String expireTime = "";
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    loadTimer();
  }

  loadTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String exp = prefs.getString('exp') ?? "";
    print("exp $exp");
    if (exp.toString().isNotEmpty) {
      String formattedDate3 =
          DateFormat('hh:mm:ss a').format(DateTime.parse(exp));
      print(formattedDate3);
      setState(() {
        expireTime = formattedDate3.toString().padLeft(2, '0');
      });

      var cd = DateTime.now();
      print("cd $cd");

      Duration difference = DateTime.parse(exp).difference(cd);

      int mins = difference.inMinutes;
      int sec = difference.inSeconds;

      print("mins $mins");
      print("sec $sec");

      setState(() {
        // timerCtrl.text = mins.toString();
        _remainingSeconds = sec;
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
          debugPrint('Remaining seconds: $_remainingSeconds');
        } else {
          timer.cancel();
          setState(() {
            _remainingSeconds = 0;
            _isRunning = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onStartButtonPressed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRunning = true;
      _remainingSeconds = int.parse(timerCtrl.text) * 60;
    });

    int mins = int.parse(timerCtrl.text);
    DateTime now = DateTime.now();
    DateTime newTime = now.add(Duration(minutes: mins));
    String format = DateFormat('hh:mm:ss a').format(newTime);
    print("Format Date -> $format");
    setState(() {
      expireTime = format.toString().padLeft(2, '0');
    });
    await prefs.setString('exp', newTime.toString());

    /// timer functions
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      debugPrint('Remaining seconds: $_remainingSeconds');
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      }
      if (_remainingSeconds.isNegative) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
      }
    });
  }

  saveTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _remainingSeconds = int.parse(timerCtrl.text) * 60;
    });
    int mins = int.parse(timerCtrl.text);
    DateTime now = DateTime.now();
    DateTime newTime = now.add(Duration(minutes: mins));
    String format = DateFormat('hh:mm:ss a').format(newTime);
    print("Format Date -> $format");
    setState(() {
      expireTime = format.toString().padLeft(2, '0');
    });
    await prefs.setString('exp', newTime.toString());
  }

  Future<void> _stopTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_timer!.isActive) {
      _timer?.cancel();
      await prefs.setInt('start_time', 0);
      setState(() {
        expireTime = "";
        _remainingSeconds = 0;
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Test'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   '$formattedMinutes:$formattedSeconds',
            //   style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            // ),
            Text(
              '$minutes:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormWidget(
                title: 'Enter Timer',
                controller: timerCtrl,
                maxLength: 2,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                required: true,
                prefixIcon: Icons.account_circle_outlined,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value.toString().trim().isEmpty) {
                    return "Field is Mandatory!";
                  }
                  if (int.parse(value.toString().trim()) > 60) {
                    return "Enter Valid Minutes!";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _onStartButtonPressed,
                  child: const Text('Start Timer'),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: !_isRunning ? null : _stopTimer,
                  child: const Text('End Timer'),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'End Time: $expireTime',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopTimer();
      loadTimer();
      // The app is in the background or the user is leaving the app.
      print('App is paused');
    } else if (state == AppLifecycleState.resumed) {
      // The app is back in the foreground.
      print('App is resumed');
      _stopTimer();
      loadTimer();
      // _stopTimer();
      // loadTimer();
    } else if (state == AppLifecycleState.detached) {
      // The app is detached from the view, meaning it is about to be terminated.
      print('App is detached');
    }
  }
}

extension DateTimeExtension on DateTime {
  DateTime applied(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }
}
