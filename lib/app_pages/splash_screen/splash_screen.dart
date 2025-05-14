import 'package:driev/app_config/app_config.dart';
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
  final SecureStorage _secureStorage = SecureStorage();
  final AlertServices _alertServices = AlertServices();
  final VehicleService _vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    printPageTitle(AppTitles.splashScreen);
    _initialize();
  }

  Future<void> _initialize() async {
    _setStatusBarStyle();
    await _checkLocationService();
    await Future.delayed(const Duration(seconds: 3), _navigateToNextScreen);
  }

  void _setStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Center(child: Image.asset(AppImages.appLogo)),
        ),
      ),
    );
  }

  Future<void> _navigateToNextScreen() async {
    final String? mobile = await _secureStorage.get("mobile");
    final bool isLogin = await _secureStorage.get("isLogin") ?? false;

    if (isLogin && mobile != null) {
      _getActiveRides(mobile);
    } else {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, "landing_page", (_) => false);
    }
  }

  Future<void> _getActiveRides(String mobile) async {
    _alertServices.showLoading();
    try {
      final response = await _vehicleService.getActiveRides(mobile);
      if (response != null) {
        final List rideList = response['rideList'] ?? [];
        final activeRides =
            rideList.where((e) => e['status'] == "On Ride").toList();

        if (activeRides.isEmpty) {
          _getBlockedRides(mobile);
        } else {
          if (!mounted) return;
          String rideId = activeRides[0]['rideId'].toString();
          Navigator.pushNamed(context, "on_ride", arguments: rideId);
        }
      }
    } catch (e) {
      debugPrint("Error fetching active rides: $e");
      _alertServices.hideLoading();
      _showErrorAlert('Failed to load active rides.');
    }
  }

  Future<void> _getBlockedRides(String mobile) async {
    _alertServices.showLoading();
    try {
      final blockedRides = await _vehicleService.getBlockedRides(mobile);
      if (blockedRides != null && blockedRides.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushNamed(context, "extend_bike", arguments: blockedRides);
      } else {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, "home", (_) => false);
      }
    } catch (e) {
      debugPrint("Error fetching blocked rides: $e");
      _alertServices.hideLoading();
      _showErrorAlert('Failed to load blocked rides.');
    }
  }

  Future<void> _checkLocationService() async {
    try {
      final LocationService locationService = LocationService();
      final Position position = await locationService.determinePosition();
      debugPrint("Position: $position");
    } catch (e, stack) {
      firebaseCatchLogs(e, stack, reason: AppTitles.splashScreen, fatal: true);
    }
  }

  void _showErrorAlert(String message) {
    _alertServices.hideLoading();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
