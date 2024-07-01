/*
* Date        : 29-05-2024
* Page        : Error Bike
* Description : Error widget for dynamic content
* Created By  : GNANA PRAKASAM
* Modified By : GNANA PRAKASAM
*/
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';

class ErrorBikes extends StatefulWidget {
  const ErrorBikes({super.key});

  @override
  State<ErrorBikes> createState() => _ErrorBikesState();
}

class _ErrorBikesState extends State<ErrorBikes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Center(
                  child: Image.asset(
                    "assets/app/error_otp.png",
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Oh Snap!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "No EVs available for\nreservation at the moment!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 30),
              AppButtonWidget(
                  title: "Okay",
                  onPressed: () {
                    // Navigator.pop(context);
                    Navigator.pushNamed(context, "home");
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
