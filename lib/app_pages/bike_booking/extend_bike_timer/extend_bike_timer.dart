import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app_services/index.dart';
import '../../../app_storages/secure_storage.dart';
import '../../../app_utils/app_loading/alert_services.dart';
import '../../app_common/need_help_widget.dart';
import 'widget/timer_button_widget.dart';

class ExtendBikeTimer extends StatefulWidget {
  final List blockRide;
  const ExtendBikeTimer({super.key, required this.blockRide});

  @override
  State<ExtendBikeTimer> createState() => _ExtendBikeTimerState();
}

class _ExtendBikeTimerState extends State<ExtendBikeTimer> {
  late GoogleMapController mapController;
  String _locationMessage = "";
  String currentLocation = "";
  double availableBalance = 0;
  LatLng? currentLocation1;
  final Set<Marker> _markers = {};
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();

  // TIMER VARIABLES
  String formattedMinutes = "";
  String formattedSeconds = "";
  Timer? countdownTimer;
  int _start = 0;
  late Timer _timer;
  bool enableChasingTime = false;
  List data = [];

  @override
  void initState() {
    print("EX: ${widget.blockRide}");
    super.initState();
    debugPrint("--- EXTEND BLOCK TIMER ---");
    getBalance();
    getLocation();
    setState(() {
      data = widget.blockRide;
    });
    // getBlockDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
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
                      bottomSheet(context);
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
                              // shape: BoxShape.circle,
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
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, "wallet_summary");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      "\u{20B9} $availableBalance",
                                      style: TextStyle(
                                        fontSize: width / 30,
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
                      ],
                    ),
                  ),
                ],
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

  bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black45,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return PopScope(
          canPop: true,
          child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      color: const Color(0xffF5F5F5),
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
                                      style: heading(Colors.black),
                                    ),
                                    TextSpan(
                                      text: 'EV ',
                                      style: heading(AppColors.primary),
                                    ),
                                    TextSpan(
                                      text: "${data[0]['planType'].toString()} ${data[0]['vehicleId'].toString()}",
                                      // "${rideDetails[0]['planType'].toString()}-${rideDetails[0]['vehicleId'].toString()}",
                                      // '${fd[0]['planType']}-${fd[0]['vehicleId']}',
                                      style: heading(Colors.black),
                                    ),
                                  ],
                                )),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    needHelpAlert(context);
                                  },
                                  icon: Align(
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
                                const Column(
                                  children: <Widget>[
                                    Text(
                                      "Estimated Range",
                                      style: TextStyle(
                                        color: Color(0xff626262),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "45~34 KM",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  "assets/img/bike2.png",
                                  height: 150,
                                  width: 200,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 5,
                      endIndent: 5,
                    ),
                    const SizedBox(height: 16),
                    TimerButtonWidget(
                      data: data,
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 50,
                    //   child: ElevatedButton(
                    //     onPressed: () {},
                    //     style: ElevatedButton.styleFrom(
                    //       textStyle: const TextStyle(
                    //         color: Colors.black,
                    //         fontWeight: FontWeight.w500,
                    //         fontSize: 14,
                    //       ),
                    //       elevation: 0,
                    //       foregroundColor: Colors.white,
                    //       backgroundColor: enableChasingTime
                    //           ? const Color(0xffFB8F80)
                    //           : const Color(0xffE1FFE6),
                    //       side: const BorderSide(
                    //           color: Color(0xffE1FFE6), width: 0),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(50),
                    //       ),
                    //     ),
                    //     child: Text(
                    //       "$formattedMinutes:$formattedSeconds Minute to Ride Time!",
                    //       // "$_formattedTime Minute to Ride Time!",
                    //       style: TextStyle(
                    //           // color: enableChasingTime
                    //           //     ? Colors.white
                    //           //     : AppColors.primary,
                    //           fontSize: 14,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 25),
                    SizedBox(
                      height: 50,
                      child: AppButtonWidget(
                        title: "More",
                        onPressed: () {
                          List params = [
                            {
                              "campus": data[0]['stationName'].toString(),
                              "distance": "20",
                              "vehicleId": data[0]['vehicleId'].toString(),
                            }
                          ];
                          Navigator.pushNamed(context, "bike_fare_details", arguments: {"query": params});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            "You can end your ride at the ${data[0]['stationName'].toString()} station only.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  // TO GET USERS CURRENT LOCATION
  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
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
          _locationMessage = "Location permissions are denied";
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
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/img/map_user_icon.png',
    );

    _locationMessage =
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}";

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
    print("_locationMessage $_locationMessage");
    print("currentDistrict $currentLocation");
    setState(() {});
  }

  // GET USER WALLET BALANCE
  getBalance() async {
    alertServices.showLoading();
    String mobile = await secureStorage.get("mobile");
    bookingServices.getWalletBalance(mobile).then((r) {
      alertServices.hideLoading();
      double balance = r['balance'];
      availableBalance = balance;
      setState(() {});
    });
  }

  getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }
}
