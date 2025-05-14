import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:driev/app_config/app_config.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:flutter/foundation.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    as polyline_algo;

class LocationService {
  // Move API key to app_config.dart
  final String _apiKey = Constants.googleMapsApiKey;

  Future<Position> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await loc.Location().requestService();
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await AppSettings.openAppSettings(type: AppSettingsType.location);
        throw Exception(
            'Location permissions are permanently denied. Please enable in settings.');
      }

      return await Geolocator.getCurrentPosition();
    } catch (e, stack) {
      firebaseCatchLogs(e, stack,
          reason: "Location Service - determinePosition", fatal: true);
      rethrow;
    }
  }

  Future<Placemark> getPlaceMark(Position position) async {
    try {
      List<Placemark> places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (places.isEmpty) {
        throw Exception(
            'No placemark found for coordinates: ${position.latitude}, ${position.longitude}');
      }

      return places.first;
    } catch (e, stack) {
      firebaseCatchLogs(e, stack,
          reason: "Location Service - getPlaceMark", fatal: false);
      rethrow;
    }
  }

  Future<String> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    final url = _buildDistanceMatrixUrl(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch distance: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (!_isValidDistanceMatrixResponse(data)) {
        return "N/A";
      }

      return data['rows'][0]['elements'][0]['distance']['text'].toString();
    } catch (e, stack) {
      firebaseCatchLogs(e, stack,
          reason: "Location Service - calculateDistance", fatal: false);
      debugPrint('Error in calculateDistance: $e');
      return "N/A";
    }
  }

  List<LatLng> decodeGooglePolyline(String encoded) {
    try {
      final List<List<num>> decodedPoints = polyline_algo.decodePolyline(encoded);
      debugPrint('Raw decoded points: ${decodedPoints.length}');
      debugPrint('First raw point: ${decodedPoints.first}');
      
      return decodedPoints.map((point) {
        // The points are already in the correct format, no need to divide
        return LatLng(
          point[0].toDouble(),
          point[1].toDouble(),
        );
      }).toList();
    } catch (e, stack) {
      firebaseCatchLogs(e, stack,
          reason: "Location Service - decodePolyline", fatal: false);
      debugPrint('Error decoding polyline: $e');
      return [];
    }
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    if (!_isValidCoordinates(origin) || !_isValidCoordinates(destination)) {
      debugPrint(
          'Invalid coordinates: Origin(${origin.latitude}, ${origin.longitude}), Destination(${destination.latitude}, ${destination.longitude})');
      throw Exception('Invalid coordinates provided');
    }

    final url = _buildDirectionsUrl(origin, destination);
    debugPrint('Fetching directions from URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Directions API Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Failed to load directions: ${response.body}');
        throw Exception('Failed to load directions: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      debugPrint('Directions API Response: ${data['status']}');

      if (!_isValidDirectionsResponse(data)) {
        debugPrint('Invalid directions response: ${data['status']}');
        if (data['error_message'] != null) {
          debugPrint('Error message: ${data['error_message']}');
        }
        throw Exception('Invalid directions response: ${data['status']}');
      }

      final coordinates = _extractPolylineCoordinates(data);
      debugPrint('Extracted ${coordinates.length} points from polyline');
      return coordinates;
    } catch (e, stack) {
      debugPrint('Error in getDirections: $e');
      debugPrint('Stack trace: $stack');
      firebaseCatchLogs(e, stack,
          reason: "Location Service - getDirections", fatal: false);
      return [];
    }
  }

  bool _isValidCoordinates(LatLng coordinates) {
    return coordinates.latitude >= -90 &&
        coordinates.latitude <= 90 &&
        coordinates.longitude >= -180 &&
        coordinates.longitude <= 180;
  }

  String _buildDirectionsUrl(LatLng origin, LatLng destination) {
    return 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_apiKey';
  }

  String _buildDistanceMatrixUrl(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return 'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?destinations=$startLat,$startLng'
        '&origins=$endLat,$endLng'
        '&key=$_apiKey';
  }

  bool _isValidDirectionsResponse(Map<String, dynamic> data) {
    if (data['status'] != 'OK') {
      debugPrint('Error fetching directions: ${data['status']}');
      if (data['error_message'] != null) {
        debugPrint('Error message: ${data['error_message']}');
      }
      return false;
    }

    if (data['routes'] == null || data['routes'].isEmpty) {
      debugPrint('No routes found in response');
      return false;
    }

    if (data['routes'][0]['legs'] == null ||
        data['routes'][0]['legs'].isEmpty) {
      debugPrint('No legs found in route');
      return false;
    }

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
      firebaseCatchLogs(e, stack,
          reason: "Location Service - extractPolylineCoordinates",
          fatal: false);
      debugPrint('Error extracting polyline coordinates: $e');
      return [];
    }
  }
}
