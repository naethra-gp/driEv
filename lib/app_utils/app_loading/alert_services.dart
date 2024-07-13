import 'dart:io';

import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../app_themes/app_colors.dart';

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
      dismissOnTap: true,
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
          title: const Text('Exit App'),
          content: const Text(
            'Are you sure you want to exit app?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Exit'),
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
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(.75),
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
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Image.asset(
                    "assets/img/kyc_hold_logo.png",
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      "Hold on! Your KYC verification is in process",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  rejectKycAlert(context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(.75),
      enableDrag: false,
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
          child: SizedBox(
            width: double.infinity,
            height: 400,
            // height: MediaQuery.of(context).size.height * .60,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 25,
                      // height: MediaQuery.of(context).size.height * .050,
                    ),
                    Image.asset("assets/img/kyc_reject.png",
                        height: 100, width: 100),
                    const SizedBox(height: 10),
                    const Text(
                      "KYC Rejected.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff020B01),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .020,
                    ),
                    const Text(
                      "Looks like the documents you uploaded has some issue.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .020,
                    ),
                    const Text(
                      "Please visit your profile page to try recapturing a clearer image",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .030,
                    ),
                    AppButtonWidget(
                      title: "Go to Profile",
                      onPressed: () {
                        Navigator.pushNamed(context, "profile");
                      },
                    ),
                  ],
                )),
          ),
        );
      },
    );
  }

  blockedKycAlert(BuildContext context, String reason) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(.2),
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
          child: SizedBox(
            width: double.infinity,
            height: 400,
            // height: MediaQuery.of(context).size.height * .50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    "assets/img/kyc_error_alert_logo.png",
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Uh-oh! Looks like we've spotted some irregular activity on your account. Hang tight while we sort it out! ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    // style: CustomTheme.termStyle1,
                  ),
                ],
              ),
            ),
          ),
        );
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
                top: height / 6 - 100,
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
                top: height / 7.5 - 100,
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
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 50,
                        left: 50,
                        top: 30,
                        bottom: 0,
                      ),
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
                    const SizedBox(height: 16),
                    Text(
                      balance,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: width * 0.9,
                      child: Text(
                        balSub,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: SizedBox(
                          width: width - 75,
                          height: 50,
                          child: ElevatedButton(
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            child: const Text(
                              "Top Up Now",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              )
            ],
          ),
        );
        // return Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       // Content of the bottom sheet
        //       Text('This is the content of the modal bottom sheet.'),
        //       SizedBox(height: 20),
        //       Expanded(
        //         child: Align(
        //           alignment: Alignment.bottomCenter,
        //           child: ElevatedButton(
        //             onPressed: () {
        //               // Handle button press
        //               Navigator.pop(context);
        //             },
        //             child: Text('Close'),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // );
      },
    );
  }
}
