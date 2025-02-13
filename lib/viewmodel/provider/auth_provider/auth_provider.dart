import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rideapp/models/user_model.dart';
import 'package:rideapp/services/canhed_data.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String _otp = '';
  String _token = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isDriver = false;
  bool _isAuthenticated = false;
  User? _userData;
   String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get otp => _otp;
  String get token => _token;
  String get errorMessage => _errorMessage;
  bool get isDriver => _isDriver;
  User? get userData => _userData;
   String? get error => _error;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  //register wiht phone number
  Future<void> registerWithPhoneNumber(String phoneNumber) async {
    final phoneRegex = RegExp(r'^\+(52|92)\d{10,11}$');

    // Log the start of the registration process
    log('Starting registration for phone number: $phoneNumber');

    // Validate phone number format
    if (!phoneRegex.hasMatch(phoneNumber)) {
      throw const FormatException('Invalid phone number format');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Send registration request
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register-with-phoneNumber'),
        body: json.encode({'phoneNumber': phoneNumber}),
        headers: {'Content-Type': 'application/json'},
      );

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Registration successful for phone number: $phoneNumber');

        final responseData = json.decode(response.body);
        _otp = responseData['otp'].toString();
        _token = responseData['token'];

        // Save token and OTP to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token);
        await prefs.setString('otp', _otp);

        log('Token: $_token, OTP: $_otp saved successfully');
        notifyListeners();
      } else if (response.statusCode == 409) {
        log('User already exists with phone number: $phoneNumber');
        throw Exception('User already exists');
      } else {
        log('Failed to register user. Status code: ${response.statusCode}');
        throw Exception('Failed to register user');
      }
    } finally {
      // Ensure loading state is reset
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> completeProfile(
      String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Starting profile completion process for email: $email');

      // Fetch token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        debugPrint('Authorization token not found');
        throw Exception('Authorization token not found');
      }

      debugPrint('Authorization token retrieved successfully');

      // Build the request body
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'name': name,
      };

      // Make the API call
      final response = await http.put(
        Uri.parse('$baseUrl/auth/completeProfile'),
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint(
            'Profile completed successfully: ${responseData.toString()}');

        // Extract and save the new token from response
        if (responseData['token'] != null) {
          await prefs.setString('token', responseData['token']);
          debugPrint('New token saved successfully');
        }
      } else if (response.statusCode == 400) {
        // Handle bad request response
        debugPrint('Bad request: ${response.body}');
        throw Exception('Enter correct email or password');
      } else if (response.statusCode == 401) {
        // Handle unauthorized response
        debugPrint('Unauthorized request: Token expired or invalid');
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 500) {
        // Handle server error
        debugPrint('Server error: ${response.body}');
        throw Exception('Server error. Please try again later.');
      } else {
        // Handle other responses
        debugPrint(
            'Unexpected response: ${response.statusCode} ${response.body}');
        throw Exception(
            'Failed to complete profile. Status code: ${response.statusCode}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password, String fcmToken) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      log('Login attempt - Email: $email, FCM Token: $fcmToken');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: json.encode(
                {'email': email, 'password': password, 'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));

      log('Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          _token = data['token'];
          _isDriver = data['isDriver'] ?? false;

          // Save token and verify
          await _saveUserData(_token, _isDriver, fcmToken);

          // Verify token was saved
          final prefs = await SharedPreferences.getInstance();
          final savedToken = prefs.getString('token');

          log('Saved token verification:');
          log('Token to save: $_token');
          log('Token from SharedPreferences: $savedToken');

          if (savedToken == _token) {
            log('✅ Token saved successfully');
            return null;
          } else {
            log('❌ Token saving failed');
            return 'Failed to save authentication data';
          }
        }
        return 'Invalid response: Token not found';
      }

      final error = json.decode(response.body);
      return error['message'] ?? 'Error: ${response.statusCode}';
    } catch (e) {
      log('Login error: $e');
      return 'Unexpected error occurred';
    }
  }

// Modified _saveUserData function with better logging
  Future<void> _saveUserData(
      String token, bool isDriver, String fcmToken) async {
    try {
      log('Saving user data to SharedPreferences...');
      log('Token to save: $token');

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);
      await prefs.setBool('isAuthenticated', true);
      await prefs.setBool('isDriver', isDriver);
      await prefs.setString('fcmToken', fcmToken);

      // Verify saves
      final savedToken = prefs.getString('token');
      final savedIsAuth = prefs.getBool('isAuthenticated');
      final savedIsDriver = prefs.getBool('isDriver');
      final savedFcmToken = prefs.getString('fcmToken');

      log('''
      📦 Saved Data Verification:
      Token: ${savedToken != null ? '✅' : '❌'}
      isAuthenticated: ${savedIsAuth != null ? '✅' : '❌'}
      isDriver: ${savedIsDriver != null ? '✅' : '❌'}
      FCM Token: ${savedFcmToken != null ? '✅' : '❌'}
    ''');

      notifyListeners();
    } catch (e) {
      log('❌ Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }


//forgot password Api Provider
  Future<String?> sendOTP(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgetPassword');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return null; // No error, OTP sent
      } else {
        final errorData = json.decode(response.body);
        return errorData['message'] ?? 'Error occurred'; // Return error message
      }
    } catch (error) {
      return 'An error occurred. Please try again.'; // Handle error
    }
  }

//logout user
  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

//Reset Password Provider
  Future<String?> resetPassword(
      String email, String otp, String password, String confirmPassword) async {
    try {
      // Example API request to reset password
      final response = await http.put(
        Uri.parse('$baseUrl/auth/resetPassword'),
        body: {
          'email': email,
          'otp': otp,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'An error occurred';
      }
    } catch (e) {
      return 'Failed to reset password. Please try again later.';
    }
  }

//Change Password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/changePassword');

    _isLoading = true;

    notifyListeners();

    try {
      // Retrieve the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      log("toek is a $token");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Handle success (e.g., show a success message)
        _isLoading = false;
        notifyListeners();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? 'Password change failed';
        _isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      _errorMessage = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch and store user data
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      log('Token not found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _userData = User.fromJson(data);
        await UserDataCache.setUserData(data);
        notifyListeners();
        log('User data fetched and cached successfully.');
      } else {
        log('Failed to load user data. Status code: ${response.statusCode}');
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      log('Error fetching user data: $e');
      throw Exception('Error fetching user data');
    }
  }

  // Get cached user data
  Future<User?> getUserData() async {
    if (_userData == null) {
      final cachedData = await UserDataCache.getUserData();
      if (cachedData != null) {
        _userData = cachedData;
        notifyListeners();
      }
    }
    return _userData;
  }

  // Update profile
  Future<void> updateProfile({
    required String name,
    required String address,
    File? profilePicture,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token not found');

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Constants.apiBaseUrl}/auth/updateProfile'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['address'] = address;

      if (profilePicture != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await fetchUserData();
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      log('Update profile error: $e');
      throw Exception('Failed to update profile');
    }
  }


 Future<bool> uploadIdCards(String frontPath, String backPath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) throw Exception('Token not found');

      final uri = Uri.parse('$baseUrl/auth/passenger/upload-idcard');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('idcardFront', frontPath))
        ..files.add(await http.MultipartFile.fromPath('idcardBack', backPath));

      final response = await request.send();
      
      if (response.statusCode == 200) {
        return true;
      } else {
        _error = 'Upload failed';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }






//FCM token get
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
