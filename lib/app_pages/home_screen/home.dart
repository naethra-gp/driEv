import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../app_services/index.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_provider/location_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationService _locationService = LocationService();
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  String selfieUrl = "";
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  double distance = 20;
  String currentDistrict = "";
  String distanceText = "";

  // PREVIOUS VALUES
  AlertServices alertServices = AlertServices();
  CustomerService customerService = CustomerService();
  SecureStorage secureStorage = SecureStorage();
  VehicleService vehicleService = VehicleService();
  List customer = [];
  Map<String, dynamic> stationDetails = {};
  LatLng? stationLocation;
  BitmapDescriptor? customerMarker;
  BitmapDescriptor? stationMarker;
  final Set<Polyline> _polyLines = {};

  @override
  void initState() {
    getLocation();
    getCustomerDetails();
    _loadCustomIcons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            if (_currentPosition != null && stationLocation != null)
              GoogleMap(
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                compassEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                polylines: _polyLines,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('1'),
                    position: _currentPosition!,
                    icon: customerMarker ?? BitmapDescriptor.defaultMarker,
                  ),
                  Marker(
                    markerId: const MarkerId('2'),
                    position: stationLocation!,
                    icon: stationMarker ?? BitmapDescriptor.defaultMarker,
                  ),
                },
              ),
            Positioned(
              top: 10,
              left: 15,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "profile");
                    },
                    child: CachedNetworkImage(
                      width: 41,
                      height: 41,
                      imageUrl: selfieUrl,
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
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                currentDistrict,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, "wallet_summary");
                          },
                          child:
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 2,
                              color: const Color(0xffDEDEDE),
                            ),
                            const SizedBox(width: 5),
                            Image.asset(
                              "assets/img/wallet.png",
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 5),
                            if (customer.isNotEmpty)
                              Text(
                                "\u{20B9}${customer[0]['walletBalance']}",
                                style: TextStyle(
                                  fontSize: width / 30,
                                  fontWeight: FontWeight.bold,
                                  color: getColor(customer[0]['walletBalance']),
                                ),
                              ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        ),],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: height / 2,
              // top: 350,
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
                        const Text(
                          "How long is your dream ride?",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                SfSliderTheme(
                                  data: const SfSliderThemeData(
                                    tooltipBackgroundColor: AppColors.primary,
                                    thumbColor: Colors.transparent,
                                    thumbRadius: 20,
                                    activeDividerColor: Colors.white,
                                  ),
                                  child: Center(
                                    child: SfSlider(
                                      min: 10.0,
                                      max: 100.0,
                                      interval: 10,
                                      shouldAlwaysShowTooltip: false,
                                      stepSize: 10,
                                      thumbIcon: Image.asset(
                                        "assets/img/slider1.png",
                                        width: 16,
                                        height: 20,
                                      ),
                                      value: distance,
                                      inactiveColor: AppColors.primary.withOpacity(0.3),
                                      labelPlacement: LabelPlacement.onTicks,
                                      thumbShape: const SfThumbShape(),
                                      semanticFormatterCallback: (dynamic value) {
                                        return '$value km';
                                      },
                                      enableTooltip: true,
                                      showLabels: false,
                                      showDividers: true,
                                      showTicks: false,
                                      tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) {
                                        return "$formattedText km";
                                      },
                                      onChanged: (dynamic newValue) {
                                        setState(() {
                                          distance = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                /*Positioned(
                                  right: 0,  // Adjust this value to position the scooter image exactly at the end of the slider
                                  top: 10,   // Adjust this value to vertically center the image if necessary
                                  child: Image.asset(
                                    "assets/img/scooter.png",
                                    height: 20,
                                    width: 20,
                                  ),
                                ),*/
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('10 km',
                                      style: TextStyle(
                                          color: Color(0xff7B7B7B),
                                          fontWeight: FontWeight.bold)),
                                  Text('100 km',
                                      style: TextStyle(
                                          color: Color(0xff7B7B7B),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Preferred Category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (stationDetails.isNotEmpty) ...[
                          Wrap(
                            spacing: 10.0,
                            runSpacing: 5.0,
                            alignment: WrapAlignment.start,
                            children: [
                              for (int i = 0;
                                  i < stationDetails['plans'].length;
                                  i++) ...[
                                if (stationDetails['plans'][i] != null) ...[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      surfaceTintColor: Colors.white,
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      List list = [
                                        {
                                          'sId': stationDetails['stationId'],
                                          'sName':
                                              stationDetails['stationName'],
                                          'plan': stationDetails['plans'][i],
                                          'distanceText': distanceText,
                                          'distance': distance
                                              .toString()
                                              .replaceAll(".0", ""),
                                        },
                                      ];
                                      Navigator.pushNamed(
                                          context, "select_vehicle",
                                          arguments: {"params": list});
                                    },
                                    child: Text(
                                      stationDetails['plans'][i].toString(),
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ]
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  getLocation() async {
    try {
      Position position = await _locationService.determinePosition();
      Placemark place = await _locationService.getPlaceMark(position);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        currentDistrict = place.locality!;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadCustomIcons() async {
    stationMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/img/map_station_icon.png',
    );
    customerMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/img/map_user_icon.png',
    );
  }

  getColor(value) {
    if (value < 350) {
      return Colors.redAccent;
    } else {
      return AppColors.primary;
    }
  }

  double distanceBetween(LatLng latLng1, LatLng latLng2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((latLng2.latitude - latLng1.latitude) * p) / 2 +
        cos(latLng1.latitude * p) *
            cos(latLng2.latitude * p) *
            (1 - cos((latLng2.longitude - latLng1.longitude) * p)) /
            2;
    return 12742 * atan2(sqrt(a), sqrt(1 - a));
  }

  void _zoomToFitPositions() {
    if (_currentPosition != null && stationLocation != null) {
      double distance = distanceBetween(_currentPosition!, stationLocation!);
      double zoomLevel = 15.0 - (log(distance) / log(2));
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _currentPosition!.latitude < stationLocation!.latitude
              ? _currentPosition!.latitude
              : stationLocation!.latitude,
          _currentPosition!.longitude < stationLocation!.longitude
              ? _currentPosition!.longitude
              : stationLocation!.longitude,
        ),
        northeast: LatLng(
          _currentPosition!.latitude > stationLocation!.latitude
              ? _currentPosition!.latitude
              : stationLocation!.latitude,
          _currentPosition!.longitude > stationLocation!.longitude
              ? _currentPosition!.longitude
              : stationLocation!.longitude,
        ),
      );

      double padding = 50.0;
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );
      mapController.animateCamera(
        CameraUpdate.zoomTo(zoomLevel),
      );
    }
  }

  /// GETTING STATION DETAILS
  getCustomerDetails() {
    alertServices.showLoading("Getting user details...");
    String mobile = secureStorage.get("mobile");
    customerService.getCustomer(mobile.toString(), true).then((response) async {
      alertServices.hideLoading();
      if (response != null) {
        customer = [response];
        String station = customer[0]['registeredStation'].toString();
        print("customer --> ${jsonEncode(customer)}");
        if (station.isNotEmpty) {
          getPlansByStation(station);
        } else {
          gotoLogin();
        }
      } else {
        gotoLogin();
      }
    });
  }

  void _addPolyline(List<LatLng> polylineCoordinates) {
    print("_addPolyline");
    Polyline polyline = Polyline(
      polylineId: const PolylineId("polyLines"),
      color: Colors.black,
      points: polylineCoordinates,
      width: 2,
      patterns: [
        PatternItem.dash(15),
        PatternItem.gap(10),
      ],
    );
    if (mapController == null) {
      alertServices.errorToast('GoogleMapController is not yet initialized.');
      return;
    }
    setState(() {
      _polyLines.add(polyline);
    });
    alertServices.showLoading("Calculate distance...");
    Future.delayed(const Duration(seconds: 3), () {
      print("_zoomToFitPositions");
      alertServices.hideLoading();
      _zoomToFitPositions();
    });
  }

  void _fetchAndDisplayDirections(LatLng start, LatLng end) async {
    print("add polyline");
    List<LatLng> pc = await _locationService.getDirections(start, end);
    _addPolyline(pc);
  }

  getPlansByStation(String stationId) async {
    alertServices.showLoading("Getting station details...");
    vehicleService.getPlansByStation(stationId).then(
      (r) async {
        alertServices.hideLoading();
        stationDetails = r;
        double stationLat = stationDetails['lattitude'];
        double stationLon = stationDetails['longitude'];
        stationLocation = LatLng(stationLat, stationLon);
        alertServices.showLoading("Finding best route...");
        Future.delayed(const Duration(seconds: 5), () {
          print("delay logic");
          alertServices.hideLoading();
          if(_currentPosition != null) {
            double distance = _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              stationLat,
              stationLon,
            );
            setState(() {
              distanceText = distance.toStringAsFixed(2);
            });
            _fetchAndDisplayDirections(_currentPosition!, stationLocation!);
          }
          print("distance: ${distance.toStringAsFixed(2)}");

        });


      },
    );
  }

  gotoLogin() {
    secureStorage.save("mobile", "");
    secureStorage.save("isLogin", false);
    Navigator.pushNamedAndRemoveUntil(context, "login_page", (route) => false);
  }
}
