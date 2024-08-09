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
  CustomerService customerService = CustomerService();

  // TIMER VARIABLES
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
    // getBalance();
    getLocation();
    getCustomerDetails();

    setState(() {
      data = widget.blockRide;
    });
  }

  getCustomerDetails() {
    alertServices.showLoading("Getting user details...");
    String mobile = secureStorage.get("mobile");
    customerService.getCustomer(mobile.toString(), true).then((response) async {
      alertServices.hideLoading();
      if (response != null) {
        customer = [response];
        print("customer $customer");
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
                  if (customer.isNotEmpty) ...[
                    HomeTopWidget(
                      imgUrl: customer[0]['selfi'],
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
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
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
                    // height: MediaQuery.of(context).size.height / 3,
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
                        print("More: ${jsonEncode(params)}");
                        // Navigator.pushNamed(context, "bike_fare_details",
                        //     arguments: {"query": params});
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
      const ImageConfiguration(size: Size(20, 25)),
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
  // getBalance() async {
  //   alertServices.showLoading();
  //   String mobile = await secureStorage.get("mobile");
  //   bookingServices.getWalletBalance(mobile).then((r) {
  //     alertServices.hideLoading();
  //     double balance = r['balance'];
  //     availableBalance = balance;
  //     setState(() {});
  //   });
  // }

  getColor(double value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }
}
