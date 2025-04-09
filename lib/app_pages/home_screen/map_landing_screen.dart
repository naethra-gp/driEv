import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLandingScreen extends StatefulWidget {
  const MapLandingScreen({super.key});

  @override
  State<MapLandingScreen> createState() => _MapLandingScreenState();
}

class _MapLandingScreenState extends State<MapLandingScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Marker? _currentLocationMarker;
  Circle? _currentLocationCircle;

  // Define an initial camera position (this can be any place or zero)
  static const LatLng _initialPosition =
      LatLng(37.42796133580664, -122.085749655962);

  @override
  void initState() {
    _checkLocationPermissions();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 15.0,
            ),
            markers: _currentLocationMarker != null
                ? {_currentLocationMarker!}
                : <Marker>{},
            circles: _currentLocationCircle != null
                ? {_currentLocationCircle!}
                : <Circle>{},
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.45,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.blue[100],
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 25,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text('Item $index'));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- LOCATION FUNCTIONS ---
  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _showMessage('Location services are disabled.');
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _showMessage('Location permissions are denied.');
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _showMessage('Location permissions are permanently denied.');
      });
      return;
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _updateLocationOnMap(position);
    });
  }

  void _updateLocationOnMap(Position position) {
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentLocationMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _currentLocationCircle = Circle(
        circleId: const CircleId('currentLocationCircle'),
        center: currentLatLng,
        radius: 50, // Radius in meters
        strokeColor: Colors.blue.withOpacity(0.5),
        strokeWidth: 1,
        fillColor: Colors.blue.withOpacity(0.1),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
