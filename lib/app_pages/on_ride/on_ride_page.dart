import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import '../app_common/need_help_widget.dart';
import 'widget/on_ride_timer_widget.dart';

class OnRidePage extends StatefulWidget {
  final String rideId;

  const OnRidePage({
    super.key,
    required this.rideId,
  });

  @override
  State<OnRidePage> createState() => _OnRidePageState();
}

class _OnRidePageState extends State<OnRidePage> {
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();

  /// MAP VARIABLES
  late GoogleMapController mapController;
  String currentLocation = "";
  double currentBalance = 0;
  LatLng? currentLocation1;
  final Set<Marker> _markers = {};

  // ON RIDE
  List rideDetails = [];
  String rideDuration = "00:00:00";

  // TIMER
  late Timer _timer;
  late DateTime _startTime;
  Duration _elapsedTime = Duration.zero;
  bool popShown = false;

  @override
  void initState() {
    print("---- ON RIDE PAGE ----");
    super.initState();
    getLocation();
    getBalance();
    getRideDetails(widget.rideId);
  }

  getRideDetails(String id) {
    print("Ride ID: $id");
    bookingServices.getRideDetails(id).then((r) {
      if (r != null) {
        setState(() {
          rideDetails = [r];
          int milliseconds = rideDetails[0]['durationTime'];

          _startTime =
              DateTime.now().subtract(Duration(milliseconds: milliseconds));
          _startTimer();
          bottomSheet(context);
        });
        if (r['status'].toString() == "On Ride") {
          var cron = Cron();
          cron.schedule(Schedule.parse('*/2 * * * *'), () async {
            getRideDetails1(widget.rideId);
          });
        }
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateElapsedTime();
      });
    });
    _calculateElapsedTime();
  }

  void _calculateElapsedTime() {
    DateTime now = DateTime.now();
    _elapsedTime = now.difference(_startTime);
  }

  getRideDetails1(String id) {
    print("Calling api --- getRideDetails1");
    String rideId = widget.rideId.toString();
    String mobile = secureStorage.get("mobile");
    bookingServices.getRideDetails(id).then((r) {
      if (r != null) {
        setState(() {
          rideDetails = [r];
        });
      }
      bookingServices.getWalletBalance(mobile).then((r) {
        double b = r['balance'];
        double c = rideDetails[0]["payableAmount"];
        bookingServices.getRideEndPin(rideId).then((r2) {
          alertServices.hideLoading();
          if (!popShown && b < c) {
            // setState(() {
            popShown = true;
            alertServices.insufficientBalanceAlert(
              context,
              currentBalance.toString(),
              r2["message"],
              [],
              widget.rideId,
              [],
            );
            // });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PopScope(
      child: SafeArea(
        child: Scaffold(
          body: currentLocation1 == null
              ? const Center(
                  child: Text("Loading map..."),
                )
              : Stack(
                  children: <Widget>[
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      markers: _markers,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation1!,
                        zoom: 15,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            width: 41,
                            height: 41,
                            imageUrl: "selfieUrl",
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/img/profile_logo.png",
                              width: 41,
                              height: 41,
                              fit: BoxFit.cover,
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 260,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xffF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xffD9D9D9),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    const Icon(Icons.location_on_outlined),
                                    const SizedBox(width: 5),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        currentLocation,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 2,
                                        color: const Color(0xffDEDEDE),
                                      ),
                                      const SizedBox(width: 10),
                                      Image.asset(
                                        "assets/img/wallet.png",
                                        height: 25,
                                        width: 25,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "\u{20B9} $currentBalance",
                                        style: TextStyle(
                                          fontSize: width / 30,
                                          fontWeight: FontWeight.bold,
                                          color: getColor(currentBalance),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  TextStyle heading(Color color) {
    return TextStyle(
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
      color: color,
      fontSize: 18,
    );
  }

  // GET USER WALLET BALANCE
  getBalance() async {
    alertServices.showLoading();
    String mobile = await secureStorage.get("mobile");
    bookingServices.getWalletBalance(mobile).then((r) {
      alertServices.hideLoading();
      double balance = r['balance'];
      setState(() {
        currentBalance = balance;
      });
    });
  }

  getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }

  // TO GET USERS CURRENT LOCATION
  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      alertServices.errorToast("Location services are disabled.");
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        alertServices.errorToast("Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      alertServices.errorToast("Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/img/map_user_icon.png',
    );
    List<Placemark> placeMark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placeMark[0];
    currentLocation = place.locality!;
    currentLocation1 = LatLng(position.latitude, position.longitude);
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLocation1!,
        icon: customIcon,
      ),
    );
    setState(() {});
  }

  // ON RIDE - MAIN SCREEN
  bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black45,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
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
                top: Radius.circular(25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    surfaceTintColor: Colors.transparent,
                    color: const Color(0xFFF5F5F5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            color: const Color(0xFFF5F5F5),
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
                                              text: 'dri',
                                              style: heading(Colors.black)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      Image.asset(
                                        "assets/img/bike2.png",
                                        height: 140,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                  const SizedBox(height: 20.0),
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
                  const SizedBox(height: 5.0),
                ],
              ),
            ),
          ),
        );
      },
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
