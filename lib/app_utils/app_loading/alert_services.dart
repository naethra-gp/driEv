import 'dart:io';

import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../app_dialogs/widgets/block_user_content.dart';
import '../../app_dialogs/widgets/kyc_block_widget.dart';
import '../../app_dialogs/widgets/kyc_hold_widget.dart';
import '../../app_themes/app_colors.dart';
import 'widgets/balance_alert_widget.dart';
import 'widgets/vehicle_alert.dart';

class AlertServices {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  showLoading([String? title]) async {
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.light;
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.fadingCircle;
    EasyLoading.instance.toastPosition = EasyLoadingToastPosition.center;
    EasyLoading.instance.animationStyle = EasyLoadingAnimationStyle.scale;
    return await EasyLoading.show(
      status: title ?? 'Please wait...',
      maskType: EasyLoadingMaskType.black,
      dismissOnTap: false,
    );
  }

  hideLoading() async {
    return await EasyLoading.dismiss();
  }

  errorToast(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  successToast(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }

  toast(String message) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 12.0,
    );
  }

  _showBackDialog(context) {
    return showDialog<bool>(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'Exit App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
            ),
          ),
          content: const Text(
            'Are you sure you want to exit app?',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Roboto-Bold",
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
              ),
              onPressed: () {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
                // Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  holdKycAlert(context) {
    return kycMainModel(context, const KycHoldWidget());
  }

  rejectKycAlert(context) {
    return kycMainModel(context, const KycBlockWidget());
  }

  blockedKycAlert(BuildContext context, String reason) {
    return kycMainModel(context, const BlockUserContent());
  }

  kycMainModel(BuildContext context, Widget child) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(.8),
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) {
              return;
            }
            final bool shouldPop = await _showBackDialog(context) ?? false;
            if (context.mounted && shouldPop) {
              Navigator.pop(context);
            }
          },
          child: child,
        );
      },
    );
  }

  balanceAlert(BuildContext context, message, List stationDetails,
      String rideID, List scanEndRideId) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return BalanceAlertWidget(
          message: message,
          stationDetails: stationDetails,
          rideID: rideID,
          scanEndRideId: scanEndRideId,
        );
      },
    );
  }
  vehicleAlert(BuildContext context, String message) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return VehicleAlert(message: message);
      },
    );
  }

  insufficientBalanceAlert(BuildContext context, String balance, String balSub,
      List stationDetails, String rideID, List scanEndRideId) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
          height: height,
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
                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //     right: 50,
                    //     left: 50,
                    //     top: 30,
                    //     bottom: 0,
                    //   ),
                    //   child: Image.asset(
                    //     "assets/img/oops.png",
                    //     height: 60,
                    //     width: 60,
                    //   ),
                    // ),
                    const SizedBox(height: 25),
                    Center(
                      child: Image.asset(
                        "assets/img/oops.png",
                        height: 60,
                        width: 60,
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
                    // const SizedBox(height: 14),
                    // Text(
                    //   balance,
                    //   style: const TextStyle(
                    //     fontSize: 28,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: width * 0.9,
                      child: Text(
                        balSub,
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
        );
      },
    );
  }
}
