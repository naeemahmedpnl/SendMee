import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/location.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class UserTripProvider extends ChangeNotifier {
  // Socket instance
  late IO.Socket socket;
  
  // Trip State
  String? currentTripId;
  bool isDriverArriving = true;
  bool hasDriverArrived = false;
  bool isTripStarted = false;
  bool isTripCompleted = false;
  
  // Map State
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? driverLocation;
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  
  // Trip Info
  Map<String, dynamic> tripDetails = {};
  String estimatedTime = '';
  double estimatedFare = 0.0;
  
  // Constructor
  UserTripProvider() {
    _initializeSocket();
  }
  
  // Socket Setup
  void _initializeSocket() {
    socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _setupSocketListeners();
  }
  
  void _setupSocketListeners() {
    socket.onConnect((_) {
      log('Socket Connected', name: 'UserTripProvider');
    });

    // Listen for driver location updates
    socket.on('driver_location_updated', (data) {
      log('Driver location update received: $data', name: 'UserTripProvider');
      _handleDriverLocationUpdate(data);
    });

    // Listen for trip status updates
    socket.on('trip_status_update', (data) {
      log('Trip status update received: $data', name: 'UserTripProvider');
      _handleTripStatusUpdate(data);
    });

    socket.onError((error) => 
      log('Socket Error: $error', name: 'UserTripProvider'));
      
    socket.onDisconnect((_) => 
      log('Socket Disconnected', name: 'UserTripProvider'));
  }

  // Initialize Trip
  Future<void> initializeTrip(Map<String, dynamic> initialTripData) async {
    log('Initializing trip with data: $initialTripData', name: 'UserTripProvider');
    
    try {
      currentTripId = initialTripData['tripId'];
      tripDetails = initialTripData;
      
      // Set locations
      pickupLocation = _parseLatLng(initialTripData['pickup']);
      dropoffLocation = _parseLatLng(initialTripData['destination']);
      driverLocation = LatLng(
        initialTripData['driverLocation']['latitude'],
        initialTripData['driverLocation']['longitude']
      );
      
      // Create initial markers and routes
      await _setupMarkersAndRoutes();
      
      // Join socket room for this trip
      socket.emit('join_trip_room', {'tripId': currentTripId});
      
      notifyListeners();
      
    } catch (e) {
      log('Error initializing trip: $e', name: 'UserTripProvider', error: e);
      throw Exception('Failed to initialize trip: $e');
    }
  }

  // Handle Updates
  Future<void> _handleDriverLocationUpdate(Map<String, dynamic> data) async {
    LatLng newDriverLocation = LatLng(data['latitude'], data['longitude']);
    
    // Update driver marker
    _updateDriverMarker(newDriverLocation);
    
    // Update route
    await _updateDriverRoute(newDriverLocation);
    
    // Check if driver has arrived at pickup
    if (!hasDriverArrived && LocationService.isNearPoint(
      newDriverLocation,
      pickupLocation!,
      threshold: 100 // 100 meters
    )) {
      hasDriverArrived = true;
      notifyListeners();
    }
    
    driverLocation = newDriverLocation;
    notifyListeners();
  }

  void _handleTripStatusUpdate(Map<String, dynamic> data) {
    switch(data['status']) {
      case 'started':
        isTripStarted = true;
        isDriverArriving = false;
        break;
      case 'completed':
        isTripCompleted = true;
        break;
      case 'cancelled':
        _handleTripCancellation();
        break;
    }
    notifyListeners();
  }

  // Map Updates
  Future<void> _setupMarkersAndRoutes() async {
    // Create markers
    markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: dropoffLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    // Create routes
    await _updateDriverRoute(driverLocation!);
    await _createPickupToDestinationRoute();
    
    notifyListeners();
  }

  Future<void> _updateDriverRoute(LatLng newDriverLocation) async {
    LatLng targetLocation = isTripStarted ? dropoffLocation! : pickupLocation!;
    
    List<LatLng> routePoints = await LocationService.getPolylinePoints(
      newDriverLocation,
      targetLocation
    );
    
    polylines.removeWhere((p) => p.polylineId.value == 'driver_route');
    polylines.add(Polyline(
      polylineId: const PolylineId('driver_route'),
      points: routePoints,
      color: Colors.blue,
      width: 3,
    ));
  }

  Future<void> _createPickupToDestinationRoute() async {
    List<LatLng> routePoints = await LocationService.getPolylinePoints(
      pickupLocation!,
      dropoffLocation!
    );
    
    polylines.add(Polyline(
      polylineId: const PolylineId('trip_route'),
      points: routePoints,
      color: Colors.red,
      width: 3,
    ));
  }

  void _updateDriverMarker(LatLng position) {
    markers.removeWhere((m) => m.markerId.value == 'driver');
    markers.add(Marker(
      markerId: const MarkerId('driver'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));
  }

  // Helper Methods
  LatLng _parseLatLng(String latLngString) {
    List<String> parts = latLngString.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  void _handleTripCancellation() {
    isDriverArriving = false;
    isTripStarted = false;
    socket.disconnect();
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}