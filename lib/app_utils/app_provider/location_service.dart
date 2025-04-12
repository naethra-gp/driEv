import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:flutter/foundation.dart';

class LocationService {
  final String _apiKey = 'AIzaSyA1BR25d81VWTluf66WscvlTb_T1kRLQeA';

  Future<Position> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await loc.Location().requestService();
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppSettings.openAppSettings(type: AppSettingsType.location);
        return Future.error('Permission denied, we cannot request again.');
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return Future.error('Error determining position: $e');
    }
  }

  Future<Placemark> getPlaceMark(Position position) async {
    try {
      double lat = position.latitude;
      double lng = position.longitude;
      List<Placemark> place = await placemarkFromCoordinates(lat, lng);
      if (place.isEmpty) {
        throw Exception('No placemark found for coordinates: $lat, $lng');
      }
      return place.first;
    } catch (e) {
      throw Exception('Error fetching placemark: $e');
    }
  }

  Future<String> calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) async {
    String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$startLatitude,$startLongitude&origins=$endLatitude,$endLongitude&key=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'].isEmpty || data['rows'][0]['elements'].isEmpty) {
          return "N/A";
        }
        String distance =
            data['rows'][0]['elements'][0]['distance']['text'].toString();
        return distance;
      } else {
        debugPrint('Error fetching distance: ${response.statusCode}');
        return "N/A";
      }
    } catch (e) {
      debugPrint('Error in calculateDistance: $e');
      return "N/A";
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result >> 1) ^ -(result & 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result >> 1) ^ -(result & 1));
      lng += dlng;

      polyline.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return polyline;
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    // Validate input coordinates
    if (origin == null || destination == null) {
      debugPrint('Origin or destination coordinates are null');
      return [];
    }

    if (origin.latitude < -90 ||
        origin.latitude > 90 ||
        origin.longitude < -180 ||
        origin.longitude > 180 ||
        destination.latitude < -90 ||
        destination.latitude > 90 ||
        destination.longitude < -180 ||
        destination.longitude > 180) {
      debugPrint('Invalid coordinates provided');
      return [];
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ZERO_RESULTS') {
          debugPrint('No route found between locations');
          return [];
        } else if (data['status'] == 'NOT_FOUND') {
          debugPrint('One or both locations not found');
          return [];
        } else if (data['status'] != 'OK') {
          debugPrint('Error fetching directions: ${data['status']}');
          return [];
        }

        if (data['routes'] == null || data['routes'].isEmpty) {
          debugPrint('No routes found in response');
          return [];
        }

        List<LatLng> polylineCoordinates = [];
        List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
        for (var step in steps) {
          String polyline = step['polyline']['points'];
          List<LatLng> decodedPolyline = decodePolyline(polyline);
          polylineCoordinates.addAll(decodedPolyline);
        }

        if (polylineCoordinates.isEmpty) {
          debugPrint('No valid route points decoded');
          return [];
        }

        return polylineCoordinates;
      } else {
        debugPrint('Failed to load directions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error in getDirections: $e');
      return [];
    }
  }
}
