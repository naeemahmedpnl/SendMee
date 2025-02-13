// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:rideapp/utils/constant/api_base_url.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DriverRatingProvider with ChangeNotifier {
//   int? rating;
//   String feedback = '';

//   void setRating(int value) {
//     rating = value;
//     notifyListeners();
//   }

//   void setFeedback(String value) {
//     feedback = value;
//     notifyListeners();
//   }

//   String get baseUrl => Constants.apiBaseUrl;

//   Future<bool> submitRating() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
     
//       // Get token from SharedPreferences
//       final token = prefs.getString('token');
//       if (token == null) {
//         log('Token not found in SharedPreferences', name: 'RatingProvider');
//         return false;
//       }
     
//       // Get passenger ID from SharedPreferences
//       final passengerId = prefs.getString('passenger_details_id');
//       if (passengerId == null) {
//         log('Passenger ID not found in SharedPreferences', name: 'RatingProvider');
//         return false;
//       }
      
//       // Validate rating
//       if (rating == null || rating! < 1 || rating! > 5) {
//         log('Invalid rating value: $rating', name: 'RatingProvider');
//         return false;
//       }

//       // Match the exact API request format
//       final body = jsonEncode({
//         "passengerId": passengerId, // Changed to match API format
//         "feedback": feedback,
//         "rating": rating, // Send as integer, not string
//       });

//       final url = '$baseUrl/rating/giveRatingToPassenger';
//       log('Submitting rating to URL: $url', name: 'RatingProvider');
//       log('Request body: $body', name: 'RatingProvider');

//       final response = await http.put(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: body,
//       );

//       log('Response status code: ${response.statusCode}', name: 'RatingProvider');
//       log('Response body: ${response.body}', name: 'RatingProvider');

//       if (response.statusCode == 200) {
//         log('Rating submitted successfully', name: 'RatingProvider');
        
//         // After successful rating submission, clean up SharedPreferences
//         await prefs.remove('passenger_details_id');
        
//         log('Cleaned up SharedPreferences after successful rating', name: 'RatingProvider');
        
//         return true;
//       } else {
//         // Parse error response for more details
//         final errorResponse = json.decode(response.body);
//         log(
//           'Failed to submit rating. Status code: ${response.statusCode}, Error: ${errorResponse.toString()}',
//           name: 'RatingProvider'
//         );
//         return false;
//       }
//     } catch (e, stackTrace) {
//       log(
//         'Error submitting rating',
//         error: e,
//         stackTrace: stackTrace,
//         name: 'RatingProvider',
//       );
//       return false;
//     }
//   }
// }

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverRatingProvider with ChangeNotifier {
  int? rating;
  String feedback = '';
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setRating(int value) {
    rating = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setFeedback(String value) {
    feedback = value;
    notifyListeners();
  }

  String get baseUrl => Constants.apiBaseUrl;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<Map<String, dynamic>> validateRatingData() async {
    final prefs = await SharedPreferences.getInstance();
    final errors = <String, dynamic>{
      'success': true,
      'message': '',
    };

    // Check token
    final token = prefs.getString('token');
    if (token == null) {
      errors['success'] = false;
      errors['message'] = 'Session expired. Please login again.';
      return errors;
    }

    // Check passenger ID
    final passengerId = prefs.getString('passenger_details_id');
    if (passengerId == null) {
      errors['success'] = false;
      errors['message'] = 'Passenger details not found.';
      return errors;
    }

    // Validate rating
    if (rating == null) {
      errors['success'] = false;
      errors['message'] = 'Please select a rating.';
      return errors;
    }

    if (rating! < 1 || rating! > 5) {
      errors['success'] = false;
      errors['message'] = 'Invalid rating value.';
      return errors;
    }

    // Optional: Validate feedback if required
    if (feedback.isEmpty) {
      errors['success'] = false;
      errors['message'] = 'Please provide feedback.';
      return errors;
    }

    return errors;
  }

  Future<bool> submitRating() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Validate data first
      final validation = await validateRatingData();
      if (!validation['success']) {
        _setError(validation['message']);
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')!;
      final passengerId = prefs.getString('passenger_details_id')!;

      final body = jsonEncode({
        "passengerId": passengerId,
        "feedback": feedback,
        "rating": rating,
      });

      final url = '$baseUrl/rating/giveRatingToPassenger';
      
      log('Submitting rating request...', name: 'RatingProvider');
      log('URL: $url', name: 'RatingProvider');
      log('Body: $body', name: 'RatingProvider');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      log('Response Status: ${response.statusCode}', name: 'RatingProvider');
      log('Response Body: ${response.body}', name: 'RatingProvider');

      if (response.statusCode == 200) {
        await prefs.remove('passenger_details_id');
        log('Rating submitted successfully', name: 'RatingProvider');
        return true;
      }

      // Handle different error scenarios
      final errorResponse = json.decode(response.body);
      switch (response.statusCode) {
        case 400:
          _setError(errorResponse['message'] ?? 'Invalid request data.');
          break;
        case 401:
          _setError('Session expired. Please login again.');
          break;
        case 404:
          _setError('Passenger not found.');
          break;
        case 429:
          _setError('Too many attempts. Please try again later.');
          break;
        default:
          _setError(errorResponse['message'] ?? 'An error occurred while submitting rating.');
      }
      
      return false;

    } catch (e, stackTrace) {
      log(
        'Error submitting rating',
        error: e,
        stackTrace: stackTrace,
        name: 'RatingProvider',
      );
      _setError('Network error. Please check your connection and try again.');
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to show error in SnackBar
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}