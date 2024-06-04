import 'dart:async';
import 'dart:convert';

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:http/http.dart' as http;

import '../../app_config/app_constants.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';

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

  List customerDetails = [];
  bool userBlock = false;
  bool userVerified = false;
  List customer = [];
  String selfieUrl = "";
  Map<String, dynamic> stationDetails = {};

  // GOOGLE MAP
  LatLng? customerLocation;
  LatLng? stationLocation;
  GoogleMapController? _controller;
  String currentDistrict = "";
  BitmapDescriptor? customerMarker;
  BitmapDescriptor? stationMarker;

  // SLIDER
  double distance = 20;

  // polyLines
  Map<PolylineId, Polyline> polyLines = {};
  List<LatLng> polylineCoordinates = [];
  final Set<Polyline> _polyLines = {};
  String distanceText = "";

  @override
  void initState() {
    _getUserLocation();
    getLocation();
    getCustomerDetails();
    _loadCustomIcons();
    getCustomer();
    super.initState();
  }

  _getUserLocation() async {
    try {
      var position = await GeolocatorPlatform.instance.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.reduced,
          ));
      setState(() {
        customerLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      customerLocation = null;
    }
  }

  /// GETTING STATION DETAILS
  getCustomerDetails() {
    alertServices.showLoading("Getting user details...");
    String mobile = secureStorage.get("mobile");
    customerService.getCustomer(mobile.toString(), true).then((response) async {
      if (response != null) {
        customer = [response];
        if (customer[0]['registeredStation'] != null) {
          getPlansByStation(customer[0]['registeredStation']);
        } else {
          alertServices.hideLoading();
          alertServices.errorToast("Something wrong!");
          secureStorage.save("mobile", "");
          secureStorage.save("isLogin", false);
          Navigator.pushNamedAndRemoveUntil(
              context, "login_page", (route) => false);
        }
      } else {
        alertServices.hideLoading();
        // alertServices.errorToast("Something wrong!");
        secureStorage.save("mobile", "");
        secureStorage.save("isLogin", false);
        Navigator.pushNamedAndRemoveUntil(
            context, "login_page", (route) => false);
      }
    });
  }

  getPlansByStation(String stationId) async {
    alertServices.showLoading("Getting station details...");
    vehicleService.getPlansByStation(stationId).then(
          (response) async {
        alertServices.hideLoading();
        stationDetails = response;
        double stationLat = stationDetails['lattitude'];
        double stationLon = stationDetails['longitude'];
        stationLocation = LatLng(stationLat, stationLon);
        if (customerLocation != null) {
          final origin =
              '${customerLocation!.latitude},${customerLocation!.longitude}';
          final destination = '$stationLat,$stationLon';
          String url =
              "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=AIzaSyA1BR25d81VWTluf66WscvlTb_T1kRLQeA";
          await _fetchDirection(url);
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            if (customerLocation != null && stationLocation != null) ...[
              GoogleMap(
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                onCameraMove: _onGeoChanged,
                initialCameraPosition: CameraPosition(
                  target: customerLocation!,
                  zoom: 20,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                polylines: distanceText.isNotEmpty ? _polyLines : <Polyline>{},
                markers: {
                  Marker(
                    markerId: const MarkerId('1'),
                    position: customerLocation!,
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
                              )),
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
                          const SizedBox(width: 20),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Current Location - $currentDistrict",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 40,
                            width: 2, // Adjust width as needed
                            color: Colors.grey[300], // Adjust color as needed
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            "assets/img/wallet.png",
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 10),
                          if (customer.isNotEmpty)
                            Text(
                              "\u{20B9}${customer[0]['walletBalance']}",
                              style: TextStyle(
                                // fontSize: 14,
                                fontSize: width / 30,
                                fontWeight: FontWeight.bold,
                                color: getColor(customer[0]['walletBalance']),
                              ),
                              // style: CustomTheme.termStyle1red,
                            ),
                          const SizedBox(width: 20),
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
                                      "assets/img/slider_icon.png",
                                      height: 50,
                                    ),
                                    value: distance,
                                    inactiveColor:
                                    AppColors.primary.withOpacity(0.3),
                                    labelPlacement: LabelPlacement.onTicks,
                                    thumbShape: const SfThumbShape(),
                                    semanticFormatterCallback: (dynamic value) {
                                      return '$value km';
                                    },
                                    enableTooltip: true,
                                    showLabels: false,
                                    showDividers: true,
                                    showTicks: false,
                                    tooltipTextFormatterCallback:
                                        (dynamic actualValue,
                                        String formattedText) {
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
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                          borderRadius:
                                          BorderRadius.circular(10),
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
                                        style: const TextStyle(
                                            color: Colors.black),
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
            ] else ...[
              const Center(
                child: Text("Loading map..."),
              )
            ]
          ],
        ),
      ),
    );
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

  getLocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    PermissionStatus permissionGranted;
    permissionGranted = await Permission.locationWhenInUse.status;
    print("serviceEnabled $serviceEnabled");
    print("permissionGranted $permissionGranted");

    // LOCATION SERVICE
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        alertServices.errorToast("Location service is not enabled");
        // Navigator.pushNamed(context, "profile");
      }
    }
    // PERMISSION
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await Permission.location.request();
      if (permissionGranted != PermissionStatus.granted) {
        alertServices.errorToast("Location Permission is not enabled");
        // Navigator.pushNamed(context, "profile");
      }
    }
    if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
      location.enableBackgroundMode(enable: true);
      location.onLocationChanged.listen((loc.LocationData loc) async {
        double lat = double.parse(loc.latitude.toString());
        double long = double.parse(loc.longitude.toString());
        customerLocation = LatLng(lat, long);
        CameraPosition currentPosition = CameraPosition(
          target: LatLng(lat, long),
          zoom: 14.4746,
        );
        _onGeoChanged(currentPosition);
        // GET ADDRESS - CITY NAME
        List<geo.Placemark> placeMark =
        await geo.placemarkFromCoordinates(lat, long);
        geo.Placemark place = placeMark[0];
        currentDistrict = place.locality!;
        // setState(() {});
      });
    }
  }

  getCustomer() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    customerService.getCustomer(mobile).then((response) {
      customerDetails = [response];
      String kyc = customerDetails[0]['kycStatus'] ?? "";
      String block = customerDetails[0]['blockStatus'] ?? "";
      selfieUrl = customerDetails[0]['selfi'] ?? "";
      if (kyc == "") {
        // SLIDE 26
        alertServices.holdKycAlert(context);
      } else if (kyc == "N") {
        // SLIDE 27
        alertServices.rejectKycAlert(context);
      } else if (kyc == "Y") {
        // SLIDE 31
        userVerified = true;
      }
      if (block == "Y") {
        // SLIDE 29
        userBlock = true;
        String reason = customerDetails[0]['comment'] ?? "";
        alertServices.blockedKycAlert(context, reason);
      }
      alertServices.hideLoading();
      setState(() {});
    });
  }

  _onGeoChanged(location) {
    // print(location);
  }

  /// POLYLINE
  Future<void> _fetchDirection(String url) async {
    print("---- Fetch Direction -----");
    final response = await http.get(Uri.parse(url));
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<dynamic> routes = data['routes'];
          if (routes.isNotEmpty) {
            var route = routes[0];
            var legs = route['legs'][0];
            distanceText = legs['distance']['text'];
            if (distanceText.isNotEmpty) {
              String extractDistance =
              distanceText.replaceAll(",", "").replaceAll(" km", "");
              print("extractDistance $extractDistance");
              // distance = double.parse(extractDistance);
              // String durationText = legs['duration']['text'];
              // print("durationText $durationText");

              PolylinePoints polylinePoints = PolylinePoints();
              PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
                Constants.apikey,
                PointLatLng(
                    customerLocation!.latitude, customerLocation!.longitude),
                PointLatLng(
                    stationLocation!.latitude, stationLocation!.longitude),
              );
              polylineCoordinates.clear();
              if (result.points.isNotEmpty) {
                for (var point in result.points) {
                  polylineCoordinates
                      .add(LatLng(point.latitude, point.longitude));
                }
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
                // _polyLines.clear();
                _polyLines.add(polyline);
                Future.delayed(const Duration(seconds: 2), () {
                  _zoomToFitPositions();
                });

                // setState(() {});
              }
            }
          } else {
            print("No routes found.");
          }
        } else {
          print("Error: ${data['status']}");
        }
      } else {
        print("Failed to fetch directions. code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

// Function to calculate the distance between two LatLng points
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
    if (_controller != null &&
        customerLocation != null &&
        stationLocation != null) {
      double distance = distanceBetween(customerLocation!, stationLocation!);
      double zoomLevel = 15.0 - (log(distance) / log(2));
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          customerLocation!.latitude < stationLocation!.latitude
              ? customerLocation!.latitude
              : stationLocation!.latitude,
          customerLocation!.longitude < stationLocation!.longitude
              ? customerLocation!.longitude
              : stationLocation!.longitude,
        ),
        northeast: LatLng(
          customerLocation!.latitude > stationLocation!.latitude
              ? customerLocation!.latitude
              : stationLocation!.latitude,
          customerLocation!.longitude > stationLocation!.longitude
              ? customerLocation!.longitude
              : stationLocation!.longitude,
        ),
      );

      double padding = 50.0;
      _controller?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );
      _controller?.animateCamera(
        CameraUpdate.zoomTo(zoomLevel),
      );
    }
  }
}
