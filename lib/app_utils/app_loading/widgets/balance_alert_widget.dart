import 'package:flutter/material.dart';

import '../../app_widgets/app_button.dart';

class BalanceAlertWidget extends StatelessWidget {
  final String message;
  final String rideID;
  final List stationDetails;
  final List scanEndRideId;

  const BalanceAlertWidget({
    super.key,
    required this.message,
    required this.rideID,
    required this.stationDetails,
    required this.scanEndRideId,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      height: height / 1.8,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: mediaQueryData.viewInsets.bottom),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: height / 6 - 70,
              child: Container(
                height: height,
                width: width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              top: height / 7.5 - 70,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Center(
                    child: Image.asset(
                      "assets/img/oops.png",
                      height: 50,
                      width: 50,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Oops!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff2c2c2c),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "₹ ${getBalance(message)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: width * 0.9,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: width - 25,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: AppButtonWidget(
                            title: 'Top Up Now',
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                "add_more_fund",
                                arguments: {
                                  "stationDetails": stationDetails,
                                  "rideId": rideID,
                                  "rideID": scanEndRideId
                                },
                              );
                            },
                            height: 45),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getBalance(String message) {
    RegExp regex = RegExp(r'Available Balance is (\d+\.\d+)');
    Match? match = regex.firstMatch(message.toString());
    String? availableBalance = match?.group(1)!;
    return availableBalance;
  }
}
