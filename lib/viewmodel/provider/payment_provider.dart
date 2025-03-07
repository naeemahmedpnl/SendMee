import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _instructions;
  String? _pollUrl;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get instructions => _instructions;
  String? get pollUrl => _pollUrl;
  String get baseUrl => Constants.apiBaseUrl;

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  // Process mobile money payments (EcoCash/OneMoney) - Optimized for speed
  Future<bool> processMobilePayment({
    required double amount,
    required String phone,
    required String method,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      _instructions = null;
      _pollUrl = null;
      
      // Get auth token - use cached token for speed
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw 'Authentication token not found. Please login again.';
      }
      
      log('Processing ${method.toUpperCase()} payment');
      log('Amount: $amount, Phone: $phone');
      
      // Optimize API call with timeouts
      final client = http.Client();
      try {
        // Use timeout to prevent long-hanging requests
        final response = await client.post(
          Uri.parse('$baseUrl/stripe/create-mobile-payment'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'amount': amount,
            'phone': phone,
            'method': method,
          }),
        ).timeout(Duration(seconds: 10)); // Faster timeout
      
        log('Mobile payment API response: ${response.body}');
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          _instructions = data['instructions'];
          _pollUrl = data['pollUrl'];
          log('Payment initiated successfully');
          log('Instructions: $_instructions');
          log('Poll URL: $_pollUrl');
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Payment failed';
          log('Payment failed: $_errorMessage');
          return false;
        }
      } finally {
        client.close(); // Properly close the client
      }
    } catch (e) {
      log('Error processing mobile payment: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check status of a payment - Optimized for speed
  Future<Map<String, dynamic>> checkPaymentStatus(String pollUrl) async {
    final client = http.Client();
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'Authentication token not found'};
      }
      
      log('Checking payment status for poll URL: $pollUrl');
      
      // Use timeout for faster response
      final response = await client.post(
        Uri.parse('$baseUrl/stripe/check-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'pollUrl': pollUrl,
        }),
      ).timeout(Duration(seconds: 5)); // Faster timeout
      
      log('Payment status API response: ${response.body}');
      
      // Handle non-200 status codes
      if (response.statusCode != 200) {
        log('Payment status check failed with status code: ${response.statusCode}');
        return {
          'success': false, 
          'error': 'Server returned status code ${response.statusCode}'
        };
      }
      
      // Handle empty response body
      if (response.body.isEmpty) {
        log('Payment status check returned empty response');
        return {
          'success': false, 
          'error': 'Empty response from server'
        };
      }
      
      // Parse the response body
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        log('Error parsing payment status response: $e');
        log('Raw response: ${response.body}');
        return {
          'success': false, 
          'error': 'Invalid response format'
        };
      }
      
      // If the response doesn't contain a 'success' field, add one
      if (!data.containsKey('success')) {
        if (data.containsKey('status')) {
          data['success'] = true;
        } else {
          data['success'] = false;
          data['error'] = 'Invalid response format: missing status field';
        }
      }
      
      return data;
    } catch (e) {
      log('Error checking payment status: $e');
      return {'success': false, 'error': e.toString()};
    } finally {
      client.close(); // Properly close the client
    }
  }

  // Manual wallet balance update - Optimized
  Future<bool> manuallyRefreshWalletBalance() async {
    final client = http.Client();
    try {
      _setLoading(true);
      final token = await getToken();
      
      if (token == null || token.isEmpty) {
        throw 'Authentication token not found. Please login again.';
      }
      
      log('Manually refreshing wallet balance');
      
      // Use timeout for faster response
      final response = await client.get(
        Uri.parse('$baseUrl/auth/refresh-wallet'),
        headers: {
          'Authorization': 'Bearer $token'
        },
      ).timeout(Duration(seconds: 5)); // Faster timeout
      
      log('Wallet refresh response: ${response.body}');
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        log('Wallet balance refreshed successfully');
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Failed to refresh wallet balance';
        return false;
      }
    } catch (e) {
      log('Error refreshing wallet balance: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      client.close(); // Properly close the client
      _setLoading(false);
    }
  }

  // Cache the auth token for faster retrieval
  String? _cachedToken;
  DateTime? _tokenCacheTime;

  // Get auth token from shared preferences with caching
  Future<String?> getToken() async {
    // Return cached token if available and less than 10 minutes old
    if (_cachedToken != null && _tokenCacheTime != null) {
      final cacheAge = DateTime.now().difference(_tokenCacheTime!);
      if (cacheAge.inMinutes < 10) {
        return _cachedToken;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      // Cache the token
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        _tokenCacheTime = DateTime.now();
      }
      
      return token;
    } catch (e) {
      log('Error getting token: $e');
      return null;
    }
  }

  // Standard web-based Paynow payment - Optimized
  Future<Map<String, dynamic>> createWebPayment(double amount) async {
    final client = http.Client();
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw 'Authentication token not found. Please login again.';
      }
      
      log('Creating web payment for amount: $amount');
      
      final response = await client.post(
        Uri.parse('$baseUrl/stripe/create-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 10)); // Faster timeout
      
      log('Web payment API response: ${response.body}');
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return {
          'success': true,
          'redirectUrl': data['redirectUrl'],
          'pollUrl': data['pollUrl']
        };
      } else {
        _errorMessage = data['message'] ?? 'Payment failed';
        return {'success': false, 'error': _errorMessage};
      }
    } catch (e) {
      log('Error creating web payment: $e');
      _errorMessage = e.toString();
      return {'success': false, 'error': e.toString()};
    } finally {
      client.close(); // Properly close the client
      _setLoading(false);
    }
  }

  // Simulate payment completion (for testing) - Optimized
  Future<bool> simulatePayment(String paymentId) async {
    final client = http.Client();
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw 'Authentication token not found. Please login again.';
      }
      
      log('Simulating payment completion for: $paymentId');
      
      final response = await client.post(
        Uri.parse('$baseUrl/stripe/simulate-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'paymentId': paymentId,
        }),
      ).timeout(Duration(seconds: 5)); // Faster timeout
      
      log('Simulate payment API response: ${response.body}');
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Simulation failed';
        return false;
      }
    } catch (e) {
      log('Error simulating payment: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      client.close(); // Properly close the client
      _setLoading(false);
    }
  }

  // Update wallet balance - Optimized
  Future<bool> updateWalletBalance(String userId, double amount) async {
    final client = http.Client();
    try {
      log('Updating wallet balance for user: $userId with amount: $amount');

      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw 'Authentication token not found. Please login again.';
      }

      final response = await client.post(
        Uri.parse('$baseUrl/auth/update-wallet-balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      ).timeout(Duration(seconds: 5)); // Faster timeout

      log('Wallet update response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Wallet balance updated successfully. New balance: ${data['newWalletBalance']}');
        return true;
      } else {
        final error = jsonDecode(response.body)['error'];
        throw error ?? 'Failed to update wallet balance';
      }
    } catch (e) {
      log('Error updating wallet balance: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      client.close(); // Properly close the client
    }
  }

  // For wallet payment - Optimized
  Future<bool> makeWalletPayment(String estimatedFare) async {
    final client = http.Client();
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Get driver ID
      String? driverId = prefs.getString('driverId');
      String? userId = prefs.getString('userId');
      if (driverId == null) throw 'Driver ID not found';
      log('Driver ID: $driverId');

      if (userId == null) throw 'User ID not found';
      log('User ID: $userId');

      // Parse amount
      if (estimatedFare.isEmpty) throw 'Invalid amount';
      double amount = double.parse(estimatedFare);

      // Get auth token
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw 'Authentication token not found. Please login again.';
      }

      // Prepare request
      final requestBody = {
        "senderId": userId,
        "recipientId": driverId,
        "amount": amount
      };

      // Make API call with timeout
      final response = await client.post(
        Uri.parse('$baseUrl/auth/transferFromWallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(requestBody)
      ).timeout(Duration(seconds: 10)); // Faster timeout

      // Log response
      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');
      log('============= End Wallet Payment =============');

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw json.decode(response.body)['message'] ?? 'Payment failed';
      }
    } catch (e) {
      log('Wallet Payment Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } finally {
      client.close(); // Properly close the client
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}