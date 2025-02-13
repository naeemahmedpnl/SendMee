
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/models/rates_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sendme/utils/constant/api_base_url.dart';

enum TripType { ride, parcel }

class RideProvider extends ChangeNotifier {
  String _pickupAddress = '';
  String _dropoffAddress = '';
  LatLng? _pickupLatLng;
  LatLng? _dropoffLatLng;
  String? _estimatedFare;
  TripType _tripType = TripType.ride;
  Rates? _rates;

  // Passenger details
  String? _passengerId;
  String? _passengerFullName;
  String? _passengerProfilePicture;
  int? _passengerVersion;

  // Getters remain the same
  String get pickupAddress => _pickupAddress;
  String get dropoffAddress => _dropoffAddress;
  LatLng? get pickupLatLng => _pickupLatLng;
  LatLng? get dropoffLatLng => _dropoffLatLng;
  String? get estimatedFare => _estimatedFare;
  TripType get tripType => _tripType;
  Rates? get rates => _rates;
  String? get passengerId => _passengerId;
  String? get passengerFullName => _passengerFullName;
  String? get passengerProfilePicture => _passengerProfilePicture;
  int? get passengerVersion => _passengerVersion;

  bool get isRouteComplete => _pickupLatLng != null && _dropoffLatLng != null;

  // Clear all data - comprehensive method
  void clearAllData() {
    _pickupAddress = '';
    _dropoffAddress = '';
    _pickupLatLng = null;
    _dropoffLatLng = null;
    _estimatedFare = null;
    _tripType = TripType.ride; // Reset to default trip type
    // Don't clear _rates as they are global settings

    // Clear passenger details
    _passengerId = null;
    _passengerFullName = null;
    _passengerProfilePicture = null;
    _passengerVersion = null;

    notifyListeners();
    log('All ride data cleared');
  }

  // Your existing methods
  void setPickupLocation(String address, LatLng latLng) {
    _pickupAddress = address;
    _pickupLatLng = latLng;
    notifyListeners();
    log('Pickup location set: $address');
  }

  void setDropoffLocation(String address, LatLng latLng) {
    _dropoffAddress = address;
    _dropoffLatLng = latLng;
    notifyListeners();
    log('Dropoff location set: $address');
  }

  void setEstimatedFare(String fare) {
    _estimatedFare = fare;
    notifyListeners();
    log('Estimated fare set: $fare');
  }

  void setTripType(TripType type) {
    _tripType = type;
    notifyListeners();
    log('Trip type set to: $type');
  }

  // Clear specific data sets
  void clearLocationData() {
    _pickupAddress = '';
    _dropoffAddress = '';
    _pickupLatLng = null;
    _dropoffLatLng = null;
    notifyListeners();
    log('Location data cleared');
  }

  void clearFareData() {
    _estimatedFare = null;
    notifyListeners();
    log('Fare data cleared');
  }

  void clearPassengerData() {
    _passengerId = null;
    _passengerFullName = null;
    _passengerProfilePicture = null;
    _passengerVersion = null;
    notifyListeners();
    log('Passenger data cleared');
  }

  Future<Map<String, dynamic>> fetchPassengerData() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('userData')) {
      String? userDataJson = prefs.getString('userData');
      if (userDataJson != null) {
        Map<String, dynamic> userData = jsonDecode(userDataJson);
        return {
          'id': userData['_id'],
          'name': userData['username'] ?? 'Unknown',
        };
      }
    }
    return {'id': null, 'name': 'Unknown'};
  }



  Future<Map<String, dynamic>> createTripRequest() async {
    log('Starting createTripRequest function');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userDataString = prefs.getString('userData');
      final serviceType = prefs.getString('serviceType') ?? 'parcel';

      // Validate user data exists
      if (userDataString == null) {
        log('User data not found in SharedPreferences');
        return {'success': false, 'message': 'User data not found'};
      }

      // Parse user data
      final userData = json.decode(userDataString) as Map<String, dynamic>;
      final passengerId = userData['_id'];
      final userName = userData['username'];
      final userPhone = userData['phone'];

      // Log user details
      log('PassengerId: $passengerId');
      log('UserName: $userName');
      log('UserPhone: $userPhone');
      log('Token: $token, UserData: $userData, ServiceType: $serviceType');

      // Validate authentication
      if (token == null || passengerId == null) {
        log('Authentication error: Token or PassengerId is null');
        return {
          'success': false,
          'message': 'Authentication error. Please log in again.'
        };
      }

      // Validate locations
      if (_dropoffLatLng == null || _pickupLatLng == null) {
        log('Location error: Pickup or dropoff location is null');
        return {
          'success': false,
          'message': 'Please select both pickup and dropoff locations.'
        };
      }

      // Base request body
      Map<String, dynamic> requestBody = {
        'passenger': passengerId,
        'destination':
            '${_dropoffLatLng!.latitude}, ${_dropoffLatLng!.longitude}',
        'pickup': '${_pickupLatLng!.latitude}, ${_pickupLatLng!.longitude}',
        'serviceType': serviceType,
      };

      // Handle different service types
      if (serviceType == 'ride') {
        requestBody.addAll({
          'vehicleType': 'motorcycle',
          'packageDetails': null,
          'senderName': null,
          'senderPhone': null,
          'receiverName': null,
          'receiverPhone': null,
          'parcelType': null
        });
      } else if (serviceType == 'parcel') {
        final parcelType = prefs.getString('parcelType');

        // Default package details
        final packageDetails = {
          'maxDimensions': '50x50 cm',
          'maxWeight': 10,
          'description': 'Standard package delivery'
        };

        if (parcelType == 'send') {
          final receiverName = prefs.getString('receiverName');
          final receiverPhone = prefs.getString('receiverPhone');

          // Log send parcel details
          log('Sending parcel details:');
          log('Sender (current user) - Name: $userName, Phone: $userPhone');
          log('Receiver - Name: $receiverName, Phone: $receiverPhone');

          if (receiverName == null ||
              receiverName.isEmpty ||
              receiverPhone == null ||
              receiverPhone.isEmpty) {
            return {
              'success': false,
              'message': 'Receiver details are required for sending parcel'
            };
          }

          requestBody.addAll({
            'serviceType': 'parcel',
            'parcelType': 'send',
            'packageDetails': packageDetails,
            'passengerName': userName, // Add passengerName
            'senderName': userName,
            'senderPhone': userPhone,
            'receiverName': receiverName,
            'receiverPhone': receiverPhone,
            'vehicleType': 'motorcycle_with_package'
          });
        } else if (parcelType == 'receive') {
          final senderName = prefs.getString('senderName');
          final senderPhone = prefs.getString('senderPhone');

          // Log receive parcel details
          log('Receiving parcel details:');
          log('Sender - Name: $senderName, Phone: $senderPhone');
          log('Receiver (current user) - Name: $userName, Phone: $userPhone');

          if (senderName == null ||
              senderName.isEmpty ||
              senderPhone == null ||
              senderPhone.isEmpty) {
            return {
              'success': false,
              'message': 'Sender details are required for receiving parcel'
            };
          }

          requestBody.addAll({
            'serviceType': 'parcel',
            'parcelType': 'receive',
            'packageDetails': packageDetails,
            'passengerName': userName, 
            'senderName': senderName,
            'senderPhone': senderPhone,
            'receiverName': userName,
            'receiverPhone': userPhone,
            'vehicleType': 'motorcycle_with_package'
          });
        }

        // Log final request body
        log('Final request body for parcel: ${json.encode(requestBody)}');
      }
      // Final validation of request body
      if (serviceType == 'parcel') {
        if ((requestBody['senderName'] == null ||
                requestBody['senderName'].toString().isEmpty) ||
            (requestBody['senderPhone'] == null ||
                requestBody['senderPhone'].toString().isEmpty) ||
            (requestBody['receiverName'] == null ||
                requestBody['receiverName'].toString().isEmpty) ||
            (requestBody['receiverPhone'] == null ||
                requestBody['receiverPhone'].toString().isEmpty)) {
          return {
            'success': false,
            'message': 'Sender and receiver details are required'
          };
        }
      }

      // Log the final request body
      log('Request body prepared: ${json.encode(requestBody)}');

      // Make API call
      final url = Uri.parse('${Constants.apiBaseUrl}/trip/createTripRequest');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      // Log response
      log('Response received. Status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        log('Response data: $responseData');
        final user = responseData['user'] as Map<String, dynamic>? ?? {};

        // Update provider state
        _passengerId = user['_id'] as String?;
        _passengerFullName = user['username'] as String?;
        _passengerProfilePicture = user['profilePicture'] as String?;

        notifyListeners();

        // Clear stored parcel data after successful request
        if (serviceType == 'parcel') {
          await prefs.remove('parcelType');
          await prefs.remove('senderName');
          await prefs.remove('senderPhone');
          await prefs.remove('receiverName');
          await prefs.remove('receiverPhone');
        }

        return responseData;
      } else {
        final errorBody = json.decode(response.body) as Map<String, dynamic>;
        final errorMessage =
            errorBody['message'] as String? ?? 'Unknown error occurred';
        final error = errorBody['error'] as String? ?? '';
        log('Failed to create trip request: $errorMessage');
        log('Error details: $error');
        return {
          'success': false,
          'message': 'Failed to create trip request: $errorMessage'
        };
      }
    } catch (e) {
      log('Error creating trip request: $e',
          error: e, stackTrace: StackTrace.current);
      return {'success': false, 'message': 'An unexpected error occurred: $e'};
    }
  }

 
  Future<void> fetchRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/auth/getRates'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _rates = Rates.fromJson(data['rates']);
        notifyListeners();
      } else {
        throw Exception('Failed to fetch rates');
      }
    } catch (e) {
      debugPrint('Error fetching rates: $e');
      // Use default values if API fails
      _rates = Rates(
        id: '0',
        baseFare: 5.0,
        vehicleRate: 5.0,
        adjustmentFare: 0.0009,
      );
      notifyListeners();
    }
  }
}
