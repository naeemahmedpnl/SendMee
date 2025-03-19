// // class ProfileProvider with ChangeNotifier {
// //   String _userName = '';
// //   double _rating = 0.0;
// //   String _phone = '';
// //   String _email = '';
// //   String _address = '';

// //   String get userName => _userName;
// //   double get rating => _rating;
// //   String get phone => _phone;
// //   String get email => _email;
// //   String get address => _address;

// //   Future<void> fetchProfileData() async {
// //     final response = await http.get(Uri.parse('https://example.com/api/profile'));

// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body);
// //       _userName = data['name'];
// //       _rating = data['rating'];
// //       _phone = data['phone'];
// //       _email = data['email'];
// //       _address = data['address'];
// //       notifyListeners();
// //     } else {
// //       throw Exception('Failed to load profile data');
// //     }
// //   }

// //   Future<void> updateProfile(String name, String phone, String email, String address) async {
// //     final response = await http.put(
// //       Uri.parse('https://example.com/api/profile'),
// //       headers: {'Content-Type': 'application/json'},
// //       body: json.encode({
// //         'name': name,
// //         'phone': phone,
// //         'email': email,
// //         'address': address,
// //       }),
// //     );

// //     if (response.statusCode == 200) {
// //       _userName = name;
// //       _phone = phone;
// //       _email = email;
// //       _address = address;
// //       notifyListeners();
// //     } else {
// //       throw Exception('Failed to update profile');
// //     }
// //   }
// // }


// import 'dart:convert';

// // profile_provider.dart
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileData {
//   final String username;
//   final String profilePicture;
//   final String phone;
//   final String email;
//   final String driverLicense;
//   final String address;
//   final double ratingAverage;
//   final int totalEarnings;
//   final Map<String, int> totalRides;
//   final List<int> ratings;

//   ProfileData({
//     required this.username,
//     required this.profilePicture,
//     required this.phone,
//     required this.email,
//     this.driverLicense = '',
//     this.address = '',
//     required this.ratingAverage,
//     required this.totalEarnings,
//     required this.totalRides,
//     required this.ratings,
//   });
// }

// class ProfileProvider with ChangeNotifier {
//   ProfileData? _profileData;
//   bool _isLoading = false;
//   String _error = '';

//   ProfileData? get profileData => _profileData;
//   bool get isLoading => _isLoading;
//   String get error => _error;

//   Future<void> fetchProfileData() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ?? '';

//       final response = await http.get(
//         Uri.parse('http://158.220.90.248:3000/auth/user'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<int> ratings = [];
        
//         if (data['driverDetails'] != null && data['driverDetails']['rating'] != null) {
//           ratings = List<int>.from(
//             data['driverDetails']['rating'].map((r) => r['rating'] as int)
//           );
//         }

//         _profileData = ProfileData(
//           username: data['username'] ?? '',
//           profilePicture: data['profilePicture'] ?? '',
//           phone: data['phone'] ?? '',
//           email: data['email'] ?? '',
//           driverLicense: data['driverDetails']?['driverLicense'] ?? '',
//           address: data['address'] ?? '',
//           ratingAverage: (data['driverDetails']?['ratingAverage'] ?? 0).toDouble(),
//           totalEarnings: data['totalEarningsAsDriver'] ?? 0,
//           totalRides: {
//             'asPassenger': data['totalRides']?['asPassenger'] ?? 0,
//             'asDriver': data['totalRides']?['asDriver'] ?? 0,
//             'total': data['totalRides']?['total'] ?? 0,
//           },
//           ratings: ratings,
//         );
//         _error = '';
//       } else {
//         _error = 'Failed to load profile data';
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }


import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  User? _profileData;
  bool _isLoading = false;
  String _error = '';

  User? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get error => _error;

  String get baseUrl => Constants.apiBaseUrl;

  Future<void> fetchProfileData() async {
    if (_isLoading) return; 

    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('API Response: $data'); // Debug log

        final totalRides = TotalRides(
          asPassenger: data['totalRides']?['asPassenger'] ?? 0,
          asDriver: data['totalRides']?['asDriver'] ?? 0,
          total: data['totalRides']?['total'] ?? 0,
        );

        PassengerDetails? passengerDetails;
        if (data['passengerDetails'] != null) {
          passengerDetails =
              PassengerDetails.fromJson(data['passengerDetails']);
        }

        _profileData = User(
          id: data['_id'] ?? '',
          registrationType: data['registrationType'] ?? '',
          phone: data['phone'] ?? '',
          otp: data['otp'] ?? '',
          otpExpire: DateTime.parse(
              data['otpExpire'] ?? DateTime.now().toIso8601String()),
          createdAt: DateTime.parse(
              data['createdAt'] ?? DateTime.now().toIso8601String()),
          isSuperAdmin: data['isSuperAdmin'] ?? false,
          driverRoleStatus: data['driverRoleStatus'] ?? '',
          passengerStatus: data['PassengerStatus'] ?? '',
          isDriver: data['isDriver'] ?? false,
          v: data['__v'] ?? 0,
          email: data['email'],
          username: data['username'],
          profilePicture: data['profilePicture'],
          passengerDetails: passengerDetails,
          walletBalance: (data['walletBalance'] ?? 0)
              .toDouble(), // Changed from toInt() to toDouble()
          totalEarningsAsDriver: (data['totalEarningsAsDriver'] ?? 0)
              .toDouble(), // Changed from toInt() to toDouble()
          // walletBalance: (data['walletBalance'] ?? 0).toInt(),
          totalRides: totalRides,
          // totalEarningsAsDriver: (data['totalEarningsAsDriver'] ?? 0).toInt(),
          fcmToken: data['fcmToken'],
        );

        _error = '';
      } else {
        _error = 'Failed to load profile data';
      }
    } catch (e) {
      log('Error fetching profile: $e'); // Debug log
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? username,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        log('No token found');
        return false;
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/updateProfile'),
      );

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add username if provided
      if (username != null) {
        request.fields['username'] = username;
      }

      // Add image if provided
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
        ));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        log('Profile updated successfully');
        return true;
      }

      log('Failed to update profile: ${jsonData['error']}');
      return false;
    } catch (e) {
      log('Error updating profile: $e');
      return false;
    }
  }

  void clearUserData() {
    _profileData = null;
    notifyListeners();
  }
}