import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:driev/app_config/app_config.dart';
import 'package:driev/app_pages/home_screen/widget/home_top_widget.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import '../../app_utils/app_provider/location_service.dart';
import '../../app_utils/app_widgets/app_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AlertServices alertServices = AlertServices();
  CustomerService customerService = CustomerService();
  SecureStorage secureStorage = SecureStorage();
  VehicleService vehicleService = VehicleService();
  final LocationService _locationService = LocationService();

  // GOOGLE MAP
  String location = "";
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(20.2993002, 85.8173442);
  LatLng? _currentPosition;
  BitmapDescriptor? customerMarker;
  BitmapDescriptor? stationMarker;
  final Set<Polyline> _polyLines = {};

  //
  List customer = [];
  Map<String, dynamic> stationDetails = {};
  LatLng? stationLocation;
  List categoryList = [];
  String selectedPlan = "";
  List vehicleList = [];
  List filterVehicleList = [];
  List closedVehicleList = [];
  String selfieUrl = "";
  double distance = 20;
  String? currentDistrict = "";
  String? distanceText = "";
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    printPageTitle(AppTitles.homeScreen);
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!_mounted) return;
    await getCustomerDetails();
  }

  @override
  void dispose() {
    _mounted = false;
    mapController?.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted) {
      setState(fn);
    }
  }

  getUserLocation() async {
    if (!_mounted) return;
    Position position = await _locationService.determinePosition();
    Placemark place = await _locationService.getPlaceMark(position);
    location = place.locality.toString();
    _currentPosition = LatLng(position.latitude, position.longitude);
    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
    _safeSetState(() {});
  }

  Future<void> _loadCustomIcons() async {
    if (!_mounted) return;
    stationMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 30)),
      'assets/img/map_station_icon.png',
    );
    customerMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 25)),
      'assets/img/map_user_icon.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = 1.1;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            if (_currentPosition != null && stationLocation != null) ...[
              SizedBox(
                height: screenHeight,
                child: GoogleMap(
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  compassEnabled: false,
                  mapType: MapType.normal,
                  minMaxZoomPreference: getZoomControl(),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  polylines: _polyLines,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    // tilt: 59.440717697143555,
                    zoom: 20.5,
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
              ),
            ] else ...[
              GoogleMap(
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                compassEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 13.5,
                ),
              ),
            ],
            if (customer.isNotEmpty)
              HomeTopWidget(
                imgUrl: customer[0]['selfi'].toString(),
                location: location.toString(),
                balance: double.parse(customer[0]['walletBalance'].toString()),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.45,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 25, 10, 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How long is your dream ride?",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15 * textScaleFactor,
                        ),
                      ),
                      const SizedBox(height: 25),
                      sliderWidget(),
                      const SizedBox(height: 25),
                      Text(
                        "Select a category:",
                        style: TextStyle(
                          fontSize: 15 * textScaleFactor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (stationDetails.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Flexible(
                          child: Wrap(
                            spacing: 15.0,
                            runSpacing: 2.0,
                            alignment: WrapAlignment.start,
                            children: [
                              if (stationDetails['plans'].length == 0) ...[
                                const SizedBox(height: 16),
                                const Center(
                                  child: Text(
                                    "Bummer! No bikes available right now. Check back later.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                              for (int i = 0;
                                  i < stationDetails['plans'].length;
                                  i++) ...[
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    surfaceTintColor: Colors.white,
                                    foregroundColor: Colors.white,
                                    backgroundColor: categoryList[i]
                                        ? Colors.white
                                        : const Color(0xffF5F5F5),
                                    side: BorderSide(
                                      color: categoryList[i]
                                          ? const Color(0xff3DB54A)
                                          : const Color(0xffE1E1E1),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      categoryList = categoryList
                                          .map((e) => e = false)
                                          .toList();
                                      categoryList[i] = true;
                                      selectedPlan =
                                          stationDetails['plans'][i].toString();
                                    });
                                  },
                                  child: Text(
                                    stationDetails['plans'][i].toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12 * textScaleFactor,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.all(0),
                              width: double.infinity,
                              child: buttonWidget(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addPolyline(List<LatLng> polylineCoordinates) {
    if (!_mounted) return;
    debugPrint("--- add Polyline ---");
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
    _safeSetState(() {
      _polyLines.add(polyline);
    });
    if (Platform.isAndroid) {
      _zoomToFitPositions();
    }
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
      mapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
      mapController?.animateCamera(CameraUpdate.zoomTo(zoomLevel));
      alertServices.hideLoading();
    } else {
      alertServices.errorToast("User Location/Station Location is missing!");
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

  Future<void> _fetchAndDisplayDirections(LatLng start, LatLng end) async {
    if (!_mounted) return;
    debugPrint(" --- FETCH AND DISPLAY DIRECTIONS ---");

    // Platform-specific coordinate validation
    if (Platform.isAndroid || Platform.isIOS) {
      // Validate coordinates are within reasonable bounds
      if (start.latitude < -90 ||
          start.latitude > 90 ||
          start.longitude < -180 ||
          start.longitude > 180 ||
          end.latitude < -90 ||
          end.latitude > 90 ||
          end.longitude < -180 ||
          end.longitude > 180) {
        debugPrint("Coordinates out of valid range");
        return;
      }

      // Check for zero or near-zero coordinates
      if (start.latitude.abs() < 0.000001 ||
          start.longitude.abs() < 0.000001 ||
          end.latitude.abs() < 0.000001 ||
          end.longitude.abs() < 0.000001) {
        debugPrint("Invalid coordinates detected (too close to zero)");
        return;
      }

      // Check if coordinates are too far apart
      double distance = distanceBetween(start, end);
      if (distance > 1000) {
        // 1000 km threshold
        debugPrint("Coordinates too far apart: $distance km");
        _safeSetState(() {
          distanceText = null;
        });
        return;
      }
    }

    List<LatLng> pc = await _locationService.getDirections(start, end);
    if (pc.isEmpty) {
      debugPrint("No route found between points");
      _safeSetState(() {
        distanceText = null;
      });
      return;
    }

    // Platform-specific polyline handling
    if (Platform.isAndroid) {
      _addPolyline(pc);
      _zoomToFitPositions();
    } else if (Platform.isIOS) {
      _addPolyline(pc);
      // iOS might need different zoom handling
      _zoomToFitPositions();
    }
  }

  /// GETTING STATION DETAILS
  Future<void> getCustomerDetails() async {
    if (!_mounted) return;
    alertServices.showLoading("Getting user details...");
    String mobile = secureStorage.get("mobile");
    final response = await customerService.getCustomer(mobile.toString(), true);
    alertServices.hideLoading();

    if (!_mounted) return;

    if (response != null) {
      _safeSetState(() {
        customer = [response];
      });
      debugPrint("Customer Details -> ${jsonEncode(customer)}");
      String station = customer[0]['registeredStation'].toString();
      String kyc = customer[0]['kycStatus'] ?? "";
      String block = customer[0]['blockStatus'] ?? "";
      String custType = customer[0]['custType'] ?? "";
      String status = customer[0]['accountStatus'] ?? "";

      if (!_mounted) return;

      if (custType == "Subscription") {
        alertServices.subscriptionAlert(context, "");
        return;
      }
      if (status == "N") {
        alertServices.deleteUserAlert(
            context, customer[0]['message'].toString(), null);
        return;
      }
      if (block == "Y") {
        alertServices.blockedKycAlert(
          context,
          customer[0]['comment'].toString(),
        );
        return;
      } else {
        if (kyc == "") {
          alertServices.holdKycAlert(context);
          return;
        } else if (kyc == "N") {
          alertServices.rejectKycAlert(context);
          return;
        } else {
          if (station.isNotEmpty) {
            await getUserLocation();
            if (!_mounted) return;
            await _loadCustomIcons();
            await getPlansByStation(station);
          } else {
            alertServices.errorToast("Registered Station is missing.");
            gotoLogin();
          }
        }
      }
    } else {
      gotoLogin();
    }
  }

  Future<void> getPlansByStation(String stationId) async {
    if (!_mounted) return;

    try {
      alertServices.showLoading("Getting station details...");
      final stationData = await vehicleService.getPlansByStation(stationId);

      if (!_mounted) return;
      alertServices.hideLoading();

      // Update station details
      _safeSetState(() {
        stationDetails = stationData;
        stationLocation = LatLng(
          stationData['lattitude'],
          stationData['longitude'],
        );
        categoryList = List.generate(
          stationData['plans'].length,
          (_) => false,
        );
      });

      // Get route details
      if (_currentPosition != null) {
        alertServices.showLoading("Finding best route...");
        await Future.delayed(const Duration(seconds: 5));

        if (!_mounted) return;
        alertServices.hideLoading();

        final distance = await _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          stationLocation!.latitude,
          stationLocation!.longitude,
        );

        if (!_mounted) return;
        _safeSetState(() => distanceText = distance);

        await _fetchAndDisplayDirections(_currentPosition!, stationLocation!);
      }
    } catch (e, stack) {
      if (!_mounted) return;
      alertServices.hideLoading();
      firebaseCatchLogs(e, stack, reason: AppTitles.homeScreen, fatal: true);
      alertServices.errorToast("Failed to get station details");
      gotoLogin();
    }
  }

  gotoLogin() {
    secureStorage.save("mobile", "");
    secureStorage.save("isLogin", false);
    Navigator.pushNamedAndRemoveUntil(context, "login_page", (route) => false);
  }

  sliderWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SfSliderTheme(
          data: const SfSliderThemeData(
            tooltipBackgroundColor: AppColors.primary,
            thumbColor: Colors.transparent,
            thumbRadius: 20,
            activeDividerColor: Color(0xff3DB54A),
            inactiveDividerStrokeColor: Color(0xff3DB54A),
            activeTrackHeight: 12,
            inactiveTrackHeight: 12,
            inactiveDividerColor: Colors.transparent,
            inactiveTickColor: Colors.transparent,
            activeTrackColor: Color(0xff3DB54A),
            trackCornerRadius: 20,
          ),
          child: SfSlider(
            min: 10.0,
            max: 100.0,
            interval: 10,
            shouldAlwaysShowTooltip: false,
            stepSize: 10,
            thumbIcon: Image.asset("assets/img/slider_logo.png",
                width: 10, height: 10),
            value: distance,
            labelPlacement: LabelPlacement.onTicks,
            thumbShape: const SfThumbShape(),
            semanticFormatterCallback: (dynamic value) {
              return '$value km';
            },
            enableTooltip: true,
            showLabels: false,
            showDividers: true,
            showTicks: false,
            tooltipTextFormatterCallback: (av, ft) {
              return "$ft km";
            },
            onChanged: (dynamic newValue) {
              setState(() {
                distance = newValue;
              });
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '10 km',
                style: TextStyle(
                  color: Color(0xff7B7B7B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '100 km',
                style: TextStyle(
                  color: Color(0xff7B7B7B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  buttonWidget() {
    return SizedBox(
      height: 45,
      child: AppButtonWidget(
        title: "Proceed",
        onPressed: selectedPlan == ""
            ? null
            : () {
                List list = [
                  {
                    'sId': stationDetails['stationId'].toString(),
                    'sName': stationDetails['stationName'].toString(),
                    'plan': selectedPlan.toString(),
                    'distanceText': distanceText.toString(),
                    'distance': distance.toString().replaceAll(".0", ""),
                  },
                ];
                getVehiclesByPlan(list);
              },
      ),
    );
  }

  // VEHICLE FILTRATION
  getVehiclesByPlan(List list) async {
    if (!_mounted) return;
    alertServices.showLoading();
    vehicleService
        .getVehiclesByStation(list[0]['sId'].toString())
        .then((response) async {
      if (!_mounted) return;
      alertServices.hideLoading();
      filterVehicleList = [];
      closedVehicleList = [];
      vehicleList = response.where((i) => i['distanceRange'] != null).toList();

      for (int i = 0; i < vehicleList.length; i++) {
        List dis = vehicleList[i]['distanceRange'].toString().split("-");
        if (dis.length == 2) {
          int minDistance = int.parse(dis[0]);
          int maxDistance = int.parse(dis[1]);
          int userDistance = int.parse(list[0]['distance']);

          String result =
              checkConditions(minDistance, maxDistance, userDistance);
          _safeSetState(() {
            if (result == "exact") {
              if (vehicleList[i]['planType'].toString() ==
                  list[0]['plan'].toString()) {
                filterVehicleList.add(vehicleList[i]);
              }
            } else if (result == "withRange") {
              if (vehicleList[i]['planType'].toString() !=
                  list[0]['plan'].toString()) {
                closedVehicleList.add(vehicleList[i]);
              }
            }
          });
        }
      }

      if (closedVehicleList.isEmpty && filterVehicleList.isEmpty) {
        Navigator.pushNamed(context, "error_bike");
      } else {
        List params = [
          {
            "sId": list[0]['sId'].toString(),
            "sName": list[0]['sName'].toString(),
            "distanceText": list[0]['distanceText'].toString(),
            "distance": list[0]['distance'].toString(),
            "filterVehicleList": filterVehicleList,
            "closedVehicleList": closedVehicleList,
          }
        ];
        Navigator.pushNamed(context, "select_vehicle", arguments: params);
      }
    });
  }

  String checkConditions(int a, int b, int c) {
    if (c >= a && c <= b) {
      return "exact";
    } else if (isWithinRange(a, b, c, 20)) {
      return "withRange";
    } else {
      return "Wrong number";
    }
  }

  bool isWithinRange(int a, int b, int c, int range) {
    return (a >= c - 10 && b <= c + 20);
  }

  getZoomControl() {
    if (Platform.isIOS) {
      return const MinMaxZoomPreference(15, 19);
    } else {
      return MinMaxZoomPreference.unbounded;
    }
  }
}
