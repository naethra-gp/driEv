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
import '../../app_utils/app_widgets/app_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LocationService _locationService = LocationService();
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  String selfieUrl = "assets/img/profile_logo.png";
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
  List categoryList = [];
  String selectedPlan = "";

  List vehicleList = [];
  List filterVehicleList = [];
  List closedVehicleList = [];

  final double smallDeviceHeight = 600;
  final double mediumDeviceHeight = 800;

  @override
  void initState() {
    getLocation();
    getCustomerDetails();
    _loadCustomIcons();

    super.initState();
  }

  updateProfile() async {
    selfieUrl = await customer[0]['selfi'];
    print('profile update $selfieUrl');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    double containerHeight;
    double textScaleFactor = 1.2;
    if (height < smallDeviceHeight) {
      print("Using small device height condition");
      containerHeight = height / 2.95;
    } else if (height < mediumDeviceHeight) {
      print("Using medium device height condition");
      containerHeight = height / 2.10;
    } else {
      print("Using large device height condition");
      containerHeight = height / 1.8;
      print("Height $containerHeight");
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
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
                    zoom: 13.5,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "profile");
                      },
                      child: CachedNetworkImage(
                        width: 41,
                        height: 41,
                        imageUrl: selfieUrl,
                        // imageUrl: selfieUrl,
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
                            onTap: () {
                              Navigator.pushNamed(context, "wallet_summary");
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
                                if (customer.isNotEmpty)
                                  Text(
                                    "\u{20B9}${customer[0]['walletBalance']}",
                                    style: TextStyle(
                                      fontSize: width / 30,
                                      fontWeight: FontWeight.bold,
                                      color: getColor(
                                          customer[0]['walletBalance']),
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: containerHeight,
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
                        sliderWidget(),
                        const SizedBox(height: 15),
                        Text(
                          "Preferred Category",
                          style: TextStyle(
                            fontSize: 14 * textScaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (stationDetails.isNotEmpty) ...[
                          Flexible(
                            child: Wrap(
                              spacing: 10.0,
                              runSpacing: 5.0,
                              alignment: WrapAlignment.start,
                              children: [
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
                                        selectedPlan = stationDetails['plans']
                                                [i]
                                            .toString();
                                      });
                                    },
                                    child: Text(
                                      stationDetails['plans'][i].toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14 * textScaleFactor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          buttonWidget(),
                        ],
                        // CustomTheme.defaultHeight10,
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
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
    stationMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/img/map_station_icon.png',
    );
    customerMarker = await BitmapDescriptor.asset(
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
        await updateProfile();
        String station = customer[0]['registeredStation'].toString();
        // print("customer --> ${jsonEncode(customer)}");
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
    // print("_addPolyline");
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
    setState(() {
      _polyLines.add(polyline);
    });
    alertServices.showLoading("Calculate distance...");
    Future.delayed(const Duration(seconds: 3), () {
      print("_zoomToFitPositions");
      alertServices.hideLoading();
      // TODO: UNCOMMENT THIS LINE
      // _zoomToFitPositions();
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

        for (var list in stationDetails['plans']) {
          categoryList.add(false);
        }
        alertServices.showLoading("Finding best route...");
        Future.delayed(const Duration(seconds: 5), () async {
          // print("delay logic");
          alertServices.hideLoading();
          if (_currentPosition != null) {
            String distance = await _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              stationLat,
              stationLon,
            );
            setState(() {
              distanceText = distance.toString();
            });
            _fetchAndDisplayDirections(_currentPosition!, stationLocation!);
          }
        });
      },
    );
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
      children: [
        Stack(
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
              child: Center(
                child: SfSlider(
                  min: 10.0,
                  max: 100.0,
                  interval: 10,
                  shouldAlwaysShowTooltip: false,
                  stepSize: 10,
                  thumbIcon: Image.asset("assets/img/slider1.png",
                      width: 16, height: 20),
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
            ),
          ],
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
    alertServices.showLoading();
    vehicleService
        .getVehiclesByPlan(
            list[0]['sId'].toString(), list[0]['plan'].toString())
        .then((response) async {
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
          setState(() {
            if (result == "exact") {
              filterVehicleList.add(vehicleList[i]);
            }
            if (result == "withRange") {
              closedVehicleList.add(vehicleList[i]);
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
            "plan": list[0]['plan'].toString(),
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
    return (c >= a - range && c <= a + range) ||
        (c >= b - range && c <= b + range);
  }
}
