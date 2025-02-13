import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  LatLng? _selectedLocation;
  String _address = '';

  LatLng? get selectedLocation => _selectedLocation;
  String get address => _address;

  void setSelectedLocation(LatLng? location) {
    _selectedLocation = location;
    _updateAddress();
    notifyListeners();
  }

   void setAddress(String address) {
    _address = address;
    notifyListeners();
  }

  Future<void> _updateAddress() async {
    if (_selectedLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          _address = '${place.street}, ${place.locality}, ${place.country}';
        }
      } catch (e) {
        print("Error getting address: $e");
        _address = '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}';
      }
    }
  }

  Future<void> saveLocation(bool isPickup) async {
    if (_selectedLocation != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('${isPickup ? 'pickup' : 'dropoff'}_lat', _selectedLocation!.latitude);
      await prefs.setDouble('${isPickup ? 'pickup' : 'dropoff'}_lng', _selectedLocation!.longitude);
    }
  }

  Future<void> loadSavedLocation(bool isPickup) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble('${isPickup ? 'pickup' : 'dropoff'}_lat');
    double? lng = prefs.getDouble('${isPickup ? 'pickup' : 'dropoff'}_lng');
    if (lat != null && lng != null) {
      _selectedLocation = LatLng(lat, lng);
      await _updateAddress();
      notifyListeners();
    }
  }
}
