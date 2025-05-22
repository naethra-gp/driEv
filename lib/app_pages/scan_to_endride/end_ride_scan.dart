import 'dart:async';
import 'dart:io';
import 'package:cron/cron.dart';
import 'package:driev/app_services/booking_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import '../../app_config/app_constants.dart';
import '../../app_utils/app_loading/alert_services.dart';
import 'widget/ride_done_alert.dart';

class EndRideScanner extends StatefulWidget {
  final List rideID;
  const EndRideScanner({
    super.key,
    required this.rideID,
  });

  @override
  State<EndRideScanner> createState() => _EndRideScannerState();
}

class _EndRideScannerState extends State<EndRideScanner> {
  bool isScanCompleted = false;
  TextEditingController bikeNumberCtl = TextEditingController();
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();
  String otpCode = "";
  Timer? timer;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'end-QR');
  Barcode? result;
  QRViewController? controller;
  String campus = '';
  String rideId = '';
  String qr = "";
  int remainingSeconds = 30;
  Timer? countdownTimer;

  bool flashOn = false;
  bool hasShownPopup = false;
  bool showQR = true;

  /// TIMER 30S
  void _startCountdown() {
    _cancelTimer();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        // if (remainingSeconds == 20) {
        //   QrMobileVision.toggleFlash();
        // }
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _cancelTimer();
          Navigator.pushReplacementNamed(context, "end_time_out",
              arguments: widget.rideID);
        }
      });
    });
  }

  void _cancelTimer() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  void initState() {
    List<String> a = widget.rideID[0]['rideId'].toString().split("-");
    setState(() {
      campus = a[0];
      rideId = widget.rideID[0]['rideId'].toString();
    });
    _startCountdown();
    QrMobileVision.stop();
    super.initState();
  }

  @override
  deactivate() {
    super.deactivate();
    QrMobileVision.stop();
  }

  @override
  void dispose() {
    timer?.cancel();
    bikeNumberCtl.dispose();
    controller?.dispose();
    QrMobileVision.stop();
    super.dispose();
  }

  void _onQRViewCreated(String code) {
    setState(() {
      qr = code;
      if (qr != "") {
        // QrMobileVision.stop();
        checkBikeNumber(qr.toString());
      }
    });
  }

  String formatNumber(int number) {
    final formatter = NumberFormat('0000');
    return formatter.format(number);
  }

  String formatCode(int number) {
    String numberStr = number.toString();
    return numberStr.substring(numberStr.length - 4).padLeft(4, '0');
  }

  checkBikeNumber(String code) {
    if (hasShownPopup) {
      return;
    }
    if (code.toString().length != 7) {
      setState(() {
        hasShownPopup = true;
        bikeNumberCtl.text = "";
      });
      String msg = "Entered/Scanned Vehicle is invalid";
      alertServices.errorToast(msg);
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          hasShownPopup = false;
        });
      });
    } else {
      String bike = widget.rideID[0]['scanCode'].toString();
      if (formatCode(int.parse(code)) == formatNumber(int.parse(bike))) {
        /// BIKE NUMBER VALID STATE
        QrMobileVision.stop();
        FocusScope.of(context).unfocus();
        bikeNumberCtl.text = bike.toString();
        submitBikeNUmber();
      } else {
        setState(() {
          bikeNumberCtl.text = "";
          hasShownPopup = true;
        });
        String msg = "Entered/Scanned Vehicle is invalid";
        alertServices.errorToast(msg);
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            hasShownPopup = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 70),
                  GestureDetector(
                    onTap: () {
                      QrMobileVision.toggleFlash();
                      setState(() {
                        flashOn = !flashOn;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.green),
                      width: 30,
                      height: 30,
                      child: Icon(
                        flashOn ? Icons.flash_off : Icons.flash_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (showQR)
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: ShapeDecoration(
                            shape: QrScannerOverlayShape(
                              borderColor: AppColors.primary,
                              borderRadius: 5,
                              borderWidth: 5,
                            ),
                          ),
                          child: QrCamera(
                            onError: (context, error) => const Center(
                              child: Text(
                                "Hey.! There may be an error with your camera due to multiple access attempts. Please try scanning it again.",
                                textAlign: TextAlign.center,
                                // error.toString(),
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            cameraDirection: CameraDirection.BACK,
                            qrCodeCallback: (code) {
                              if (code != null) {
                                _onQRViewCreated(code);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    "Wrap up your two-wheeled \n adventure!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "End your ride at $campus by scanning the QR \n code or entering the bike number manually.",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 190,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: bikeNumberCtl,
                          textAlign: TextAlign.left,
                          onChanged: (value) {},
                          maxLength: 6,
                          textInputAction: TextInputAction.done,
                          keyboardType: Platform.isAndroid
                              ? TextInputType.phone
                              : const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: false,
                                ),
                          // keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0Xff7A7A7A),
                            ),
                            counterText: "",
                            hintText: 'Enter Bike Number',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            String bike = bikeNumberCtl.text.toString();
                            if (bike.isNotEmpty && bike.length <= 6) {
                              String vId =
                                  widget.rideID[0]['scanCode'].toString();
                              if (bike == vId) {
                                submitBikeNUmber();
                              } else {
                                String msg =
                                    "Entered/Scanned Vehicle is invalid";
                                alertServices.errorToast(msg);
                              }

                              // checkBikeNumber(bikeNumberCtl.text.toString());
                            } else {
                              alertServices.errorToast(
                                  "Enter the Bike Number or Scan the QR Code");
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Image.asset(Constants.backButton),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  submitBikeNUmber() async {
    // String mobile = secureStorage.get("mobile");
    _cancelTimer();
    // ON-RIDE CRON JOB
    final cron = Cron();
    try {
      await cron.close();
    } on ScheduleParseException {
      await cron.close();
    }
    alertServices.showLoading();
    bookingServices.getRideEndPin(rideId).then((r2) {
      // print("r2 --> $r2");
      alertServices.hideLoading();

      if (r2['key'] == "WALLET_ISSUE") {
        QrMobileVision.stop();
        _cancelTimer();
        alertServices.insufficientBalanceAlert(
            context, "", r2["message"].toString(), [], "", widget.rideID);
      } else {
        if (r2 != null) {
          timer?.cancel();
          String stopPing = r2['stopPing'].toString();
          setState(() {
            showQR = false;
          });
          showOtp(stopPing);
          String rideID = r2['rideID'].toString();
          timer = Timer.periodic(
            const Duration(seconds: 3),
            (Timer t) => startWatching(rideID),
          );
        }
      }
      // if (b < c) {
      //   QrMobileVision.stop();
      //   _cancelTimer();
      //   alertServices.insufficientBalanceAlert(
      //       context, b.toString(), r2["message"].toString(), [], "", widget.rideID);
      // } else
    });

    // bookingServices.getRideEndPin(rideId).then((r) {
    //   bookingServices.getWalletBalance(mobile).then((r) {
    //     double b = r['balance'];
    //     print("Balance --> $b");
    //     bookingServices.getRideDetails(rideId).then((r1) {
    //       List rideDetails = [r1];
    //       double c = rideDetails[0]["payableAmount"];
    //       print("payableAmount --> $c");
    //       print("rideId --> $rideId");
    //
    //       bookingServices.getRideEndPin(rideId).then((r2) {
    //         print("r2 --> $r2");
    //
    //         alertServices.hideLoading();
    //         if (b < c) {
    //           QrMobileVision.stop();
    //           _cancelTimer();
    //           alertServices.insufficientBalanceAlert(
    //               context, b.toString(), r2["message"].toString(), [], "", widget.rideID);
    //         } else if (r2 != null) {
    //           timer?.cancel();
    //           String stopPing = r2['stopPing'].toString();
    //           setState(() {
    //             showQR = false;
    //           });
    //           showOtp(stopPing);
    //           String rideID = r2['rideID'].toString();
    //           timer = Timer.periodic(
    //             const Duration(seconds: 3),
    //             (Timer t) => startWatching(rideID),
    //           );
    //         }
    //       });
    //     });
    //   });
    // });
  }

  showOtp(String otp) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: height / 2, // Adjust the height here
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: height / 6 - 70,
                child: Container(
                  height: height / 2, // Adjust the height here
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
                left: 10,
                right: 10,
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
                            setState(() {
                              showQR = true;
                            });
                            _cancelTimer();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "Share this PIN with our station executive to end the ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // color: Color(0xff6F6F6F),
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      otp.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TextButton(
                    //   onPressed: () {},
                    //   child: const Text(
                    //     'Regenerate OTP',
                    //     style: TextStyle(
                    //       decoration: TextDecoration.underline,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  startWatching(String rideId) {
    // print(" ---- startWatching ----");
    String mobile = secureStorage.get("mobile");
    bookingServices.rideEndConfirmation(mobile.toString()).then((r) {
      if (r != null) {
        if (rideId.toString() == r['rideId'].toString()) {
          rideDoneAlert([r]);
          timer?.cancel();
        }
      }
    });
  }

  rideDoneAlert(List res) {
    // print(" ---- Stop Watching ----");
    Navigator.pop(context);
    QrMobileVision.stop();
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black,
      builder: (context) {
        return PopScope(
          canPop: false,
            onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
          },
          child: RideDoneAlert(
            result: res,
            rideId: rideId,
          ),
        );
      },
    );
  }
}
