// location_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math.dart' as vector;

class LocationService {
  static const String _apiKey = 'AIzaSyBdbZLVOJf6x4kUv2xPEWZOYOVBifSBzwc';
  static LatLng calculateNewPosition(LatLng current, LatLng next) {
    const stepSize = 0.00001; // Adjust based on your needs

    double heading = calculateBearing(current, next);

    double lat = current.latitude + (stepSize * cos(vector.radians(heading)));
    double lng = current.longitude + (stepSize * sin(vector.radians(heading)));

    return LatLng(lat, lng);
  }

  static double calculateBearing(LatLng start, LatLng end) {
    double lat1 = vector.radians(start.latitude);
    double lng1 = vector.radians(start.longitude);
    double lat2 = vector.radians(end.latitude);
    double lng2 = vector.radians(end.longitude);

    double dLng = lng2 - lng1;

    double y = sin(dLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

    double bearing = vector.degrees(atan2(y, x));
    return bearing < 0 ? bearing + 360 : bearing;
  }

  static bool isNearPoint(LatLng position, LatLng target,
      {double threshold = 50}) {
    double distance = calculateDistance(position, target);
    return distance <= threshold;
  }

  static double calculateDistance(LatLng point1, LatLng point2) {
    // Implementation of distance calculation using Haversine formula
    double lat1 = vector.radians(point1.latitude);
    double lng1 = vector.radians(point1.longitude);
    double lat2 = vector.radians(point2.latitude);
    double lng2 = vector.radians(point2.longitude);

    double dLat = lat2 - lat1;
    double dLng = lng2 - lng1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return 6371000 * c; // Earth's radius in meters * c
  }

  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
    print('Error getting current location: $e');
      rethrow;
    }
  }

  static Future<String> getAddressFromLatLng(String latLng) async {
    final coordinates = latLng.split(',');
    final lat = coordinates[0];
    final lng = coordinates[1];

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse['results'].isNotEmpty) {
          return decodedResponse['results'][0]['formatted_address'];
        }
      }

      return 'Address not found';
    } catch (e) {
      log('Error getting address: $e' as num);
      return 'Error occurred while fetching address';
    }
  }

  static Future<Map<String, String>> calculateDistanceAndTime(
      LatLng origin, LatLng destination) async {
    final distanceInMeters = Geolocator.distanceBetween(origin.latitude,
        origin.longitude, destination.latitude, destination.longitude);

    final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);

    // Assuming an average speed of 40 km/h for simplicity
    final timeInHours = distanceInMeters / 40000;
    final timeInMinutes = (timeInHours * 60).round();

    return {
      'distance': '$distanceInKm km',
      'duration': '$timeInMinutes min',
    };
  }

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
        log('Error getting polyline: ${result.errorMessage}' as num);
        throw Exception('Error getting route: ${result.errorMessage}');
      } else {
        log('No route found between the specified points' as num);
        return [start, end];
      }
    } catch (e) {
      log('Exception in getPolylinePoints: $e' as num);
      return [start, end];
    }
  }

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
