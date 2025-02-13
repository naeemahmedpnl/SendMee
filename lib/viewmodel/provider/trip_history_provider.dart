
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripModel {
  final String id;
  final double amount;
  final String status;
  final String dateTime;
  final String pickupAddress;
  final String destinationAddress;
  final double baseFare;
  final double distanceKm;
  final double distanceFare;
  final double platformFee;
  final double totalAmount;

  TripModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.dateTime,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.baseFare,
    required this.distanceKm,
    required this.distanceFare,
    required this.platformFee,
    required this.totalAmount,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    DateTime date = DateTime.parse(json['createdAt']);
    String formattedDate = DateFormat('MMM dd, hh:mm a').format(date);

    return TripModel(
      id: json['_id'],
      amount: json['estimatedFare'].toDouble(),
      status: json['status'],
      dateTime: formattedDate,
      pickupAddress: json['pickupAddress'],
      destinationAddress: json['destinationAddress'],
      baseFare: json['baseFare'].toDouble(),
      distanceKm: json['distanceKm'].toDouble(),
      distanceFare: json['distanceFare'].toDouble(),
      platformFee: json['platformFee'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'status': status,
      'dateTime': dateTime,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'baseFare': baseFare,
      'distanceKm': distanceKm,
      'distanceFare': distanceFare,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
    };
  }
}

class TripHistoryProvider extends ChangeNotifier {
  List<TripModel> _pendingTrips = [];
  List<TripModel> _completedTrips = [];
  List<TripModel> _cancelledTrips = [];
  bool _isLoading = false;

  List<TripModel> get pendingTrips => _pendingTrips;
  List<TripModel> get completedTrips => _completedTrips;
  List<TripModel> get cancelledTrips => _cancelledTrips;
  bool get isLoading => _isLoading;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> fetchTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      await Future.wait([
        _fetchTripsByStatus('trip/getPendingTrips', headers),
        _fetchTripsByStatus('trip/getAcceptedTrips', headers),
        _fetchTripsByStatus('trip/getRejectedTrips', headers),
      ]);
    } catch (e) {
      log('Error fetching trips: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchTripsByStatus(String endpoint, Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trips = (data['tripHistory'] as List)
            .map((trip) => TripModel.fromJson(trip))
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
      }
    } catch (e) {
      log('Error fetching $endpoint: $e');
    }
  }
}