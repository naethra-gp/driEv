import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';

class TransactionFailure extends StatefulWidget {
  const TransactionFailure({super.key});

  @override
  State<TransactionFailure> createState() => _TransactionFailureState();
}

class _TransactionFailureState extends State<TransactionFailure> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                  "Transaction Failed",
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFFE11900),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "If the amount was deducted,\n it will be credited back to\n your account within 24hrs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: AppButtonWidget(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "add_more_fund",
                            arguments: {
                              "stationDetails": [],
                              "rideId": "",
                              "rideID": [],
                            });
                      },
                      title: "Retry Payment",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
