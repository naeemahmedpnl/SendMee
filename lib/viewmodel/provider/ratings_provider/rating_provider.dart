import 'package:flutter/foundation.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class RatingProvider with ChangeNotifier {
  int? rating;
  String feedback = '';

  void setRating(int value) {
    rating = value;
    notifyListeners();
  }

  void setFeedback(String value) {
    feedback = value;
    notifyListeners();
  }

  String get baseUrl => Constants.apiBaseUrl;

  Future<bool> submitRating() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get token from SharedPreferences
      final token = prefs.getString('token');
      if (token == null) {
        developer.log('Token not found in SharedPreferences', name: 'RatingProvider');
        return false;
      }

      // Get driver ID from SharedPreferences
      final driverId = prefs.getString('driverId');
      if (driverId == null) {
        developer.log('Driver ID not found in SharedPreferences', name: 'RatingProvider');
        return false;
      }
      developer.log('Retrieved driver ID from SharedPreferences: $driverId', name: 'RatingProvider');

      // Validate rating
      if (rating == null || rating! < 1 || rating! > 5) {
        developer.log('Invalid rating value: $rating', name: 'RatingProvider');
        return false;
      }

      final body = jsonEncode({
        "DriverId": driverId, // Use driverId from SharedPreferences
        "feedback": feedback,
        "rating": rating,
      });

      final url = '$baseUrl/rating/giveRatingToDriver';
      developer.log('Submitting rating to URL: $url', name: 'RatingProvider');
      developer.log('Request body: $body', name: 'RatingProvider');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      developer.log('Response status code: ${response.statusCode}', name: 'RatingProvider');
      developer.log('Response body: ${response.body}', name: 'RatingProvider');

      if (response.statusCode == 200) {
        developer.log('Rating submitted successfully', name: 'RatingProvider');
        
        // After successful rating submission, remove the driver ID
        await prefs.remove('driverId');
        developer.log('Removed driver ID from SharedPreferences', name: 'RatingProvider');
        
        return true;
      } else {
        developer.log(
          'Failed to submit rating. Status code: ${response.statusCode}', 
          name: 'RatingProvider'
        );
        return false;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error submitting rating',
        error: e,
        stackTrace: stackTrace,
        name: 'RatingProvider',
      );
      return false;
    }
  }
}