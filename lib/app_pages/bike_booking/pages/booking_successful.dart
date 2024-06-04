import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';

class BookingSuccessful extends StatefulWidget {
  final String rideId;

  const BookingSuccessful({super.key, required this.rideId});

  @override
  State<BookingSuccessful> createState() => _BookingSuccessfulState();
}

class _BookingSuccessfulState extends State<BookingSuccessful> {
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
                  "assets/img/success_logo.png",
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Hooray!",
                style: TextStyle(
                  fontSize: 40,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Ride locked in! Kick-start the ride of your dreams.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 50),
              AppButtonWidget(
                title: "Go to Controls",
                onPressed: () {
                  String rideId = widget.rideId.toString();
                  Navigator.pushNamed(context, "on_ride", arguments: rideId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
