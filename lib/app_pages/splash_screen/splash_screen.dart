import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';

import '../../app_services/vehicle_service.dart';
import '../../app_storages/secure_storage.dart';

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
  String mobile = "";

  @override
  void initState() {
    debugPrint('--->>> Splash Screen <<<---');
    super.initState();
    setState(() {
      mobile = secureStorage.get("mobile");
    });
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset("assets/img/logo.png"),
        ),
      ),
    );
  }

  getRoute() async {
    bool isLogin = await secureStorage.get("isLogin") ?? false;
    if (isLogin) {
      getActiveRides(mobile);
      // Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, "landing_page", (route) => false);
    }
  }

  getActiveRides(String mobile) {
    print("---------- getActiveRides -------------");
    alertServices.showLoading();
    vehicleService.getActiveRides(mobile).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        List rideList = [r][0]['rideList'];
        List a =
            rideList.where((e) => e['status'].toString() == "On Ride").toList();
        if (a.isEmpty) {
          getBlockRides(mobile);
          // home page
          // Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        } else {
          // print("Ride ID -> ${a[0]['rideId'].toString()}");
          Navigator.pushNamed(context, "on_ride",
              arguments: a[0]['rideId'].toString());
        }
      }
    });
  }

  getBlockRides(String mobile) {
    print("---------- getBlockRides -------------");
    alertServices.showLoading();
    vehicleService.getBlockedRides(mobile).then((r) {
      alertServices.hideLoading();
      if (r != null) {
        if (r.isNotEmpty) {
          print("getBlockRides ---> $r");
          Navigator.pushNamed(context, "extend_bike", arguments: r);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
        }
        // setState(() {
        // rideDetails = [r];
        // });
      }
    });
  }
}
