import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cron/cron.dart';
import 'package:driev/app_services/booking_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_common/need_help_widget.dart';

class OnRide extends StatefulWidget {
  final String rideId;
  const OnRide({
    super.key,
    required this.rideId,
  });

  @override
  State<OnRide> createState() => _OnRideState();
}

class _OnRideState extends State<OnRide> {
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();

  late GoogleMapController mapController;
  List rideDetails = [];
  LatLng? currentLocation;
  String currentDistrict = "";
  double availableBalance = 0;
  Timer? countdownTimer;
  String rideDuration = "00:00:00";
  bool popShown = false;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final Set<Marker> _markers = {};

  // TIMER
  late Timer _timer;
  late DateTime _startTime;
  Duration _elapsedTime = Duration.zero; // Initialize with zero duration

  @override
  void dispose() {
    if (countdownTimer != null) {
      countdownTimer!.cancel();
      countdownTimer = null;
    }
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("---- ON RIDE 1 ----");
    _getUserLocation();
    getBalance();
    getRideDetails(widget.rideId);
    setState(() {
      popShown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatDuration1(_elapsedTime);
    return SafeArea(
      child: PopScope(
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
        child: Scaffold(
          body: currentLocation == null
              ? const Center(child: Text("Loading Map..."))
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      markers: _markers,
                      zoomControlsEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation!,
                        zoom: 15,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 15,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: CachedNetworkImage(
                              width: 41,
                              height: 41,
                              imageUrl: "selfieUrl",
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/img/profile_logo.png",
                                width: 41,
                                height: 41,
                                fit: BoxFit.cover,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
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
                          ),
                          const SizedBox(width: 5),
                          Container(
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.location_on_outlined),
                                          Text(
                                            currentDistrict,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  height: 40,
                                  width: 2, // Adjust width as needed
                                  color: Colors
                                      .grey[300], // Adjust color as needed
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  "assets/img/wallet.png",
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(width: 5),
                                if (rideDetails.isNotEmpty)
                                  Text(
                                    "\u{20B9}${availableBalance.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: getColor(availableBalance),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (rideDetails.isNotEmpty) ...[
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Card(
                                        elevation: 0,
                                        color: const Color(0xFFF5F5F5),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 5, 15, 5),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  RichText(
                                                      text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'dri',
                                                        style: heading(
                                                            Colors.black),
                                                      ),
                                                      TextSpan(
                                                        text: 'EV ',
                                                        style: heading(
                                                            AppColors.primary),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            "${rideDetails[0]['planType'].toString()} ${rideDetails[0]['vehicleId'].toString()}",
                                                        style: heading(
                                                            Colors.black),
                                                      ),
                                                    ],
                                                  )),
                                                  const Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      needHelpAlert(context);
                                                    },
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Container(
                                                        width: 25,
                                                        height: 25,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.green,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .headset_mic_outlined,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      const Text(
                                                        "Estimated Range",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff626262),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${rideDetails[0]['estimatedRange'] ?? "0"} km",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Image.asset(
                                                    "assets/img/bike2.png",
                                                    height: 140,
                                                    width: 180,
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
                              const SizedBox(height: 25.0),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            '${rideDetails[0]['totalKm'].toString()} km',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
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
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.timer_outlined,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          'Ride Duration',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xff7E7E7E),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                        "scanCode": rideDetails[0]['scanCode']
                                            .toString(),
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
                                    'You can end your ride at the ${widget.rideId.toString().split("-").first} station only',
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
                    ],
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

  getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
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

  getBalance() async {
    alertServices.showLoading();
    String mobile = await secureStorage.get("mobile");
    bookingServices.getWalletBalance(mobile).then((r) {
      alertServices.hideLoading();
      double balance = r['balance'];
      print("bal -- ${balance.toStringAsFixed(2)}");
      setState(() {
        availableBalance = balance;
      });
    });
  }

  getRideDetails(String id) {
    bookingServices.getRideDetails(id).then((r) {
      if (r != null) {
        setState(() {
          rideDetails = [r];
          int milliseconds = rideDetails[0]['durationTime'];
          Duration duration = Duration(milliseconds: milliseconds);
          String formattedTime = _formatDuration1(duration);

          rideDuration = formattedTime;
          _startTime =
              DateTime.now().subtract(Duration(milliseconds: milliseconds));
          _startTimer();
        });
        if (r['status'].toString() == "On Ride") {
          var cron = Cron();
          cron.schedule(Schedule.parse('*/1 * * * *'), () async {
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

  String _formatDuration1(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  getRideDetails1(String id) {
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
            setState(() {
              popShown = true;
              alertServices.insufficientBalanceAlert(context, b.toString(),
                  r2["message"].toString(), [], widget.rideId, []);
            });
          }
        });
      });
    });
  }

  _getUserLocation() async {
    try {
      Position position = await GeolocatorPlatform.instance.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.reduced,
        ),
      );
      BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5, 15)),
        'assets/img/map_user_icon.png',
      );
      print("${position.latitude} ${position.longitude}");
      setState(() async {
        currentLocation = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLocation!,
            icon: customIcon,
          ),
        );
        List<Placemark> placeMark = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placeMark[0];
        currentDistrict = place.locality!;
      });
    } catch (e) {}
  }
}
