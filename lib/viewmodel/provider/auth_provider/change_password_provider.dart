import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ChangePasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordChanged = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordChanged => _isPasswordChanged;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  Future<void> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _isPasswordChanged = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/changePassword'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );


      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        _isPasswordChanged = true;
        log('Password changed successfully');
      } else if (response.statusCode == 400) {
        _errorMessage = responseBody['message'] ?? 'Current password is incorrect';
        log('Error 400: $_errorMessage');
      } else if (response.statusCode == 401) {
        _errorMessage = 'Your session has expired. Please log in again.';
        log('Error 401: $_errorMessage');
      } else if (response.statusCode == 422) {
        _errorMessage = 'New password does not meet the required criteria';
        log('Error 422: $_errorMessage');
      } else {
        _errorMessage = responseBody['message'] ?? 'An unexpected error occurred';
        log('Unexpected error: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}