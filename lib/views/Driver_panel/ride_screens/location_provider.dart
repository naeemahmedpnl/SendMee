
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
// import 'package:rideapp/views/Driver_panel/ride_screens/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripProvider extends ChangeNotifier {
  // Socket instance
  late IO.Socket socket;

  // Base URL
  String get baseUrl => Constants.apiBaseUrl;

  // Trip State
  String? currentTripId;
  bool isMovingToPickup = true;
  bool hasPickedUpPassenger = false;
  bool isNear500m = false;
  bool hasArrivedAtDestination = false;

  // Map State
  List<LatLng> routePoints = [];
  int currentRouteIndex = 0;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? driverPosition;

  TripProvider() {
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      debugPrint('Socket Connected');
      // Listen for any trip updates from passenger
      socket.on('trip_status_update', _handleTripStatusUpdate);
    });

    socket.onError((error) => debugPrint('Socket Error: $error'));
    socket.onDisconnect((_) => debugPrint('Socket Disconnected'));
  }

  void _handleTripStatusUpdate(dynamic data) {
    if (data['status'] == 'cancelled') {
      hasArrivedAtDestination = true;
      notifyListeners();
    }
  }


  // API Methods
  Future<void> startTrip(
      String tripId, LatLng pickupLocation, LatLng dropoffLocation) async {
    log('Starting trip', name: 'TripProvider');
    log('Trip ID: $tripId', name: 'TripProvider');
    log('Pickup Location: ${pickupLocation.latitude},${pickupLocation.longitude}',
        name: 'TripProvider');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trip/start/$tripId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': driverPosition?.latitude,
          'longitude': driverPosition?.longitude,
        }),
      );

      if (response.statusCode == 200) {
        log('Trip started successfully', name: 'TripProvider');
        currentTripId = tripId;
        hasPickedUpPassenger = true;
        isMovingToPickup = false;
        notifyListeners();
      } else {
        log('Failed to start trip: ${response.body}',
            name: 'TripProvider', error: true);
        throw Exception('Failed to start trip: ${response.body}');
      }
    } catch (e) {
      log('Start trip API error', name: 'TripProvider', error: e);
      throw Exception('Start trip API error: $e');
    }
  }

  Future<void> updateDriverLocationAPI(String tripId, LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      log("Token for API call: $token");

      if (token == null) {
        log("Token not found");
        return;
      };

    log('Updating driver location', name: 'TripProvider');
    log('Current Position: ${position.latitude},${position.longitude}',
        name: 'TripProvider');
    log('Moving to ${isMovingToPickup ? "Pickup" : "Destination"}',
        name: 'TripProvider');

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trip/update-driver-location/$tripId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        log('Location updated successfully', name: 'TripProvider');
        driverPosition = position;
        _updateDriverMarker(position);
        notifyListeners();
      } else {
        log('Failed to update location: ${response.body}',
            name: 'TripProvider', error: true);
        throw Exception('Failed to update location: ${response.body}');
      }
    } catch (e) {
      log('Update location API error', name: 'TripProvider', error: e);
      throw Exception('Update location API error: $e');
    }
  }

  Future<void> endTripAPI() async {
    log('Ending trip', name: 'TripProvider');
    log('Trip ID: $currentTripId', name: 'TripProvider');

    try {
      if (currentTripId == null) {
        log('No active trip to end', name: 'TripProvider', error: true);
        throw Exception('No active trip');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/trip/completed/$currentTripId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        log('Trip completed successfully', name: 'TripProvider');
        hasArrivedAtDestination = true;
        notifyListeners();
      } else {
        log('Failed to complete trip: ${response.body}',
            name: 'TripProvider', error: true);
        throw Exception('Failed to complete trip: ${response.body}');
      }
    } catch (e) {
      log('Complete trip API error', name: 'TripProvider', error: e);
      throw Exception('Complete trip API error: $e');
    }
  }

  // Enhanced State Methods with Logging
  void setPickedUpPassenger(bool status) {
    log('Setting pickupPassenger: $status', name: 'TripProvider');
    hasPickedUpPassenger = status;
    isMovingToPickup = !status;
    notifyListeners();
  }

  void setIsNear500m(bool status) {
    log('Setting isNear500m: $status', name: 'TripProvider');
    isNear500m = status;
    notifyListeners();
  }

  // Map Update Methods
  void _updateDriverMarker(LatLng position) {
    markers.removeWhere((marker) => marker.markerId.value == 'driver');
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Driver Location'),
      ),
    );
  }

  // State Update Methods
  void updateDriverPosition(LatLng newPosition) {
    driverPosition = newPosition;
    _updateDriverMarker(newPosition);
    notifyListeners();
  }

  void setRoutePoints(List<LatLng> points) {
    routePoints = points;
    notifyListeners();
  }

  void setMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    notifyListeners();
  }

  void setPolylines(Set<Polyline> newPolylines) {
    polylines = newPolylines;
    notifyListeners();
  }

  void setArrivedAtDestination(bool status) {
    hasArrivedAtDestination = status;
    notifyListeners();
  }
}
