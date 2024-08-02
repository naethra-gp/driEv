import 'dart:async';
import 'dart:convert';
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
import '../home_screen/widget/home_top_widget.dart';
import 'widget/on_ride_bottom_sheet.dart';
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
  List customer = [];

  @override
  void initState() {
    debugPrint("---- ON RIDE PAGE ----");
    super.initState();
    getCustomerDetails();
    getLocation();
    getRideDetails(widget.rideId);
  }

  CustomerService customerService = CustomerService();

  getCustomerDetails() {
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
          bottomSheet(context, widget, rideDetails);
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
      if(!mounted) return;
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
                    if (customer.isNotEmpty)
                      HomeTopWidget(
                        imgUrl: customer[0]['selfi'],
                        location: currentLocation.toString(),
                        balance: double.parse(
                            customer[0]['walletBalance'].toString()),
                      ),
                  ],
                ),
        ),
      ),
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
  bottomSheet(BuildContext context, widget, rideDetails) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black45,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return OnRideBottomSheet(
          widget: widget,
          rideDetails: rideDetails,
        );
      },
    );
  }
}
