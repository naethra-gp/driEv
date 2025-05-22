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

class MapWidget extends StatefulWidget {
  final LatLng? currentPosition;
  final LatLng? stationLocation;
  final Set<Polyline> polylines;
  final BitmapDescriptor? customerMarker;
  final BitmapDescriptor? stationMarker;
  final Function(GoogleMapController) onMapCreated;
  final MinMaxZoomPreference? zoomPreference;

  const MapWidget({
    super.key,
    this.currentPosition,
    this.stationLocation,
    required this.polylines,
    this.customerMarker,
    this.stationMarker,
    required this.onMapCreated,
    this.zoomPreference,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.currentPosition != null && widget.stationLocation != null) {
      return GoogleMap(
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        compassEnabled: false,
        mapType: MapType.normal,
        minMaxZoomPreference:
            widget.zoomPreference ?? MinMaxZoomPreference.unbounded,
        onMapCreated: widget.onMapCreated,
        polylines: widget.polylines,
        initialCameraPosition: const CameraPosition(
          target: LatLng(20.2993002, 85.8173442),
          zoom: 20.5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('1'),
            position: widget.currentPosition!,
            icon: widget.customerMarker ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('2'),
            position: widget.stationLocation!,
            icon: widget.stationMarker ?? BitmapDescriptor.defaultMarker,
          ),
        },
      );
    }

    return GoogleMap(
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: false,
      mapType: MapType.normal,
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(20.2993002, 85.8173442),
        zoom: 13.5,
      ),
    );
  }
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AlertServices _alertServices = AlertServices();
  final CustomerService _customerService = CustomerService();
  final SecureStorage _secureStorage = SecureStorage();
  final VehicleService _vehicleService = VehicleService();
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _locationSubscription;

  // Map related variables
  String _location = "";
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(20.2993002, 85.8173442);
  LatLng? _currentPosition;
  BitmapDescriptor? _customerMarker;
  BitmapDescriptor? _stationMarker;
  final Set<Polyline> _polyLines = {};

  // App state variables
  List<Map<String, dynamic>> _customer = [];
  Map<String, dynamic> _stationDetails = {};
  LatLng? _stationLocation;
  List<bool> _categoryList = [];
  String _selectedPlan = "";
  List<Map<String, dynamic>> _vehicleList = [];
  List<Map<String, dynamic>> _filterVehicleList = [];
  List<Map<String, dynamic>> _closedVehicleList = [];
  double _distance = 20;
  String? _distanceText = "";
  bool _mounted = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    printPageTitle(AppTitles.homeScreen);
    _initializeData();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _mounted = false;
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLocationUpdates();
    } else if (state == AppLifecycleState.paused) {
      _locationSubscription?.cancel();
    }
  }

  void _startLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 30),
      ),
    ).listen(
      (Position position) {
        if (!_mounted) return;
        debugPrint(
            "Location update received: ${position.latitude}, ${position.longitude}");
        _updateLocation(position);
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
        if (!_mounted) return;
        _alertServices.errorToast(
            "Location updates failed. Please check your location settings.");
        // Try to restart location updates after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (_mounted) {
            _startLocationUpdates();
          }
        });
      },
      cancelOnError: false,
    );
  }

  void _updateLocation(Position position) {
    if (!_mounted) return;
    debugPrint(
        "Processing location update: ${position.latitude}, ${position.longitude}");

    if (position.latitude == 0 && position.longitude == 0) {
      debugPrint("Invalid position received (0,0)");
      return;
    }

    _safeSetState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    if (_currentPosition != null && _stationLocation != null) {
      _fetchAndDisplayDirections(_currentPosition!, _stationLocation!);
    }
  }

  Future<void> _initializeData() async {
    if (!_mounted) return;
    await _getCustomerDetails();
  }

  void _safeSetState(VoidCallback fn) {
    if (_mounted && !_isLoading) {
      setState(fn);
    }
  }

  Future<void> _getCustomerDetails() async {
    if (!_mounted) return;
    try {
      _isLoading = true;
      _alertServices.showLoading();
      final String? mobile = _secureStorage.get("mobile");
      if (mobile == null) {
        _gotoLogin();
        return;
      }

      final response = await _customerService.getCustomer(mobile, true);
      if (!_mounted) return;

      if (response == null) {
        _alertServices.hideLoading();
        _gotoLogin();
        return;
      }

      _safeSetState(() {
        _customer = [response];
      });

      await _processCustomerData(response);
    } catch (e, stack) {
      if (!_mounted) return;
      _alertServices.hideLoading();
      firebaseCatchLogs(e, stack, reason: AppTitles.homeScreen, fatal: false);
      _alertServices.errorToast("Failed to get user details");
      _gotoLogin();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _processCustomerData(Map<String, dynamic> response) async {
    if (!_mounted) return;

    debugPrint("=== Processing Customer Data ===");
    debugPrint("Response: $response");

    final station = response['registeredStation'].toString();
    final kyc = response['kycStatus'] ?? "";
    final block = response['blockStatus'] ?? "";
    final custType = response['custType'] ?? "";
    final status = response['accountStatus'] ?? "";

    debugPrint("Station ID: $station");
    debugPrint("KYC Status: $kyc");
    debugPrint("Block Status: $block");
    debugPrint("Customer Type: $custType");
    debugPrint("Account Status: $status");

    if (custType == "Subscription") {
      debugPrint("Customer is on subscription plan");
      _alertServices.hideLoading();
      _alertServices.subscriptionAlert(context, "");
      return;
    }

    if (status == "N") {
      debugPrint("Account status is inactive");
      _alertServices.hideLoading();
      _alertServices.deleteUserAlert(
          context, response['message'].toString(), null);
      return;
    }

    if (block == "Y") {
      debugPrint("Account is blocked");
      _alertServices.hideLoading();
      _alertServices.blockedKycAlert(context, response['comment'].toString());
      return;
    }

    if (kyc.isEmpty) {
      debugPrint("KYC status is empty");
      _alertServices.hideLoading();
      _alertServices.holdKycAlert(context);
      return;
    }

    if (kyc == "N") {
      debugPrint("KYC is rejected");
      _alertServices.hideLoading();
      _alertServices.rejectKycAlert(context);
      return;
    }

    if (station.isEmpty) {
      debugPrint("Station ID is empty");
      _alertServices.hideLoading();
      _alertServices.errorToast("Registered Station is missing.");
      _gotoLogin();
      return;
    }

    debugPrint(
        "All checks passed, proceeding with location and station details");
    _alertServices.showLoading("Getting your location...");
    await _getUserLocation();
    if (!_mounted) return;
    await _loadCustomIcons();
    await _getPlansByStation(station);
  }

  Future<void> _getUserLocation() async {
    if (!_mounted) return;
    try {
      _alertServices.showLoading("Getting your location...");

      final Position? position =
          await _locationService.determinePosition().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint("Location request timed out after 30 seconds");
          return null;
        },
      );

      if (!_mounted) return;
      _alertServices.hideLoading();

      if (position == null) {
        if (!_mounted) return;
        _alertServices.errorToast(
            "Unable to get your location. Please ensure location services are enabled and try again.");
        return;
      }

      try {
        final Placemark place =
            await _locationService.getPlaceMark(position).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint("Geocoding request timed out after 10 seconds");
            return const Placemark(
              locality: "Unknown Location",
              subLocality: "",
              administrativeArea: "",
              country: "",
              name: "",
              street: "",
              postalCode: "",
              subAdministrativeArea: "",
              isoCountryCode: "",
              thoroughfare: "",
              subThoroughfare: "",
            );
          },
        );

        if (!_mounted) return;

        _safeSetState(() {
          _location = place.locality?.toString() ?? "Unknown Location";
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      } catch (e) {
        debugPrint("Error getting placemark: $e");
        if (!_mounted) return;
        _safeSetState(() {
          _location = "Unknown Location";
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e, stack) {
      if (!_mounted) return;
      _alertServices.hideLoading();
      firebaseCatchLogs(e, stack,
          reason: "HomePage - getUserLocation", fatal: false);
      _alertServices.errorToast(
          "Failed to get location. Please check your location settings and try again.");
    }
  }

  Future<void> _loadCustomIcons() async {
    if (!_mounted) return;
    _stationMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 30)),
      'assets/img/map_station_icon.png',
    );
    _customerMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 25)),
      'assets/img/map_user_icon.png',
    );
  }

  void _gotoLogin() {
    _secureStorage.save("mobile", "");
    _secureStorage.save("isLogin", false);
    Navigator.pushNamedAndRemoveUntil(context, "login_page", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_mounted) return const SizedBox.shrink();

    const textScaleFactor = 1.1;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.loose,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            SizedBox(
              height: screenHeight,
              child: MapWidget(
                currentPosition: _currentPosition,
                stationLocation: _stationLocation,
                polylines: _polyLines,
                customerMarker: _customerMarker,
                stationMarker: _stationMarker,
                onMapCreated: (controller) {
                  _mapController = controller;
                  debugPrint("Map controller created");
                },
                zoomPreference: getZoomControl(),
              ),
            ),
            if (_customer.isNotEmpty)
              HomeTopWidget(
                imgUrl: _customer[0]['selfi'].toString(),
                location: _location.toString(),
                balance: double.parse(_customer[0]['walletBalance'].toString()),
              ),
            _buildBottomSheet(textScaleFactor),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(double textScaleFactor) {
    return Positioned(
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
              if (_stationDetails.isNotEmpty) ...[
                const SizedBox(height: 15),
                Flexible(
                  child: _buildCategoryButtons(textScaleFactor),
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
    );
  }

  Widget _buildCategoryButtons(double textScaleFactor) {
    if (_stationDetails.isEmpty) {
      return const Center(
        child: Text(
          "No station details available",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    final plans = _stationDetails['plans'] as List?;
    if (plans == null || plans.isEmpty) {
      return const Center(
        child: Text(
          "Bummer! No bikes available right now. Check back later.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Roboto",
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 15.0,
      runSpacing: 2.0,
      alignment: WrapAlignment.start,
      children: List.generate(
        plans.length,
        (i) => _buildCategoryButton(i, textScaleFactor),
      ),
    );
  }

  Widget _buildCategoryButton(int index, double textScaleFactor) {
    final plans = _stationDetails['plans'] as List;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.white,
        backgroundColor:
            _categoryList[index] ? Colors.white : const Color(0xffF5F5F5),
        side: BorderSide(
          color: _categoryList[index]
              ? const Color(0xff3DB54A)
              : const Color(0xffE1E1E1),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () => _onCategorySelected(index),
      child: Text(
        plans[index].toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 12 * textScaleFactor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  void _onCategorySelected(int index) {
    if (!_mounted) return;
    setState(() {
      _categoryList = _categoryList.map((e) => false).toList();
      _categoryList[index] = true;
      _selectedPlan = _stationDetails['plans'][index].toString();
    });
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
    debugPrint("Start: ${start.latitude}, ${start.longitude}");
    debugPrint("End: ${end.latitude}, ${end.longitude}");

    try {
      // Check distance between points
      double distance = distanceBetween(start, end);
      debugPrint("Distance between points: ${distance.toStringAsFixed(2)} km");
      debugPrint(
          "Distance check: ${distance <= 100 ? "Within 100km limit" : "Exceeds 100km limit"}");

      if (distance > 100) {
        debugPrint("Points are outside the 100km radius limit");
        _safeSetState(() {
          _distanceText = "Distance exceeds 100km limit";
          _polyLines.clear();
        });
        return;
      }

      // Clear existing polylines
      _safeSetState(() {
        _polyLines.clear();
      });

      // Get directions with timeout
      debugPrint("Fetching directions from Google Directions API...");
      List<LatLng> polylineCoordinates =
          await _locationService.getDirections(start, end).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint("Directions request timed out after 10 seconds");
          return <LatLng>[];
        },
      );

      if (!_mounted) return;

      debugPrint("Polyline points count: ${polylineCoordinates.length}");
      if (polylineCoordinates.isNotEmpty) {
        debugPrint(
            "First point: ${polylineCoordinates.first.latitude}, ${polylineCoordinates.first.longitude}");
        debugPrint(
            "Last point: ${polylineCoordinates.last.latitude}, ${polylineCoordinates.last.longitude}");
      }

      if (polylineCoordinates.isEmpty) {
        debugPrint("No route found between points");
        _safeSetState(() {
          _distanceText = "No route available";
        });
        return;
      }

      // Create and add polyline
      Polyline polyline = Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.black,
        points: polylineCoordinates,
        width: 4,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
        geodesic: true,
      );

      debugPrint(
          "Adding polyline to map with ${polylineCoordinates.length} points");
      _safeSetState(() {
        _polyLines.add(polyline);
        _distanceText = "Distance: ${distance.toStringAsFixed(1)} km";
      });

      // Zoom to fit the route
      if (_currentPosition != null && _stationLocation != null) {
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            min(_currentPosition!.latitude, _stationLocation!.latitude),
            min(_currentPosition!.longitude, _stationLocation!.longitude),
          ),
          northeast: LatLng(
            max(_currentPosition!.latitude, _stationLocation!.latitude),
            max(_currentPosition!.longitude, _stationLocation!.longitude),
          ),
        );

        debugPrint(
            "Zooming to bounds: SW(${bounds.southwest.latitude}, ${bounds.southwest.longitude}), NE(${bounds.northeast.latitude}, ${bounds.northeast.longitude})");
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0),
        );
      }
    } catch (e, stack) {
      debugPrint("Error fetching directions: $e");
      debugPrint("Stack trace: $stack");
      firebaseCatchLogs(e, stack,
          reason: "HomePage - fetchDirections", fatal: false);
      _safeSetState(() {
        _distanceText = "Error finding route";
      });
    }
  }

  Future<void> _getPlansByStation(String stationId) async {
    if (!_mounted) return;

    try {
      debugPrint("=== Getting Plans By Station ===");
      debugPrint("Station ID: $stationId");
      _alertServices.showLoading("Loading station details...");

      final stationData = await _vehicleService.getPlansByStation(stationId);
      debugPrint("Raw station data: $stationData");

      if (!_mounted) return;

      if (stationData == null) {
        debugPrint("Station data is null");
        _alertServices.hideLoading();
        _alertServices.errorToast("No station details found");
        return;
      }

      if (stationData.isEmpty) {
        debugPrint("Station data is empty");
        _alertServices.hideLoading();
        _alertServices.errorToast("No station details found");
        return;
      }

      debugPrint("Station data keys: ${stationData.keys.toList()}");
      debugPrint("Plans data: ${stationData['plans']}");

      // Update station details
      _safeSetState(() {
        _stationDetails = stationData;
        debugPrint("Station details updated: $_stationDetails");

        // Parse and set station location
        try {
          final lat = stationData['lattitude']?.toString();
          final lng = stationData['longitude']?.toString();

          debugPrint("Raw latitude: $lat");
          debugPrint("Raw longitude: $lng");

          if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
            final double latitude = double.parse(lat);
            final double longitude = double.parse(lng);

            if (latitude != 0 && longitude != 0) {
              _stationLocation = LatLng(latitude, longitude);
              debugPrint(
                  "Station location set to: ${_stationLocation?.latitude}, ${_stationLocation?.longitude}");
            } else {
              debugPrint("Warning: Station coordinates are (0,0)");
            }
          } else {
            debugPrint("Warning: Station coordinates are missing or empty");
          }
        } catch (e) {
          debugPrint("Error parsing station coordinates: $e");
        }

        final plansLength = stationData['plans']?.length ?? 0;
        debugPrint("Number of plans: $plansLength");
        _categoryList = List.generate(plansLength, (_) => false);
        debugPrint(
            "Category list initialized with ${_categoryList.length} items");
      });

      // Get route details if we have both locations
      if (_currentPosition != null && _stationLocation != null) {
        debugPrint("Both locations available, calculating route");
        _alertServices.showLoading("Finding best route...");
        await Future.delayed(const Duration(seconds: 1));

        if (!_mounted) return;

        final distance = await _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _stationLocation!.latitude,
          _stationLocation!.longitude,
        );

        if (!_mounted) return;
        _safeSetState(() => _distanceText = distance);
        debugPrint("Distance calculated: $distance");

        await _fetchAndDisplayDirections(_currentPosition!, _stationLocation!);
      } else {
        debugPrint("Cannot calculate route: missing location data");
        debugPrint("Current position: $_currentPosition");
        debugPrint("Station location: $_stationLocation");

        // If we have station location but no current position, try to get location again
        if (_stationLocation != null && _currentPosition == null) {
          debugPrint("Attempting to get current position again");
          await _getUserLocation();
        }
      }

      _alertServices.hideLoading();
    } catch (e, stack) {
      debugPrint("=== Error in _getPlansByStation ===");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stack");
      if (!_mounted) return;
      _alertServices.hideLoading();
      firebaseCatchLogs(e, stack, reason: AppTitles.homeScreen, fatal: false);
      _alertServices
          .errorToast("Failed to get station details: ${e.toString()}");
    }
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
            value: _distance,
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
                _distance = newValue;
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
        onPressed: _selectedPlan == ""
            ? null
            : () {
                List list = [
                  {
                    'sId': _stationDetails['stationId'].toString(),
                    'sName': _stationDetails['stationName'].toString(),
                    'plan': _selectedPlan.toString(),
                    'distanceText': _distanceText.toString(),
                    'distance': _distance.toString().replaceAll(".0", ""),
                  },
                ];
                debugPrint(
                    "====> Distance: ${_distance.toString().replaceAll(".0", "")}");
                getVehiclesByPlan(list);
              },
      ),
    );
  }

  // VEHICLE FILTRATION
  getVehiclesByPlan(List list) async {
    if (!_mounted) return;
    _alertServices.showLoading();
    _vehicleService
        .getVehiclesByStation(list[0]['sId'].toString())
        .then((response) async {
      if (!_mounted) return;
      _alertServices.hideLoading();
      _filterVehicleList = [];
      _closedVehicleList = [];
      _vehicleList = response.where((i) => i['distanceRange'] != null).toList();

      for (int i = 0; i < _vehicleList.length; i++) {
        List dis = _vehicleList[i]['distanceRange'].toString().split("-");
        if (dis.length == 2) {
          int minDistance = int.parse(dis[0]);
          int maxDistance = int.parse(dis[1]);
          int userDistance = int.parse(list[0]['distance']);

          String result =
              checkConditions(minDistance, maxDistance, userDistance);
          _safeSetState(() {
            if (result == "exact") {
              if (_vehicleList[i]['planType'].toString() ==
                  list[0]['plan'].toString()) {
                _filterVehicleList.add(_vehicleList[i]);
              }
            } else if (result == "withRange") {
              if (_vehicleList[i]['planType'].toString() !=
                  list[0]['plan'].toString()) {
                _closedVehicleList.add(_vehicleList[i]);
              }
            }
          });
        }
      }

      if (_closedVehicleList.isEmpty && _filterVehicleList.isEmpty) {
        Navigator.pushNamed(context, "error_bike");
      } else {
        List params = [
          {
            "sId": list[0]['sId'].toString(),
            "sName": list[0]['sName'].toString(),
            "distanceText": list[0]['distanceText'].toString(),
            "distance": list[0]['distance'].toString(),
            "filterVehicleList": _filterVehicleList,
            "closedVehicleList": _closedVehicleList,
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
