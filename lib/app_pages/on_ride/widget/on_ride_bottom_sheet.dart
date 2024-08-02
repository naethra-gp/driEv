import 'dart:ui';

import 'package:driev/app_config/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_themes/app_colors.dart';
import '../../app_common/need_help_widget.dart';
import 'on_ride_timer_widget.dart';

class OnRideBottomSheet extends StatelessWidget {
  final dynamic widget;
  final dynamic rideDetails;
  const OnRideBottomSheet({super.key, this.widget, this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: const Text("Confirm"),
                content: const Text("Do you want Exit app?"),
                actions: [
                  TextButton(
                    child: const Text(
                      "No",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                color: const Color(0xFFF5F5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                  text: 'dri', style: heading(Colors.black)),
                              TextSpan(
                                text: 'EV ',
                                style: heading(AppColors.primary),
                              ),
                              TextSpan(
                                text:
                                    "${rideDetails[0]['planType'].toString()} ${rideDetails[0]['vehicleId'].toString()}",
                                style: heading(Colors.black),
                              ),
                            ],
                          )),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              needHelpAlert(context);
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.headset_mic_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "Estimated Range",
                                style: TextStyle(
                                  color: Color(0xff626262),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${rideDetails[0]['estimatedRange'] ?? "0"} km",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: 130,
                              alignment: Alignment.center, // This is needed
                              child: Image.asset(
                                // "assets/img/bike.png",
                                Constants.defaultBike,
                                fit: BoxFit.fitWidth,
                                width: 200,
                              ),
                            ),
                            // child: Image.asset(
                            //   "assets/img/bike2.png",
                            //   height: 140,
                            //   width: 150,
                            //   fit: BoxFit.cover,
                            // ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Card(
              //   margin: const EdgeInsets.all(5.0),
              //   surfaceTintColor: Colors.transparent,
              //   color: const Color(0xFFF5F5F5),
              //   elevation: 0,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(10),
              //   ),
              //   clipBehavior: Clip.antiAlias,
              //   child: Padding(
              //     padding: const EdgeInsets.all(15),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16.0),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.speed_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${rideDetails[0]['totalKm']} km',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Ride Distance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff7E7E7E),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  OnRideTimerWidget(
                    rd: rideDetails,
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 25.0),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    List params = [
                      {
                        "rideId": widget.rideId.toString(),
                        "scanCode": rideDetails[0]['scanCode'],
                      }
                    ];
                    print(params);
                    Navigator.pushNamed(
                      context,
                      "scan_to_end_ride",
                      arguments: params,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('End Ride'),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'You can end your ride at the ${widget.rideId.split("-").first} station only',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins-Bold",
      // fontWeight: FontWeight.bold,
      color: color,
      fontSize: 18,
    );
  }

  needHelpAlert(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return const NeedHelpWidget();
      },
    );
  }
}
