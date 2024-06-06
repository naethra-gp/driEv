import 'dart:async';

import 'package:driev/app_services/booking_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../app_utils/app_loading/alert_services.dart';

class EndRideScanner extends StatefulWidget {
  final String rideId;
  const EndRideScanner({
    super.key,
    required this.rideId,
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    bikeNumberCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double scanArea = (width < 400 || height < 400) ? 150.0 : 300.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the radius as needed
              child: Container(
                width: 250, // adjust the size as needed
                height: 250,
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: AppColors.primary,
                    borderRadius: 5,
                    borderWidth: 10,
                  ),
                ),
                child: MobileScanner(
                  onDetect: (qrcode) {
                    print("qrcode $qrcode");
                    List a = [qrcode];
                    // if (!isScanCompleted) {
                    if (a[0]['rawValue'] == null) {
                      isScanCompleted = true;
                      debugPrint('Failed to scan Barcode');
                      alertServices.errorToast("Unable to Scan QR Code!");
                    } else {
                      final String code = a[0]['rawValue'];
                      debugPrint('Qr found! $code');
                      setState(() {
                        bikeNumberCtl.text = code.toString();
                        submitBikeNUmber();
                      });
                    }
                    // }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Wrap up your two-wheeled adventure!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "End your ride at KIIT Campus 6 by scanning the QR \n code or entering the bike number manually.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
                    onChanged: (value){
                      if(value.toString().length == 7) {
                        submitBikeNUmber();
                      }
                    },
                    maxLength: 7,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
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
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: Image.asset(
                      "assets/img/flash_on.png",
                      height: 19,
                      width: 9,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  submitBikeNUmber() {
    print("VID: ${bikeNumberCtl.text}");
    alertServices.showLoading();
    bookingServices.getRideEndPin(widget.rideId.toString()).then((r) {
      alertServices.hideLoading();
      print("Resposne: $r");
      if (r != null) {
        String stopPing = r['stopPing'].toString();
        String rideID = r['rideID'].toString();
        shopOTP(stopPing);
        timer = Timer.periodic(
          const Duration(seconds: 15),
          (Timer t) => startWatching(rideID),
        );
      }
    });
  }

  shopOTP(String otp) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: height / 2,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: height / 5.5 - 100,
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
                top: height / 6.6 - 100,
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
                    const Padding(
                      padding: EdgeInsets.only(
                        right: 50,
                        left: 50,
                        top: 50,
                        bottom: 20,
                      ),
                      child: Text(
                        "Please enter your OTP to\nconclude this ride.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      "Share this PIN with our station executive\nto end the ride",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff2c2c2c),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      otp,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    String mobile = secureStorage.get("mobile");
    bookingServices.rideEndConfirmation(mobile.toString()).then((r) {
      if (r != null) {
        String totalRideDuration = r['rideId'].toString();
        if (rideId.toString() == r['rideId'].toString()) {
          // Navigator.pushNamed(context, "home");
          rideDoneAlert();
        }
        print("rideId $totalRideDuration");
      }
    });
  }

  rideDoneAlert() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
          height: height / 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: height / 5.5 - 100,
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
                top: height / 6.6 - 100,
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
                        top: 50,
                        bottom: 20,
                      ),
                      child: Image.asset(
                        "assets/img/ride_end.png",
                        height: 60,
                        width: 60,
                      ),
                    ),
                    const Text(
                      "Ride done!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff2c2c2c),
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'Great job on your ',
                        style: DefaultTextStyle.of(context).style,
                        children: const <TextSpan>[
                          TextSpan(
                              text: 'last trip covering',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' 25 kilometers!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            // width: width / 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "ride_summary",
                                    arguments: widget.rideId.toString(),
                                    (route) => false);
                              },
                              child: const Text("View Ride Summary"),
                            ),
                          ),
                          const SizedBox(width: 25),
                          SizedBox(
                            // width: width / 2,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text("Rate This Ride"),
                            ),
                          ),
                        ],
                      ),
                    ),
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
