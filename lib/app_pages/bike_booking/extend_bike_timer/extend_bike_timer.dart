import 'dart:async';
import 'dart:convert';
import 'package:driev/app_themes/app_colors.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app_services/index.dart';
import '../../../app_storages/secure_storage.dart';
import '../../../app_utils/app_loading/alert_services.dart';
import '../../home_screen/widget/home_top_widget.dart';
import 'bike_card_widget.dart';
import 'widget/timer_button_widget.dart';

/// A widget that displays the bike extension timer screen with map and booking details
class ExtendBikeTimer extends StatefulWidget {
  final List blockRide;
  const ExtendBikeTimer({super.key, required this.blockRide});

  @override
  State<ExtendBikeTimer> createState() => _ExtendBikeTimerState();
}

class _ExtendBikeTimerState extends State<ExtendBikeTimer> {
  late GoogleMapController mapController;
  String currentLocation = "";
  double availableBalance = 0;
  LatLng? currentLocation1;
  final Set<Marker> _markers = {};
  AlertServices alertServices = AlertServices();
  BookingServices bookingServices = BookingServices();
  SecureStorage secureStorage = SecureStorage();
  CustomerService customerService = CustomerService();

  // Timer state variables
  String formattedMinutes = "";
  String formattedSeconds = "";
  Timer? countdownTimer;
  bool enableChasingTime = false;
  List data = [];
  List customer = [];

  @override
  void initState() {
    super.initState();
    debugPrint("--- EXTEND BLOCK TIMER ---");
    getLocation();
    getCustomerDetails();

    setState(() {
      data = widget.blockRide;
    });
  }

  /// Fetches and updates customer details from the server
  Future<void> getCustomerDetails() async {
    alertServices.showLoading("Getting user details...");
    String mobile = secureStorage.get("mobile");
    customerService.getCustomer(mobile.toString(), true).then((response) async {
      alertServices.hideLoading();
      if (response != null) {
        customer = [response];
      } else {
        alertServices.errorToast("Customer details not found!");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: currentLocation1 == null
            ? const Center(
                child: Text("Loading map..."),
              )
            : Stack(
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.6,
                    child: GoogleMap(
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
                  ),
                  if (customer.isNotEmpty) ...[
                    HomeTopWidget(
                      imgUrl: customer[0]['selfi'] == null
                          ? "assets/img/profile_logo.png"
                          : customer[0]['selfi'].toString(),
                      location: currentLocation.toString(),
                      balance:
                          double.parse(customer[0]['walletBalance'].toString()),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  /// Shows the bottom sheet with bike details and timer controls
  Future<dynamic> bottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black45,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BikeCardWidget(data: data),
                  const Divider(indent: 5, endIndent: 5),
                  const SizedBox(height: 16),
                  TimerButtonWidget(data: data),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 45,
                    child: AppButtonWidget(
                      title: "More",
                      onPressed: () {
                        List params = [
                          {
                            "campus": data[0]['stationName'].toString(),
                            "distance": data[0]['distanceRange'].toString(),
                            "vehicleId": data[0]['vehicleId'].toString(),
                            "via": "api",
                            "data": data
                          }
                        ];
                        debugPrint("More: ${jsonEncode(params)}");
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "bike_fare_details",
                          arguments: {"query": params},
                          (route) => false,
                        );
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
                        const Icon(Icons.info_outline,
                            color: Colors.red, size: 20),
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Fetches and updates the user's current location
  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Error: Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Error: Location permissions are disabled.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Error: Location permissions are permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    BitmapDescriptor customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 25)),
      'assets/img/map_user_icon.png',
    );
    debugPrint("Location: ${position.latitude},${position.longitude}");
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

  /// Returns color based on the given value
  /// Returns red for values less than 350, otherwise returns primary color
  Color getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }
}
