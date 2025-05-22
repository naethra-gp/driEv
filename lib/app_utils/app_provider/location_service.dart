import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    as polyline_algo;

import 'package:driev/app_config/app_config.dart';

class LocationService {
  final String _apiKey = Constants.googleMapsApiKey;
  final loc.Location _location = loc.Location();

  Future<Position?> determinePosition() async {
    try {
      debugPrint("=== Determining Position ===");

      // First try with Location package
      try {
        debugPrint("Checking Location package service and permission");

        bool serviceEnabled = await _location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await _location.requestService();
          if (!serviceEnabled) {
            debugPrint("User declined to enable location services");
            return null;
          }
        }

        loc.PermissionStatus permission = await _location.hasPermission();
        if (permission == loc.PermissionStatus.denied) {
          permission = await _location.requestPermission();
          if (permission != loc.PermissionStatus.granted) {
            debugPrint("Location permission denied");
            return null;
          }
        }

        debugPrint("Fetching location using Location package...");
        final locationData = await _location.getLocation().timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            debugPrint("Timeout waiting for location");
            throw TimeoutException("Location fetch timed out");
          },
        );

        if (locationData.latitude != null && locationData.longitude != null) {
          debugPrint(
              "Location package success: ${locationData.latitude}, ${locationData.longitude}");
          return Position(
            latitude: locationData.latitude!,
            longitude: locationData.longitude!,
            timestamp: DateTime.now(),
            accuracy: locationData.accuracy ?? 0,
            altitude: locationData.altitude ?? 0,
            heading: locationData.heading ?? 0,
            speed: locationData.speed ?? 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      } catch (e) {
        debugPrint("Location package error: $e");
      }

      // Fallback to Geolocator
      debugPrint("Falling back to Geolocator");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location services are disabled");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        debugPrint("Location permission denied");
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("Location permission permanently denied");
        AppSettings.openAppSettings();
        return null;
      }

      try {
        debugPrint("Attempting to get position with lowest accuracy");
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.lowest,
          timeLimit: const Duration(seconds: 15),
        );
      } catch (e) {
        debugPrint("Lowest accuracy failed: $e");

        try {
          debugPrint("Attempting to get position with low accuracy");
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 15),
          );
        } catch (e) {
          debugPrint("Low accuracy failed: $e");

          try {
            debugPrint("Attempting to get position with high accuracy");
            return await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 15),
            );
          } catch (e) {
            debugPrint("High accuracy failed: $e");
            return null;
          }
        }
      }
    } catch (e, stack) {
      debugPrint("Error in determinePosition: $e");
      debugPrint("Stack trace: $stack");
      return null;
    }
  }

  Future<Placemark> getPlaceMark(Position position) async {
    try {
      debugPrint(
          "Getting placemark for position: ${position.latitude}, ${position.longitude}");
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        debugPrint("Placemark found: ${placemarks.first.locality}");
        return placemarks.first;
      } else {
        debugPrint("No placemark found");
        return _unknownPlacemark();
      }
    } catch (e) {
      debugPrint("Error getting placemark: $e");
      return _unknownPlacemark();
    }
  }

  Placemark _unknownPlacemark() {
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
  }

  Future<String> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      double distanceInMeters = Geolocator.distanceBetween(
        startLat,
        startLng,
        endLat,
        endLng,
      );
      double distanceInKm = distanceInMeters / 1000;
      return "${distanceInKm.toStringAsFixed(1)} km";
    } catch (e) {
      debugPrint("Error calculating distance: $e");
      return "Distance calculation failed";
    }
  }

  List<LatLng> decodeGooglePolyline(String encoded) {
    try {
      final List<List<num>> decodedPoints =
          polyline_algo.decodePolyline(encoded);
      debugPrint('Decoded points count: ${decodedPoints.length}');
      return decodedPoints
          .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
          .toList();
    } catch (e, stack) {
      debugPrint('Error decoding polyline: $e');
      return [];
    }
  }

  Future<List<LatLng>> getDirections(LatLng start, LatLng end) async {
    try {
      debugPrint(
          "Getting directions from ${start.latitude},${start.longitude} to ${end.latitude},${end.longitude}");
      // Add API call if needed
      return [start, end]; // fallback dummy path
    } catch (e) {
      debugPrint("Error getting directions: $e");
      return [];
    }
  }


  bool _isValidDirectionsResponse(Map<String, dynamic> data) {
    if (data['status'] != 'OK') {
      debugPrint('Error fetching directions: ${data['status']}');
      if (data['error_message'] != null) {
        debugPrint('Error message: ${data['error_message']}');
      }
      return false;
    }

    if (data['routes'] == null || data['routes'].isEmpty) return false;
    if (data['routes'][0]['legs'] == null || data['routes'][0]['legs'].isEmpty)
      return false;

    return true;
  }

  bool _isValidDistanceMatrixResponse(Map<String, dynamic> data) {
    if (data['rows'] == null ||
        data['rows'].isEmpty ||
        data['rows'][0]['elements'] == null ||
        data['rows'][0]['elements'].isEmpty) {
      return false;
    }
    return true;
  }

  List<LatLng> _extractPolylineCoordinates(Map<String, dynamic> data) {
    try {
      final List<LatLng> polylineCoordinates = [];
      final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

      for (var step in steps) {
        final String polyline = step['polyline']['points'];
        final List<LatLng> decodedPolyline = decodeGooglePolyline(polyline);
        polylineCoordinates.addAll(decodedPolyline);
      }

      if (polylineCoordinates.isEmpty) {
        throw Exception('No valid route points decoded');
      }

      return polylineCoordinates;
    } catch (e, stack) {
      debugPrint('Error extracting polyline coordinates: $e');
      return [];
    }
  }
}
