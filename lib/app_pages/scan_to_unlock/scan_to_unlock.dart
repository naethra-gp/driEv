import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

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

  @override
  void initState() {
    print("test -> ${widget.data}");
    _getCurrentLocation();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: height / 10),
                SizedBox(
                  width: 250,
                  height: 250,
                  child: QrCamera(
                    cameraDirection: CameraDirection.BACK,
                    onError: (context, error) => Text(
                      error.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    offscreenBuilder: (context) => const Text(
                      "Loading...",
                      style: TextStyle(color: Colors.white),
                    ),
                    notStartedBuilder: (context) {
                      return const Text("Loading the QR Code scanner");
                    },
                    qrCodeCallback: (String? code) {
                      setState(() {
                        bikeNumberCtl.text = code!;
                      });
                      print("code $code");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 4.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  "Wrap up your two-wheeled adventure!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "End your ride at ${widget.data[0]['campus']} by scanning the QR code or entering the bike number manually.",
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: bikeNumberCtl,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        maxLength: 7,
                        decoration: InputDecoration(
                          hintText: 'Enter Bike Number',
                          counterText: "",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        onChanged: (value) {
                          if (value.toString().length == 7) {
                            startMyRide();
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 60,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: IconButton(
                        icon: Image.asset(
                          "assets/img/flash_on.png",
                          height: 19,
                          width: 9,
                        ),
                        onPressed: () {
                          QrCamera.toggleFlash();
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
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
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
    });
    print("_locationMessage $_locationMessage");
  }

  startMyRide() {
    String mobile = secureStorage.get("mobile");
    print("Vid ${widget.data[0]['vehicleId'].toString()}");
    if (widget.data[0]['vehicleId'].toString() != "null") {
      if (currentLocation != null) {
        alertServices.showLoading();
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
          print("Resposne: $r");
          if (r != null) {
            String rideId = r['rideId'].toString();
            Navigator.pushNamed(context, "booking_success", arguments: rideId);
          }
        });
      } else {
        alertServices.errorToast("Location Invalid!");
      }
    } else {
      alertServices.errorToast("Invalid Vehicle ID!");
    }
  }

  submitBikeNUmber() {
    alertServices.showLoading();
    bookingServices.getRideEndPin("ITER-906").then((r) {
      alertServices.hideLoading();
      print("Resposne: $r");
      if (r != null) {
        String stopPing = r['stopPing'].toString();
        shopOTP(stopPing);
        timer = Timer.periodic(
          const Duration(seconds: 15),
          (Timer t) => startWatching(stopPing),
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
        if (rideId.toString() == "ITER-906") {
          Navigator.pushNamed(context, "home");
        }
        print("rideId $totalRideDuration");
      }
    });
  }
}
