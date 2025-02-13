// class ProfileProvider with ChangeNotifier {
//   String _userName = '';
//   double _rating = 0.0;
//   String _phone = '';
//   String _email = '';
//   String _address = '';

//   String get userName => _userName;
//   double get rating => _rating;
//   String get phone => _phone;
//   String get email => _email;
//   String get address => _address;

//   Future<void> fetchProfileData() async {
//     final response = await http.get(Uri.parse('https://example.com/api/profile'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       _userName = data['name'];
//       _rating = data['rating'];
//       _phone = data['phone'];
//       _email = data['email'];
//       _address = data['address'];
//       notifyListeners();
//     } else {
//       throw Exception('Failed to load profile data');
//     }
//   }

//   Future<void> updateProfile(String name, String phone, String email, String address) async {
//     final response = await http.put(
//       Uri.parse('https://example.com/api/profile'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'name': name,
//         'phone': phone,
//         'email': email,
//         'address': address,
//       }),
//     );

//     if (response.statusCode == 200) {
//       _userName = name;
//       _phone = phone;
//       _email = email;
//       _address = address;
//       notifyListeners();
//     } else {
//       throw Exception('Failed to update profile');
//     }
//   }
// }


import 'dart:convert';

// profile_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  final String username;
  final String profilePicture;
  final String phone;
  final String email;
  final String driverLicense;
  final String address;
  final double ratingAverage;
  final int totalEarnings;
  final Map<String, int> totalRides;
  final List<int> ratings;

  ProfileData({
    required this.username,
    required this.profilePicture,
    required this.phone,
    required this.email,
    this.driverLicense = '',
    this.address = '',
    required this.ratingAverage,
    required this.totalEarnings,
    required this.totalRides,
    required this.ratings,
  });
}

class ProfileProvider with ChangeNotifier {
  ProfileData? _profileData;
  bool _isLoading = false;
  String _error = '';

  ProfileData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchProfileData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('https://m5nkcs2p-3000.inc1.devtunnels.ms/auth/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<int> ratings = [];
        
        if (data['driverDetails'] != null && data['driverDetails']['rating'] != null) {
          ratings = List<int>.from(
            data['driverDetails']['rating'].map((r) => r['rating'] as int)
          );
        }

        _profileData = ProfileData(
          username: data['username'] ?? '',
          profilePicture: data['profilePicture'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          driverLicense: data['driverDetails']?['driverLicense'] ?? '',
          address: data['address'] ?? '',
          ratingAverage: (data['driverDetails']?['ratingAverage'] ?? 0).toDouble(),
          totalEarnings: data['totalEarningsAsDriver'] ?? 0,
          totalRides: {
            'asPassenger': data['totalRides']?['asPassenger'] ?? 0,
            'asDriver': data['totalRides']?['asDriver'] ?? 0,
            'total': data['totalRides']?['total'] ?? 0,
          },
          ratings: ratings,
        );
        _error = '';
      } else {
        _error = 'Failed to load profile data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}