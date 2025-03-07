import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';


void _log(String message, {String? error, StackTrace? stackTrace, String? context}) {
  final timestamp = DateTime.now().toIso8601String();
  final contextInfo = context != null ? '[$context] ' : '';
  final logMessage = '[$timestamp] $contextInfo$message';
  
  if (error != null) {
    developer.log(logMessage, error: error, stackTrace: stackTrace);
  } else {
    developer.log(logMessage);
  }
}



class TripModel {
  // Core trip information
  final String id;
  final double estimatedFare;
  final String status;
  final String dateTime;
  final String pickupAddress;
  final String destinationAddress;

  // Location information
  final String pickup;
  final String destination;
  final Map<String, dynamic>? driverLocation;

  // Service details
  final String serviceType;
  final String? parcelType;
  final String? vehicleType;

  // Package information
  final Map<String, dynamic>? packageDetails;

  // Sender and receiver information
  final String? senderName;
  final String? senderPhone;
  final String? receiverName;
  final String? receiverPhone;

  // Timing information
  final DateTime createdAt;
  final DateTime expiryTime;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  // Fare breakdown
  final double baseFare;
  final double distanceKm;
  final double distanceFare;
  final double platformFee;
  final double perKmCost;
  final double totalAmount;
  final double? driverEstimatedFare;

  // IDs
  final String passengerId;
  final String? driverId;

  TripModel({
    required this.id,
    required this.estimatedFare,
    required this.status,
    required this.dateTime,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickup,
    required this.destination,
    required this.serviceType,
    required this.createdAt,
    required this.expiryTime,
    required this.baseFare,
    required this.distanceKm,
    required this.distanceFare,
    required this.platformFee,
    required this.perKmCost,
    required this.totalAmount,
    required this.passengerId,
    this.parcelType,
    this.vehicleType,
    this.packageDetails,
    this.senderName,
    this.senderPhone,
    this.receiverName,
    this.receiverPhone,
    this.acceptedAt,
    this.completedAt,
    this.driverEstimatedFare,
    this.driverId,
    this.driverLocation,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    try {
      _log('Starting to parse trip data: ${json['_id']}', context: 'TripModel');

      // Parse dates safely
      DateTime parseDateTime(String? dateStr, String fieldName) {
        try {
          return dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
        } catch (e) {
          _log('Error parsing $fieldName: $dateStr', error: e.toString(), context: 'TripModel');
          return DateTime.now();
        }
      }

      // Safe conversion helper function
      double safeDouble(dynamic value, String fieldName) {
        try {
          if (value == null) return 0.0;
          if (value is int) return value.toDouble();
          if (value is double) return value;
          if (value is String) return double.parse(value);
          return 0.0;
        } catch (e) {
          _log('Error converting $fieldName to double: $value', error: e.toString(), context: 'TripModel');
          return 0.0;
        }
      }

      final createdAtDate = parseDateTime(json['createdAt'], 'createdAt');
      final formattedDate = DateFormat('MMM dd, hh:mm a').format(createdAtDate);

      final trip = TripModel(
        id: json['_id']?.toString() ?? '',
        estimatedFare: safeDouble(json['estimatedFare'], 'estimatedFare'),
        status: json['status']?.toString() ?? 'unknown',
        dateTime: formattedDate,
        pickupAddress: json['pickupAddress']?.toString() ?? 'No pickup address',
        destinationAddress: json['destinationAddress']?.toString() ?? 'No destination address',
        pickup: json['pickup']?.toString() ?? '',
        destination: json['destination']?.toString() ?? '',
        serviceType: json['serviceType']?.toString() ?? 'unknown',
        parcelType: json['parcelType']?.toString(),
        vehicleType: json['vehicleType']?.toString(),
        packageDetails: json['packageDetails'] as Map<String, dynamic>?,
        senderName: json['senderName']?.toString(),
        senderPhone: json['senderPhone']?.toString(),
        receiverName: json['receiverName']?.toString(),
        receiverPhone: json['receiverPhone']?.toString(),
        driverLocation: json['driverLocation'] as Map<String, dynamic>?,
        createdAt: createdAtDate,
        expiryTime: parseDateTime(json['expiryTime'], 'expiryTime'),
        acceptedAt: json['acceptedAt'] != null ? parseDateTime(json['acceptedAt'], 'acceptedAt') : null,
        completedAt: json['completedAt'] != null ? parseDateTime(json['completedAt'], 'completedAt') : null,
        baseFare: safeDouble(json['baseFare'], 'baseFare'),
        distanceKm: safeDouble(json['distanceKm'], 'distanceKm'),
        distanceFare: safeDouble(json['distanceFare'], 'distanceFare'),
        platformFee: safeDouble(json['platformFee'], 'platformFee'),
        perKmCost: safeDouble(json['perKmCost'], 'perKmCost'),
        totalAmount: safeDouble(json['totalAmount'], 'totalAmount'),
        driverEstimatedFare: safeDouble(json['driverEstimatedFare'], 'driverEstimatedFare'),
        passengerId: json['passenger']?.toString() ?? '',
        driverId: json['driver']?.toString(),
      );

      _log('Successfully parsed trip ${trip.id}', context: 'TripModel');
      return trip;
      
    } catch (e, stackTrace) {
      _log(
        'Critical error parsing trip data',
        error: e.toString(),
        stackTrace: stackTrace,
        context: 'TripModel'
      );
      _log('Problematic JSON: ${json.toString()}', context: 'TripModel');
      
      return TripModel(
        id: 'ERROR-${DateTime.now().millisecondsSinceEpoch}',
        estimatedFare: 0,
        status: 'error',
        dateTime: DateFormat('MMM dd, hh:mm a').format(DateTime.now()),
        pickupAddress: 'Error: Unable to load address',
        destinationAddress: 'Error: Unable to load address',
        pickup: '',
        destination: '',
        serviceType: 'unknown',
        createdAt: DateTime.now(),
        expiryTime: DateTime.now(),
        baseFare: 0,
        distanceKm: 0,
        distanceFare: 0,
        platformFee: 0,
        perKmCost: 0,
        totalAmount: 0,
        passengerId: '',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': estimatedFare,
      'status': status,
      'dateTime': dateTime,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickup': pickup,
      'destination': destination,
      'serviceType': serviceType,
      'parcelType': parcelType,
      'senderName': senderName,
      'senderPhone': senderPhone,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'baseFare': baseFare,
      'distanceKm': distanceKm,
      'distanceFare': distanceFare,
      'platformFee': platformFee,
      'perKmCost': perKmCost,
      'totalAmount': totalAmount,
    };
  }
}

class TripHistoryProvider extends ChangeNotifier {
  List<TripModel> _pendingTrips = [];
  List<TripModel> _completedTrips = [];
  List<TripModel> _cancelledTrips = [];
  bool _isLoading = false;
  String? _error;

  List<TripModel> get pendingTrips => _pendingTrips;
  List<TripModel> get completedTrips => _completedTrips;
  List<TripModel> get cancelledTrips => _cancelledTrips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get baseUrl => Constants.apiBaseUrl;

  Future<String> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }
      
      return token;
    } catch (e, stackTrace) {
      _log(
        'Authentication error',
        error: e.toString(),
        stackTrace: stackTrace,
        context: 'TripHistoryProvider'
      );
      _error = 'Authentication failed. Please log in again.';
      notifyListeners();
      return '';
    }
  }

  Future<void> fetchTrips() async {
    _log('Starting trip fetch operation', context: 'TripHistoryProvider');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token.isEmpty) {
        _log('Aborting trip fetch: No valid token', context: 'TripHistoryProvider');
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      await Future.wait([
        _fetchTripsByStatus('trip/getPendingTrips', headers),
        _fetchTripsByStatus('trip/getAcceptedTrips', headers),
        _fetchTripsByStatus('trip/getRejectedTrips', headers),
      ]);

    } catch (e, stackTrace) {
      _log(
        'Error in fetchTrips',
        error: e.toString(),
        stackTrace: stackTrace,
        context: 'TripHistoryProvider'
      );
      _error = 'Failed to fetch trips. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }





  Future<void> _fetchTripsByStatus(String endpoint, Map<String, String> headers) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final tripHistoryData = data['tripHistory'] as List<dynamic>?;
        
        if (tripHistoryData == null) {
          throw Exception('Trip history data is null');
        }

        final trips = tripHistoryData
            .map((trip) => TripModel.fromJson(trip as Map<String, dynamic>))
            .where((trip) => !trip.id.startsWith('ERROR-'))
            .toList();

        switch (endpoint) {
          case 'trip/getPendingTrips':
            _pendingTrips = trips;
            break;
          case 'trip/getAcceptedTrips':
            _completedTrips = trips;
            break;
          case 'trip/getRejectedTrips':
            _cancelledTrips = trips;
            break;
        }
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      _log(
        'Error fetching trips from $endpoint',
        error: e.toString(),
        stackTrace: stackTrace,
        context: 'TripHistoryProvider'
      );
      
      // Clear the affected list instead of keeping stale data
      switch (endpoint) {
        case 'trip/getPendingTrips':
          _pendingTrips = [];
          break;
        case 'trip/getAcceptedTrips':
          _completedTrips = [];
          break;
        case 'trip/getRejectedTrips':
          _cancelledTrips = [];
          break;
      }
    }
  }
}