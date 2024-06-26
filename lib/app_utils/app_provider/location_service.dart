import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

class LocationService {
  final String _apiKey = 'AIzaSyA1BR25d81VWTluf66WscvlTb_T1kRLQeA';

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await loc.Location().requestService();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark> getPlaceMark(Position position) async {
    double lat = position.latitude;
    double lng = position.longitude;
    List<Placemark> place = await placemarkFromCoordinates(lat, lng);
    return place.first;
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    return distanceInMeters / 1000; // Convert meters to kilometers
  }

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> polylineCoordinates = [];
        var steps = data['routes'][0]['legs'][0]['steps'];

        for (var step in steps) {
          var startLocation = step['start_location'];
          var endLocation = step['end_location'];
          polylineCoordinates
              .add(LatLng(startLocation['lat'], startLocation['lng']));
          polylineCoordinates
              .add(LatLng(endLocation['lat'], endLocation['lng']));
        }
        return polylineCoordinates;
      } else {
        throw Exception('Error fetching directions: ${data['status']}');
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
