import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapProvider with ChangeNotifier {
  String _mapTheme = "";
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;

  String get mapTheme => _mapTheme;
  LatLng? get pickupLocation => _pickupLocation;
  LatLng? get dropoffLocation => _dropoffLocation;

  void setMapTheme(String theme) {
    _mapTheme = theme;
    notifyListeners();
  }

  void setPickupLocation(LatLng location) {
    _pickupLocation = location;
    notifyListeners();
  }

  void setDropoffLocation(LatLng location) {
    _dropoffLocation = location;
    notifyListeners();
  }
}
