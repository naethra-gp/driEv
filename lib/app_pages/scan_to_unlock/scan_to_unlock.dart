import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import 'widget/screen_text_widget.dart';

class ScanToUnlock extends StatefulWidget {
  final List data;
  const ScanToUnlock({super.key, required this.data});

  @override
  State<ScanToUnlock> createState() => _ScanToUnlockState();
}

class _ScanToUnlockState extends State<ScanToUnlock> {
  TextEditingController bikeNumberCtl = TextEditingController();
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();
  String otpCode = "";
  Timer? timer;
  LatLng? currentLocation;
  String _locationMessage = "";

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String qr = "";

  int remainingSeconds = 40;
  Timer? countdownTimer;

  @override
  void initState() {
    debugPrint(" --- PAGE: SCAN TO UNLOCK --- ");
    print("SCAN TO UNLOCK Data: ${widget.data}");
    _startCountdown();
    super.initState();
  }

  checkBikeNumber(String code) {
    print("Code -> $code");
    String vId = widget.data[0]['vehicleId'].toString();
    QrMobileVision.stop();
    if (code.toString() == vId) {
      setState(() {
        bikeNumberCtl.text = code.toString();
      });
      // startMyRide();
    } else {
      String msg =
          "Wrong vehicle! Scan the code of the assigned vehicle to end the ride";
      alertServices.errorToast(msg);
    }
  }

  /// NEW PLUGIN
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
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
                      fit: BoxFit.cover,
                      onError: (context, error) => Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                      cameraDirection: CameraDirection.BACK,
                      qrCodeCallback: (code) {
                        if (code != null) {
                          print("QR Scanned --> $code");
                          QrMobileVision.stop();
                          setState(() {
                            bikeNumberCtl.text = code.toString();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const ScreenTextWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 190,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      controller: bikeNumberCtl,
                      maxLength: 6,
                      textAlign: TextAlign.left,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        print("Value: $value");
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: 'Enter Bike Number',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0Xff7A7A7A),
                        ),
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        submitButtonClicked();
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  submitButtonClicked() {
    // startMyRide();
    String bike = bikeNumberCtl.text.toString();
    if (bike.isNotEmpty && bike.length <= 6) {
      String vId = widget.data[0]['vehicleId'].toString();
      if (bike == vId) {
        print("Start my Ride");
        startMyRide();
      } else {
        alertServices.errorToast(
            "Wrong vehicle! Scan the code of the assigned vehicle to end the ride");
        Navigator.pushReplacementNamed(context, "scan_to_unlock",
            arguments: widget.data);
      }
    }
    // print("Value:${bikeNumberCtl.text}");
  }

  Future<void> _getCurrentLocation() async {
    alertServices.showLoading("Fetching location details...");
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      _locationMessage = "${position.latitude},${position.longitude}";
      alertServices.hideLoading();
      bookAndStartMyRide();
    });
    print("_locationMessage $_locationMessage");
  }

  startMyRide() {
    if (widget.data[0]['vehicleId'].toString() != "null") {
      print("bikeNumberCtl.text -> ${bikeNumberCtl.text}");
      print("bikeNumberCtl.text -> ${bikeNumberCtl.text.toString() == ""}");
      if (bikeNumberCtl.text.toString() != "") {
        _getCurrentLocation();
      } else {
        alertServices.errorToast("Please enter valid Bike Number!");
      }
    }
  }

  bookAndStartMyRide() {
    FocusScope.of(context).unfocus();
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    _cancelTimer();
    var params = {
      "vehicleId": widget.data[0]['vehicleId'].toString(),
      "scanCode": bikeNumberCtl.text.toString(),
      "contact": mobile.toString(),
      "noOfHelmet": 1,
      "lattitude": currentLocation!.latitude.toString(),
      "longitude": currentLocation!.longitude.toString(),
    };
    print("params $params");
    bookingServices.startMyRide(params).then((r) {
      alertServices.hideLoading();
      print("Response -> ${jsonEncode(r)}");
      conditionCheck([r]);
    });
  }

  conditionCheck(List res2) {
    if (res2[0]['key'].toString() == "WALLET_ISSUE") {
      alertServices.balanceAlert(
          context, res2[0]['message'].toString(), [], "", []);
    } else if (res2[0]['key'].toString() != "null" &&
        res2[0]['message'].toString() != "null") {
      alertServices.vehicleAlert(context, res2[0]['message'].toString());
    } else {
      String rideId = res2[0]['rideId'].toString();
      if (rideId != "null") {
        Navigator.pushNamedAndRemoveUntil(
            context, "booking_success", arguments: rideId, (a) => false);
      } else {
        alertServices.errorToast("Something went wrong!");
      }
    }
  }

  void _cancelTimer() {
    if (countdownTimer?.isActive ?? false) {
      countdownTimer?.cancel();
    }
  }

  void _startCountdown() {
    // _cancelTimer();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (remainingSeconds == 30) {
          QrMobileVision.toggleFlash();
        }
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _cancelTimer();
          Navigator.pushReplacementNamed(context, "time_out",
              arguments: widget.data);
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    bikeNumberCtl.dispose();
    controller?.dispose();
    _cancelTimer();
    super.dispose();
  }

// _onQRViewCreated(String code) {
//   print("Code ---> $code");
//   if (code != "") {
//     QrMobileVision.stop();
//     String vId = widget.data[0]['vehicleId'].toString();
//     if (code.toString() == vId) {
//       setState(() {
//         bikeNumberCtl.text = code.toString();
//       });
//       // startMyRide();
//     } else {
//       alertServices.errorToast(
//           "Wrong vehicle! Scan the code of the assigned vehicle to end the ride");
//     }
//   }
// }
}
