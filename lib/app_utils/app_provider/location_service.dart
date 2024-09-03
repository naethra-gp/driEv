import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

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

  Future<String> calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=$startLatitude,$startLongitude&origins=$endLatitude,$endLongitude&key=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'].isEmpty || data['rows'][0]['elements'].isEmpty) {
          throw Exception('Invalid response from Distance Matrix API');
        }
        String distance = data['rows'][0]['elements'][0]['distance']['text'].toString();
        return distance;
      } else {
        throw Exception('Error fetching distance: ${response.statusCode}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<LatLng> polylineCoordinates = [];
          var steps = data['routes'][0]['legs'][0]['steps'];
          for (var step in steps) {
            var startLocation = step['start_location'];
            var endLocation = step['end_location'];
            polylineCoordinates.add(LatLng(startLocation['lat'], startLocation['lng']));
            polylineCoordinates.add(LatLng(endLocation['lat'], endLocation['lng']));
          }
          return polylineCoordinates;
        } else {
          throw Exception('Error fetching directions: ${data['status']}');
        }
      } else {
        throw Exception('Failed to load directions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
