// import 'package:flutter/foundation.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:rideapp/utils/location_utils.dart';

// class LocationProvider with ChangeNotifier {
//   // GET POLYLINE POINTS
//   Future<List<LatLng>> getPolylinePoints(LatLng start, LatLng end) async {
//     return await LocationUtils.getPolylinePoints(start, end);
//   }

//   // CALCULATE DRIVER TO PICKUP DISTANCE AND TIME
//   Future<Map<String, String>> calculateDriverToPickupDistanceAndTime(LatLng driverLocation, LatLng pickupLocation) async {
//     return await LocationUtils.calculateDriverToPickupDistanceAndTime(driverLocation, pickupLocation);
//   }

//   // CALCULATE BOUNDS
//   LatLngBounds calculateBounds(List<LatLng> positions) {
//     return LocationUtils.calculateBounds(positions);
//   }
// }