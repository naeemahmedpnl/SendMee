

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendme/views/Driver_panel/ride_screens/location.dart';
import 'dart:developer' as developer;

class TripProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  int _currentRouteIndex = 0;
  bool _isMovingToPickup = true;
  bool _isNearDestination = false;
  bool _hasArrivedAtDestination = false;
  bool _hasPickedUpPassenger = false;
  LatLng? _driverPosition;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  bool _isNear500m = false;
  bool _isRideEnded = false;
  bool _isArrivalConfirmed = false;



  bool get isNear500m => _isNear500m;
  bool get isRideEnded => _isRideEnded;
  bool get isArrivalConfirmed => _isArrivalConfirmed;

  // Getters
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  List<LatLng> get routePoints => _routePoints;
  int get currentRouteIndex => _currentRouteIndex;
  bool get isMovingToPickup => _isMovingToPickup;
  bool get isNearDestination => _isNearDestination;
  bool get hasArrivedAtDestination => _hasArrivedAtDestination;
  bool get hasPickedUpPassenger => _hasPickedUpPassenger;
  LatLng? get driverPosition => _driverPosition;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get dropoffLocation => _dropoffLocation;

  void updateDriverPosition(LatLng newPosition) {
    developer.log('Updating driver position: $newPosition');
    _driverPosition = newPosition;
    _updateMarkers();
    _checkNearDestination();
    notifyListeners();
  }

   void setIsNear500m(bool value) {
    _isNear500m = value;
    notifyListeners();
  }

  void _updateMarkers() {
    developer.log('Updating markers');
    _markers.removeWhere((marker) => marker.markerId.value == 'driver');
    if (_driverPosition != null) {
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Driver Location'),
      ));
    }
  }


 void _checkNearDestination() {
  if (_routePoints.isNotEmpty && _driverPosition != null) {
    LatLng? targetPoint = _isMovingToPickup ? _pickupLocation : _dropoffLocation;
    if (targetPoint != null) {
      bool isNear = LocationService.isNearPoint(_driverPosition!, targetPoint, threshold: 100);
      if (isNear && !_isNearDestination) {
        _isNearDestination = true;
        notifyListeners();
      }
      
      // Check for 500m proximity
      bool isNear500m = LocationService.isNearPoint(_driverPosition!, targetPoint, threshold: 500);
      if (isNear500m != _isNear500m) {
        _isNear500m = isNear500m;
        notifyListeners();
      }
    } else {
      developer.log('Warning: Target point is null. isMovingToPickup: $_isMovingToPickup');
    }
  }
}

  void setIsMovingToPickup(bool value) {
    developer.log('Setting isMovingToPickup: $value');
    _isMovingToPickup = value;
    _isNearDestination = false;  
    notifyListeners();
  }

  void setIsNearDestination(bool value) {
    developer.log('Setting isNearDestination: $value');
    _isNearDestination = value;
    notifyListeners();
  }

 void setArrivedAtDestination(bool value) {
    _hasArrivedAtDestination = value;
    if (value) {
      _isNearDestination = false;
      _isMovingToPickup = false;
    }
    notifyListeners();
  }

  void setPickedUpPassenger(bool value) {
    developer.log('Setting hasPickedUpPassenger: $value');
    _hasPickedUpPassenger = value;
    setIsMovingToPickup(false);  // Switch to dropoff navigation
    notifyListeners();
  }

  void setRoutePoints(List<LatLng> points) {
    developer.log('Setting route points: ${points.length} points');
    _routePoints = points;
    notifyListeners();
  }

  void updateCurrentRouteIndex() {
    if (_currentRouteIndex < _routePoints.length - 1) {
      _currentRouteIndex++;
      developer.log('Updated current route index: $_currentRouteIndex');
      notifyListeners();
    }
  }

  void setPolylines(Set<Polyline> newPolylines) {
    developer.log('Setting polylines: ${newPolylines.length} polylines');
    _polylines = newPolylines;
    notifyListeners();
  }

  void setMarkers(Set<Marker> newMarkers) {
    developer.log('Setting markers: ${newMarkers.length} markers');
    _markers = newMarkers;
    notifyListeners();
  }

  void initializeTrip(LatLng pickup, LatLng dropoff) {
    developer.log('Initializing trip: Pickup - $pickup, Dropoff - $dropoff');
    _pickupLocation = pickup;
    _dropoffLocation = dropoff;
    _isMovingToPickup = true;
    _isNearDestination = false;
    _hasArrivedAtDestination = false;
    _hasPickedUpPassenger = false;
    _currentRouteIndex = 0;
    notifyListeners();
  }
}