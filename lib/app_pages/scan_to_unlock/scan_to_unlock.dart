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
  // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String qr = "";

  int remainingSeconds = 30;
  Timer? countdownTimer;

  @override
  void initState() {
    print("Data: ${widget.data}");
    _startCountdown();
    super.initState();
  }

  void _cancelTimer() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
  }

  /* @override
  void reassemble() {
    print(" --- reassemble --- ");
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }*/

  void _startCountdown() {
    _cancelTimer();
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

  void _onQRViewCreated(String code) {
    setState(() {
      qr = code;
      bikeNumberCtl.text = qr.toString();
      print("result-> $qr");
      if (qr != "") {
        print("---- Start ---- ");
        QrMobileVision.stop();
        String vId = widget.data[0]['vehicleId'].toString().padLeft(4, '0');
        bool checkVehicle =
            bikeNumberCtl.text.toString().contains(vId.toString());
        if (!checkVehicle) {
          alertServices.errorToast(
              "Wrong vehicle!!! Scan the code of the assigned vehicle to end the ride");
        } else {
          startMyRide();
        }
      }
    });
    print("result $qr");
  }

  @override
  Widget build(BuildContext context) {
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
                child: QrCamera(
                  onError: (context, error) => Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.red),
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
            Text(
              "End your ride at ${widget.data[0]['campus'].toString()} Campus 6 by scanning the QR \n code or entering the bike number manually.",
              style: const TextStyle(
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
                    maxLength: 7,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      if (value.toString().length == 7) {
                        String vId = widget.data[0]['vehicleId']
                            .toString()
                            .padLeft(4, '0');
                        bool checkVehicle =
                            value.toString().contains(vId.toString());
                        if (!checkVehicle) {
                          alertServices.errorToast(
                              "Wrong vehicle!!! Scan the code of the assigned vehicle to end the ride");
                        } else {
                          startMyRide();
                        }
                      }
                      print("Value: $value");
                    },
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
                    onPressed: () async {
                      await QrMobileVision.toggleFlash();
                    },
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
    _cancelTimer();
    if (widget.data[0]['vehicleId'].toString() != "null") {
      print("bikeNumberCtl.text -> ${bikeNumberCtl.text}");
      print("bikeNumberCtl.text -> ${bikeNumberCtl.text.toString() == ""}");
      if (bikeNumberCtl.text.toString() != "") {
        _getCurrentLocation();
      } else {
        alertServices.errorToast("Please enter valid Bike Number!");
      }
    } else {
      alertServices.errorToast("Invalid Vehicle ID!");
    }
  }

  bookAndStartMyRide() {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    var params = {
      "vehicleId": widget.data[0]['vehicleId'].toString(),
      "scanCode": bikeNumberCtl.text.toString(),
      "contact": mobile.toString(),
      "noOfHelmet": 1,
      "lattitude": currentLocation!.latitude.toString(),
      "longitude": currentLocation!.longitude.toString(),
    };
    print("params ${jsonEncode(params)}");
    bookingServices.startMyRide(params).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        String rideId = r['rideId'].toString();
        Navigator.pushNamed(context, "booking_success", arguments: rideId);
      }
    });
  }
}
