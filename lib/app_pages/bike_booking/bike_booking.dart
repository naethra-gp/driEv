import 'package:flutter/material.dart';

import '../../app_config/app_constants.dart';

class BikeBooking extends StatefulWidget {
  const BikeBooking({super.key});

  @override
  State<BikeBooking> createState() => _BikeBookingState();
}

class _BikeBookingState extends State<BikeBooking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Image.asset(Constants.backButton),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const Center(
          child: Text("Bike Booking"),
        )
    );
  }
}
