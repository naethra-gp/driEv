import 'dart:async';
import 'package:driev/app_services/booking_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:qr_mobile_vision/qr_mobile_vision.dart';
import '../../app_utils/app_loading/alert_services.dart';

class EndRideScanner extends StatefulWidget {
  final List rideId;
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
  Barcode? result;
  QRViewController? controller;
  String campus = '';
  String rideId = '';
  String qr="";
  int remainingSeconds = 30;
  Timer? countdownTimer;

  /// TIMER 30S
  void _startCountdown() {
    _cancelTimer();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if(remainingSeconds==20){
          QrMobileVision.toggleFlash();
        }
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          _cancelTimer();
          Navigator.pushReplacementNamed(context, "end_time_out", arguments: widget.rideId);
        }
      });
    });
  }

  void _cancelTimer() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
  }
  @override
  void initState() {
    List<String> a = widget.rideId[0]['rideId'].toString().split("-");
    setState(() {
      campus = a[0];
      rideId = widget.rideId[0]['rideId'].toString();
    });
    _startCountdown();
    super.initState();
  }
  @override
  deactivate() {
    super.deactivate();
    QrMobileVision.stop();
  }

  @override
  /*void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }*/
  @override
  void dispose() {
    timer?.cancel();
    bikeNumberCtl.dispose();
    controller?.dispose();
    super.dispose();
  }
  void _onQRViewCreated(String code) {
    //this.controller = controller;
  //  controller.scannedDataStream.listen((Barcode scanData) {
      setState(() {
        qr = code;
        bikeNumberCtl.text = qr.toString();
        print("result-> $qr");
        if(qr != "") {
          QrMobileVision.stop();
          checkBikeNumber(qr.toString());

          // submitBikeNUmber();
        }
      });
      print("result $qr");
  //  });
  }
  checkBikeNumber(String bikeNo) {
    String bike = widget.rideId[0]['scanCode'].toString();
    if(bike != bikeNo) {
      setState(() {
        bikeNumberCtl.text = "";
      });
      alertServices.errorToast("Wrong vehicle!!! Scan the code of the selected vehicle");
     // controller?.resumeCamera();
    } else {
      /// BIKE NUMBER VALID STATE
      submitBikeNUmber();
    }
    // alertServices.showLoading();
  }
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70,),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the radius as needed
              child: Container(
                width: 150, // adjust the size as needed
                height: 150,
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: AppColors.primary,
                    borderRadius: 5,
                    borderWidth: 5,
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
            const SizedBox(height: 30),
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
                    textAlign: TextAlign.left,
                    onChanged: (value){
                  /*    if(value.toString().length == 7) {
                        checkBikeNumber(value);
                        // submitBikeNUmber();
                      }*/
                    },
                    maxLength: 6,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintStyle:TextStyle(fontSize:12,color:Color(0Xff7A7A7A)),
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
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,),
                    onPressed: () async {
                      if (bikeNumberCtl.text.toString().isNotEmpty && bikeNumberCtl.text.toString().length<=6) {
                        checkBikeNumber(bikeNumberCtl.text.toString());
                      } else{
                        alertServices.errorToast("Enter the Bike Number or Scan the QR Code");
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
    );
  }

  submitBikeNUmber() {
    print("VID: ${bikeNumberCtl.text}");
    alertServices.showLoading();
    _cancelTimer();
    bookingServices.getRideEndPin(rideId).then((r) {
      alertServices.hideLoading();
      print("Resposne: $r");
      if (r != null) {
        String stopPing = r['stopPing'].toString();
        showOtp(stopPing);
        String rideID = r['rideID'].toString();
        timer = Timer.periodic(
          const Duration(seconds: 15),
          (Timer t) => startWatching(rideID),
        );
      }
    });
  }

  showOtp(String otp) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: height / 1.8,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: height / 6.6 - 100,
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
                top: height / 8 - 100,
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
                        color: Color(0xff6F6F6F),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      otp,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
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
          rideDoneAlert([r]);
          timer?.cancel();
        }
        print("rideId $totalRideDuration");
      }
    });
  }

  rideDoneAlert(List res) {
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
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'last trip covering',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: ' ${res[0]['lastRideDistance']} kilometers!',
                              style: const TextStyle(
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
                                    arguments: rideId,
                                    (route) => false);
                              },
                              child: const Text("View Ride Summary"),
                            ),
                          ),
                          const SizedBox(width: 25),
                          SizedBox(
                            // width: width / 2,
                            child: ElevatedButton(

                              onPressed: () {
                                Navigator.pushNamed(context, "rate_this_raid",arguments: rideId);
                              },
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
