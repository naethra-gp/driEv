import 'package:flutter/material.dart';

import '../../../app_themes/app_colors.dart';
import '../../../app_utils/app_widgets/app_button.dart';

class BookingFailed extends StatefulWidget {
  const BookingFailed({super.key});

  @override
  State<BookingFailed> createState() => _BookingFailedState();
}

class _BookingFailedState extends State<BookingFailed> {
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
                "No EVs available for reservation at the moment!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 50),
              AppButtonWidget(
                title: "Pick Another Ride",
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
