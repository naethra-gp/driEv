import 'dart:async';
import 'dart:io';
import 'package:driev/app_config/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool flashOn = false;
  bool hasShownPopup = false;

  @override
  void initState() {
    debugPrint(" --- PAGE: SCAN TO UNLOCK --- ");
    print("SCAN TO UNLOCK Data: ${widget.data}");
    _startCountdown();
    super.initState();
  }

  checkBikeNumber(String code) {
    if (hasShownPopup) {
      return;
    }
    String vId = widget.data[0]['vehicleId'].toString();
    if (code.toString() == vId) {
      QrMobileVision.stop();
      setState(() {
        bikeNumberCtl.text = code.toString();
      });
      startMyRide();
    } else {
      setState(() {
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

  clickBackButton() {
    Navigator.pushReplacementNamed(context, "bike_fare_details",
        arguments: {"query": widget.data[0]['data']});
  }

  /// NEW PLUGIN
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        clickBackButton();
      },
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
                        color: AppColors.primary,
                      ),
                      width: 30,
                      height: 30,
                      child: Icon(
                        flashOn ? Icons.flash_off : Icons.flash_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                          onError: (context, error) => const Center(
                            child: Text(
                              "There may be an error with your camera. Try scanning again.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          cameraDirection: CameraDirection.BACK,
                          qrCodeCallback: (code) {
                            if (code != null) {
                              setState(() {
                                bikeNumberCtl.text = code.toString();
                                checkBikeNumber(code);
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: Platform.isAndroid
                              ? TextInputType.phone
                              : const TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: false,
                                ),
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
            Positioned(
              top: 40,
              left: 10,
              child: Container(
                  child: IconButton(
                icon: Image.asset(Constants.backButton),
                onPressed: () {
                  clickBackButton();
                  // Navigator.pop(context);
                },
              )),
            )
          ],
        ),
      ),
    );
  }

  submitButtonClicked() {
    // startMyRide();
    FocusScope.of(context).unfocus();
    String bike = bikeNumberCtl.text.toString();
    if (bike.isNotEmpty && bike.length <= 6) {
      String vId = widget.data[0]['vehicleId'].toString();
      if (bike == vId) {
        startMyRide();
      } else {
        String msg = "Entered/Scanned Vehicle is invalid";
        alertServices.errorToast(msg);
      }
    }
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
  }

  startMyRide() {
    if (widget.data[0]['vehicleId'].toString() != "null") {
      if (bikeNumberCtl.text.toString() != "") {
        _getCurrentLocation();
      } else {
        alertServices.errorToast("Please enter valid Bike Number!");
      }
    }
  }

  bookAndStartMyRide() {
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
    bookingServices.startMyRide(params).then((r) {
      alertServices.hideLoading();
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
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
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
}
