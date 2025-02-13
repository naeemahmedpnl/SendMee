import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rideapp/utils/constant/api_base_url.dart';

class CancelTripRequest with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> cancelTrip(String tripId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = '${Constants.apiBaseUrl}/trip/delete/$tripId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cancellationReason': reason}),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to cancel trip: ${response.body}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error cancelling trip: $e';
      notifyListeners();
      return false;
    }
  }
}