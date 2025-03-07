import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationUtils {
  // GOOGLE MAPS API KEY
  static final _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  // GET CURRENT LOCATION
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // CHECK IF LOCATION SERVICES ARE ENABLED
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // CHECK LOCATION PERMISSIONS
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // GET CURRENT POSITION
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      // log('Error getting current location: $e');
      rethrow;
    }
  }

  // In location_utils.dart
  static Future<double> calculateDistance(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) async {
    try {
      // Using Haversine formula to calculate distance
      const double earthRadius = 6371000; // Earth's radius in meters

      // Convert latitude and longitude from degrees to radians
      double lat1 = startLatitude * (pi / 180);
      double lon1 = startLongitude * (pi / 180);
      double lat2 = endLatitude * (pi / 180);
      double lon2 = endLongitude * (pi / 180);

      // Differences in coordinates
      double dLat = lat2 - lat1;
      double dLon = lon2 - lon1;

      // Haversine formula
      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double distance = earthRadius * c;

      return distance; // Returns distance in meters
    } catch (e) {
      // log('Error calculating distance: $e');
      return double.infinity;
    }
  }

  // GET ADDRESS FROM LATITUDE AND LONGITUDE
  static Future<String> getAddressFromLatLng(String latLng) async {
    final coordinates = latLng.split(',');
    final lat = coordinates[0];
    final lng = coordinates[1];

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse['results'].isNotEmpty) {
        return decodedResponse['results'][0]['formatted_address'];
      }
    }

    return 'Address not found';
  }

  // CALCULATE DISTANCE AND TIME BETWEEN TWO POINTS
  static Future<Map<String, String>> calculateDistanceAndTime(
      String originLatLng, String destinationLatLng) async {
    final originCoords = originLatLng.split(',');
    final destCoords = destinationLatLng.split(',');

    final originLat = double.parse(originCoords[0]);
    final originLng = double.parse(originCoords[1]);
    final destLat = double.parse(destCoords[0]);
    final destLng = double.parse(destCoords[1]);

    final distanceInMeters =
        Geolocator.distanceBetween(originLat, originLng, destLat, destLng);

    final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);

    // ASSUMING AN AVERAGE SPEED OF 40 KM/H FOR SIMPLICITY
    final timeInHours = distanceInMeters / 4000;
    final timeInMinutes = (timeInHours * 30).round();

    return {
      'distance': '$distanceInKm km',
      'duration': '$timeInMinutes min',
    };
  }

  // New function to calculate distance and time from driver to pickup
  static Future<Map<String, String>> calculateDriverToPickupDistanceAndTimeV2(
      LatLng driverLocation, LatLng pickupLocation) async {
    final distanceInMeters = Geolocator.distanceBetween(
        driverLocation.latitude,
        driverLocation.longitude,
        pickupLocation.latitude,
        pickupLocation.longitude);

    final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);

    // Assuming an average speed of 40 km/h for simplicity
    final timeInHours = distanceInMeters / 40000;
    final timeInMinutes = (timeInHours * 60).round();

    return {
      'distance': '$distanceInKm km',
      'duration': '$timeInMinutes min',
    };
  }

// CALCULATE DISTANCE AND TIME FROM DRIVER TO PICKUP
  static Future<Map<String, String>> calculateDriverToPickupDistanceAndTime(
      LatLng driverLocation, LatLng pickupLocation) async {
    final distanceInMeters = Geolocator.distanceBetween(
        driverLocation.latitude,
        driverLocation.longitude,
        pickupLocation.latitude,
        pickupLocation.longitude);

    final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);

    // ASSUMING AN AVERAGE SPEED OF 40 KM/H FOR SIMPLICITY
    final timeInHours = distanceInMeters / 40000;
    final timeInMinutes = (timeInHours * 60).round();

    return {
      'distance': '$distanceInKm km',
      'duration': '$timeInMinutes min',
    };
  }

  // GET DIRECTIONS BETWEEN TWO POINTS
  static Future<List<LatLng>> getPolylinePoints(
      LatLng start, LatLng end) async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: _apiKey,
          request: PolylineRequest(
              origin: PointLatLng(start.latitude, start.longitude),
              destination: PointLatLng(end.latitude, end.longitude),
              mode: TravelMode.driving));

      if (result.points.isNotEmpty) {
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } else if (result.errorMessage != null &&
          result.errorMessage!.isNotEmpty) {
        // log('ERROR GETTING POLYLINE: ${result.errorMessage}');
        throw Exception('ERROR GETTING ROUTE: ${result.errorMessage}');
      } else {
        // log('NO ROUTE FOUND BETWEEN THE SPECIFIED POINTS');

        return [start, end];
      }
    } catch (e) {
      // log('EXCEPTION IN getPolylinePoints: $e');
      return [start, end];
    }
  }

  // CALCULATE BOUNDS FOR MULTIPLE LATLNG POINTS
  static LatLngBounds calculateBounds(List<LatLng> positions) {
    double minLat = positions[0].latitude;
    double maxLat = positions[0].latitude;
    double minLng = positions[0].longitude;
    double maxLng = positions[0].longitude;

    for (var pos in positions) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
