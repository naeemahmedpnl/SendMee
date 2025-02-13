

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TripProvider extends ChangeNotifier {
  Map<String, dynamic>? _acceptedDriverData;
  bool _isDriverAccepted = false;
  bool _isLoading = false;
  late IO.Socket socket;

  Map<String, dynamic>? get acceptedDriverData => _acceptedDriverData;
  bool get isDriverAccepted => _isDriverAccepted;
  bool get isLoading => _isLoading;

  TripProvider() {
    _initSocket();
  }

  void _initSocket() {
    dev.log('TripProvider - Initializing socket');
    socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket.connect();

    socket.on('connect', (_) {
      dev.log('TripProvider - Socket connected');
    });

    socket.on('driver_accepted_trip', (data) {
      dev.log('TripProvider - Driver accepted trip: ${json.encode(data)}');
      setDriverAccepted(data);
    });

    socket.on('driver_location_updated', (data) {
      dev.log('TripProvider - Driver location updated: ${json.encode(data)}');
      updateDriverLocation(data);
    });

    socket.on('disconnect', (_) {
      dev.log('TripProvider - Socket disconnected');
    });

    socket.on('connect_error', (error) {
      dev.log('TripProvider - Socket connection error: $error');
    });

    socket.on('error', (error) {
      dev.log('TripProvider - Socket error: $error');
    });

    dev.log('TripProvider - Socket initialization completed');
  }

  void setDriverAccepted(Map<String, dynamic> data) {
    dev.log('TripProvider - Setting driver as accepted: ${json.encode(data)}');
    _acceptedDriverData = data;
    _isDriverAccepted = true;
    notifyListeners();
    dev.log('TripProvider - Driver accepted state updated');
  }

  void updateDriverLocation(Map<String, dynamic> data) {
    dev.log('TripProvider - Updating driver location: ${json.encode(data)}');
    if (_acceptedDriverData != null) {
      _acceptedDriverData!['driverLocation'] = data['location'];
      notifyListeners();
      dev.log('TripProvider - Driver location updated in acceptedDriverData');
    } else {
      dev.log('TripProvider - Unable to update driver location: acceptedDriverData is null');
    }
  }

  Future<void> acceptDriverOffer(String tripId) async {
    dev.log('TripProvider - Accepting driver offer for trip: $tripId');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        dev.log('TripProvider - No token found');
        throw Exception('No token found');
      }

      final response = await http.put(
        Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      dev.log('TripProvider - Server response status code: ${response.statusCode}');
      dev.log('TripProvider - Server response body: ${response.body}');

      if (response.statusCode == 200) {
        dev.log('TripProvider - Trip accepted successfully');
        final responseData = jsonDecode(response.body);
        
        if (responseData['tripDetails'] != null) {
          _acceptedDriverData = responseData['tripDetails'];
          _isDriverAccepted = true;
          dev.log('TripProvider - Accepted driver data updated: ${json.encode(_acceptedDriverData)}');
        } else {
          dev.log('TripProvider - Unexpected response structure: ${response.body}');
          throw Exception('Unexpected response structure');
        }
      } else {
        dev.log('TripProvider - Failed to accept trip: ${response.body}');
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to accept trip');
      }
    } catch (e) {
      dev.log('TripProvider - Error accepting trip: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      dev.log('TripProvider - Trip acceptance process completed');
    }
  }

  void reset() {
    dev.log('TripProvider - Resetting provider state');
    _acceptedDriverData = null;
    _isDriverAccepted = false;
    _isLoading = false;
    notifyListeners();
    dev.log('TripProvider - Provider state reset completed');
  }

  @override
  void dispose() {
    dev.log('TripProvider - Disposing provider');
    socket.disconnect();
    dev.log('TripProvider - Socket disconnected');
    super.dispose();
  }
}