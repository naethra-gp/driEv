import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';
import '../../../app_utils/app_widgets/app_button.dart';

class EndTimeOut extends StatefulWidget {
  final List data;
  const EndTimeOut({super.key, required this.data});

  @override
  State<EndTimeOut> createState() => _EndTimeOutState();
}

class _EndTimeOutState extends State<EndTimeOut> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/error_logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Oh Snap!",
                style: TextStyle(
                  fontSize: 40,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Wrong vehicle! Scan the code of the selected vehicle!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 50),
              AppButtonWidget(
                title: "Scan Again",
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "scan_to_end_ride",
                      arguments: widget.data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
