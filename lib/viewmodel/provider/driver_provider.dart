
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideBookingProvider with ChangeNotifier {
  bool _isOnline = false;
  bool _isFetchingEnabled = true;
  String _mapTheme = "";
  List<Map<String, dynamic>> _rideRequests = [];
  Position? _currentPosition;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  final Set<String> _seenTripIds = {};
  bool _isRelevantScreenActive = false;

  bool get isOnline => _isOnline;
  String get mapTheme => _mapTheme;
  List<Map<String, dynamic>> get rideRequests => _rideRequests;
  Position? get currentPosition => _currentPosition;
  String get baseUrl => Constants.apiBaseUrl;

  void setMapTheme(String theme) {
    _mapTheme = theme;
    notifyListeners();
  }

  void setPickupLocation(LatLng location) {
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    log("Getting current location");
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      log("Current position updated - Lat: ${position.latitude}, Lng: ${position.longitude}");
      // Only notify if the screen is active
      if (_isRelevantScreenActive) {
        notifyListeners();
      }
    } catch (e) {
      log("Error getting current location: $e");
    }
  }

  Future<void> initializeData() async {
    log("Initializing data");
    await _fetchUserData();
    await getCurrentLocation();
  }

  void resumeFetching() {
    if (_isOnline) {
      log("Resuming fetch operations");
      _isFetchingEnabled = true;
      _isRelevantScreenActive = true;
      _startFetchingTrips();
    }
  }

  Future<void> goOnline() async {
    log("Going online");
    _isOnline = true;
    _isFetchingEnabled = true;
    _isRelevantScreenActive = true;
    
    // Clear old requests when going online
    _rideRequests.clear();
    _seenTripIds.clear();
    
    notifyListeners();
    
    await getCurrentLocation();
    await _fetchTrips();
    _startFetchingTrips();
  }

  void goOffline() {
    log("Going offline");
    _isOnline = false;
    _isFetchingEnabled = false;
    _isRelevantScreenActive = false;
    _rideRequests.clear();
    _seenTripIds.clear();
    _stopFetchingTrips();
    notifyListeners();
  }

  // Modified to use Future.microtask for state updates
  void setRelevantScreenActive(bool isActive) {
    log("Setting screen active: $isActive");
    
    // Use Future.microtask to defer the state update
    Future.microtask(() {
      _isRelevantScreenActive = isActive;
      
      if (isActive && _isOnline) {
        _isFetchingEnabled = true;
        _startFetchingTrips();
      } else {
        _stopFetchingTrips();
      }
      
      notifyListeners();
    });
  }

  void _startFetchingTrips() {
    log("Starting to fetch trips");
    log("Conditions - Online: $_isOnline, Fetching Enabled: $_isFetchingEnabled, Screen Active: $_isRelevantScreenActive");
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (_isOnline && _isFetchingEnabled && _isRelevantScreenActive) {
        log("Fetching trips in timer");
        await getCurrentLocation();
        await _fetchTrips();
      } else {
        log("Skipping fetch - Online: $_isOnline, Fetching: $_isFetchingEnabled, Active: $_isRelevantScreenActive");
      }
    });
  }

  void _stopFetchingTrips() {
    log("Stopping trip fetching");
    _timer?.cancel();
    _timer = null;
  }
  
  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      log("Token not found");
      return;
    }

    final url = Uri.parse('${Constants.apiBaseUrl}/auth/user');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('user_data', jsonEncode(data));
        log("User data stored in SharedPreferences");
      } else {
        log("Failed to fetch user data: ${response.statusCode}");
      }
    } catch (error) {
      log("Error fetching user data: $error");
    }
  }

  Future<void> _fetchTrips() async {
    if (!_isFetchingEnabled) {
      log("Fetch trips called but fetching is disabled");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse('${Constants.apiBaseUrl}/trip/get-trips');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "lat": _currentPosition?.latitude ?? 0,
          "lng": _currentPosition?.longitude ?? 0
        }),
      );

      if (response.statusCode == 200) {
        final dynamic decodedResponse = jsonDecode(response.body);
        log("Fetched trips: $decodedResponse");
        if (decodedResponse is List) {
          bool hasNewTrips = false;
          List<Map<String, dynamic>> newRideRequests = [];

          for (var trip in decodedResponse) {
            String tripId = _getTripIdentifier(trip);
            Map<String, dynamic> processedTrip = _processTrip(trip);
            newRideRequests.add(processedTrip);

            if (!_seenTripIds.contains(tripId)) {
              _seenTripIds.add(tripId);
              hasNewTrips = true;
            }
          }

          _rideRequests = newRideRequests;

          if (hasNewTrips) {
            await _playAlarmSound();
          }

          notifyListeners();
        }
      }
    } catch (e) {
      log("Exception in _fetchTrips: $e");
    }
  }

  String _getTripIdentifier(Map<String, dynamic> trip) {
    if (trip['_id'] != null) {
      return trip['_id'].toString();
    }

    final result = trip['result'] as Map<String, dynamic>? ?? {};
    final user = trip['user'] as Map<String, dynamic>? ?? {};
    return '${user['username'] ?? ''}_${result['pickupAddress'] ?? ''}_${result['destinationAddress'] ?? ''}';
  }

  Map<String, dynamic> _processTrip(Map<String, dynamic> trip) {
    final result = trip['result'] as Map<String, dynamic>? ?? {};
    final user = trip['user'] as Map<String, dynamic>? ?? {};

    return {
      'displayData': {
        'username': user['username'] ?? 'Unknown User',
        'email': user['email'] ?? 'No email provided',
        'profilePicture': user['profilePicture'] ?? '',
        'estimatedFare': result['estimatedFare']?.toString() ?? 'N/A',
        'pickupAddress': result['pickupAddress'] ?? 'N/A',
        'destinationAddress': result['destinationAddress'] ?? 'N/A',
        'vehicleType': result['vehicleType'] ?? 'N/A',
        'serviceType': trip['result']['serviceType'] ,
      'parcelType': trip['result']['parcelType'],
      },
      'fullData': trip,
    };
  }

  void removeRideRequest(Map<String, dynamic> ride) {
    _rideRequests.remove(ride);
    notifyListeners();
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.play(AssetSource('sound/notifications.wav'));
    } catch (e) {
      log("Error playing alarm sound: $e");
    }
  }

  @override
  void dispose() {
    _stopFetchingTrips();
    _audioPlayer.dispose();
    super.dispose();
  }
}