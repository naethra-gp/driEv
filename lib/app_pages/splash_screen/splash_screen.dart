import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

import '../../app_services/vehicle_service.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_utils/app_provider/location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SecureStorage secureStorage = SecureStorage();
  AlertServices alertServices = AlertServices();
  VehicleService vehicleService = VehicleService();
  bool loading = true;

  @override
  void initState() {
    debugPrint('--->>> Splash Screen <<<---');
    super.initState();
    checkLocationService();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Set the status bar color here
      statusBarIconBrightness:
          Brightness.dark, // For Android to set the icons color
    ));
    Future.delayed(const Duration(seconds: 3), () {
      getRoute();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set your desired background color here
        child: SafeArea(
          child: Center(
            child: Image.asset("assets/img/logo.png"),
          ),
        ),
      ),
    );
  }

  getRoute() async {
    var mobile = await secureStorage.get("mobile");
    bool isLogin = await secureStorage.get("isLogin") ?? false;
    if (isLogin && mobile != null) {
      getActiveRides(mobile);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, "landing_page", (route) => false);
    }
  }

  getActiveRides(String mobile) {
    alertServices.showLoading();
    vehicleService.getActiveRides(mobile).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        List rideList = [r][0]['rideList'];
        List a =
            rideList.where((e) => e['status'].toString() == "On Ride").toList();
        if (a.isEmpty) {
          getBlockRides(mobile);
        } else {
          Navigator.pushNamed(context, "on_ride",
              arguments: a[0]['rideId'].toString());
        }
      }
    });
  }

  getBlockRides(String mobile) {
    alertServices.showLoading();
    vehicleService.getBlockedRides(mobile).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        if (r.isNotEmpty) {
          Navigator.pushNamed(context, "extend_bike", arguments: r);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        }
      }
    });
  }

  checkLocationService() async {
    final LocationService _locationService = LocationService();
    Position position = await _locationService.determinePosition();
    print("position $position");
  }
}
