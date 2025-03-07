// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:sendme/models/driver_registration_model.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DriverRegistrationProvider extends ChangeNotifier {
//   final SharedPreferences _prefs;
//   DriverRegistrationModel _formData = DriverRegistrationModel();
//   bool _isLoading = false;
//   String? _error;

//   // Use a getter for the base URL
//   String get baseUrl => Constants.apiBaseUrl;

//   // Getters
//   DriverRegistrationModel get formData => _formData;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   DriverRegistrationProvider(this._prefs) {
//     loadSavedData();
//   }

//   // Load saved data
//   Future<void> loadSavedData() async {
//     try {
//       final savedData = _prefs.getString('driver_registration_data');
//       if (savedData != null) {
//         _formData = DriverRegistrationModel.fromJson(jsonDecode(savedData));
//         notifyListeners();
//       }
//     } catch (e) {
//       _error = 'Error loading saved data: $e';
//       notifyListeners();
//     }
//   }

//   // Save current data
//   Future<void> _saveData() async {
//     try {
//       await _prefs.setString(
//           'driver_registration_data', jsonEncode(_formData.toJson()));
//     } catch (e) {
//       _error = 'Error saving data: $e';
//       notifyListeners();
//     }
//   }

//   // Basic Info Form with DOB

//   Future<bool> saveBasicInfo({
//     required String username,
//     required String phone,
//     required String profilePicture,
//     required String address,
//     required String dob, 
//   }) async {
//     try {
//       _formData.username = username;
//       _formData.phone = phone;
//       _formData.profilePicture = profilePicture;
//       _formData.address = address; 
//       _formData.dob = dob; 

//       await _saveData();
//       return true;
//     } catch (e) {
//       _error = 'Error saving basic info: $e';
//       notifyListeners();
//       return false;
//     }
//   }


//   // Driver License Form
//   Future<bool> saveDriverLicense(String driverLicense) async {
//     try {
//       _formData.driverLicense = driverLicense;
//       await _saveData();
//       return true;
//     } catch (e) {
//       _error = 'Error saving driver license: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   // ID Confirmation Form
//   Future<bool> saveIdConfirmation({
//     required String voterID,
//     String? passport,
//   }) async {
//     try {
//       _formData.voterID = voterID;
//       _formData.passport = passport;
//       await _saveData();
//       return true;
//     } catch (e) {
//       _error = 'Error saving ID confirmation: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   // Proof of Address Form
//   Future<bool> saveProofOfAddress(String proofOfAddress) async {
//     try {
//       _formData.proofOfAddress = proofOfAddress;
//       await _saveData();
//       return true;
//     } catch (e) {
//       _error = 'Error saving proof of address: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   // Vehicle Info Form
//   Future<bool> saveVehicleInfo({
//     required String licensePlateNumber,
//     required String color,
//     required String year,
//     required String model,
//     required List<String> photos,
//   }) async {
//     try {
//       _formData.motorcycleLicensePlateNumber = licensePlateNumber;
//       _formData.motorcycleColor = color;
//       _formData.motorcycleYear = year;
//       _formData.motorcycleModel = model;
//       _formData.motorcyclePhotos = photos;
//       await _saveData();
//       return true;
//     } catch (e) {
//       _error = 'Error saving vehicle info: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   // Submit Registration

// // Modify the submitRegistration method to include logging
//   Future<bool> submitRegistration() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       final dio = Dio();
//       dio.interceptors.add(LogInterceptor(
//         requestHeader: true,
//         requestBody: true,
//         responseHeader: true,
//         responseBody: true,
//         error: true,
//         logPrint: (object) => debugPrint(object.toString()),
//       ));

//       // Base form data
//       Map<String, dynamic> formMap = {
//         'username': _formData.username,
//         'address': _formData.address,
//         'dob': _formData.dob,
//         'phone': _formData.phone,
//         'isDriver': 'true',
//         'registrationType': 'gmail',
//       };

//       // Only add motorcycle details if all required fields are present
//       if (_formData.hasMotorcycleDetails) {
//         formMap.addAll({
//           'motorcycleLicensePlateNumber':
//               _formData.motorcycleLicensePlateNumber,
//           'motorcycleColor': _formData.motorcycleColor,
//           'motorcycleYear': _formData.motorcycleYear,
//           'motorcycleModel': _formData.motorcycleModel,
//         });
//       }

//       final formData = FormData();

//       // Add all regular fields
//       formMap.forEach((key, value) {
//         if (value != null && value.toString().isNotEmpty) {
//           formData.fields.add(MapEntry(key, value.toString()));
//           log('📝 Added field $key: $value');
//         }
//       });

//       // Handle required file uploads
//       if (_formData.profilePicture?.isNotEmpty == true) {
//         formData.files.add(MapEntry(
//           'profilePicture',
//           await MultipartFile.fromFile(_formData.profilePicture!,
//               filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'),
//         ));
//         log('📸 Added profile picture');
//       }

//       if (_formData.driverLicense?.isNotEmpty == true) {
//         formData.files.add(MapEntry(
//           'driverLicense',
//           await MultipartFile.fromFile(_formData.driverLicense!,
//               filename: 'license_${DateTime.now().millisecondsSinceEpoch}.jpg'),
//         ));
//         log('📸 Added driver license');
//       }

//       if (_formData.voterID?.isNotEmpty == true) {
//         formData.files.add(MapEntry(
//           'voterID',
//           await MultipartFile.fromFile(_formData.voterID!,
//               filename: 'voter_${DateTime.now().millisecondsSinceEpoch}.jpg'),
//         ));
//         log('📸 Added voter ID');
//       }

//       if (_formData.passport?.isNotEmpty == true) {
//         formData.files.add(MapEntry(
//           'passport',
//           await MultipartFile.fromFile(_formData.passport!,
//               filename:
//                   'passport_${DateTime.now().millisecondsSinceEpoch}.jpg'),
//         ));
//         log('📸 Added passport');
//       }

//       if (_formData.proofOfAddress?.isNotEmpty == true) {
//         formData.files.add(MapEntry(
//           'proofOfAddress',
//           await MultipartFile.fromFile(_formData.proofOfAddress!,
//               filename: 'address_${DateTime.now().millisecondsSinceEpoch}.jpg'),
//         ));
//         log('📸 Added proof of address');
//       }

//       // Add motorcycle photos if motorcycle details are present
//       if (formMap.containsKey('motorcycleLicensePlateNumber') &&
//           _formData.motorcyclePhotos.isNotEmpty) {
//         for (var i = 0; i < _formData.motorcyclePhotos.length; i++) {
//           try {
//             formData.files.add(MapEntry(
//               'motorcyclePhotos',
//               await MultipartFile.fromFile(_formData.motorcyclePhotos[i],
//                   filename:
//                       'motorcycle_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg'),
//             ));
//             log('📸 Added motorcycle photo $i: ${_formData.motorcyclePhotos[i]}');
//           } catch (e) {
//             log('❌ Error adding motorcycle photo $i: $e');
//           }
//         }
//       }

//       log('🚀 Sending registration request to: $baseUrl/auth/register');

//       final response = await dio.post(
//         '$baseUrl/auth/register',
//         data: formData,
//         options: Options(
//           followRedirects: false,
//           validateStatus: (status) => status! < 500,
//           headers: {
//             'Accept': 'application/json',
//             'Content-Type': 'multipart/form-data',
//           },
//         ),
//       );

//       if (response.statusCode == 201) {
//         log('✅ Registration successful');
//         await _prefs.remove('driver_registration_data');
//         return true;
//       } else {
//         log('❌ Registration failed with status: ${response.statusCode}');
//         _error = response.data['error'] ??
//             response.data['message'] ??
//             'Registration failed';
//         return false;
//       }
//     } on DioException catch (e) {
//       log('❌ Network error: ${e.message}');
//       log('Error response: ${e.response?.data}');
//       _error = e.response?.data?['error'] ??
//           e.response?.data?['message'] ??
//           'Network error occurred';
//       return false;
//     } catch (e) {
//       log('❌ Error: $e');
//       _error = 'Registration error: $e';
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Clear all saved data
//   Future<void> clearData() async {
//     try {
//       await _prefs.remove('driver_registration_data');
//       _formData = DriverRegistrationModel();
//       notifyListeners();
//     } catch (e) {
//       _error = 'Error clearing data: $e';
//       notifyListeners();
//     }
//   }
// }


import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sendme/models/driver_registration_model.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverRegistrationProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  DriverRegistrationModel _formData = DriverRegistrationModel();
  bool _isLoading = false;
  String? _error;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  // Getters
  DriverRegistrationModel get formData => _formData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constants for storage keys
  static const String _registrationDataKey = 'driver_registration_data';

  DriverRegistrationProvider(this._prefs) {
    loadSavedData();
  }

  // Load saved data
  Future<void> loadSavedData() async {
    try {
      final savedData = _prefs.getString(_registrationDataKey);
      if (savedData != null) {
        _formData = DriverRegistrationModel.fromJson(jsonDecode(savedData));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error loading saved data: $e';
      notifyListeners();
    }
  }

  // Save current data
  Future<void> _saveData() async {
    try {
      await _prefs.setString(
          _registrationDataKey, jsonEncode(_formData.toJson()));
    } catch (e) {
      _error = 'Error saving data: $e';
      notifyListeners();
    }
  }

  // Basic Info Form with DOB
  Future<bool> saveBasicInfo({
    required String username,
    required String phone,
    required String profilePicture,
    required String address,
    required String dob, 
  }) async {
    try {
      _formData.username = username;
      _formData.phone = phone;
      _formData.profilePicture = profilePicture;
      _formData.address = address; 
      _formData.dob = dob; 

      await _saveData();
      return true;
    } catch (e) {
      _error = 'Error saving basic info: $e';
      notifyListeners();
      return false;
    }
  }

  // Driver License Form
  Future<bool> saveDriverLicense(String driverLicense) async {
    try {
      _formData.driverLicense = driverLicense;
      await _saveData();
      return true;
    } catch (e) {
      _error = 'Error saving driver license: $e';
      notifyListeners();
      return false;
    }
  }

  // ID Confirmation Form
  Future<bool> saveIdConfirmation({
    required String voterID,
    String? passport,
  }) async {
    try {
      _formData.voterID = voterID;
      _formData.passport = passport;
      await _saveData();
      return true;
    } catch (e) {
      _error = 'Error saving ID confirmation: $e';
      notifyListeners();
      return false;
    }
  }

  // Proof of Address Form
  Future<bool> saveProofOfAddress(String proofOfAddress) async {
    try {
      _formData.proofOfAddress = proofOfAddress;
      await _saveData();
      return true;
    } catch (e) {
      _error = 'Error saving proof of address: $e';
      notifyListeners();
      return false;
    }
  }

  // Vehicle Info Form
  Future<bool> saveVehicleInfo({
    required String licensePlateNumber,
    required String color,
    required String year,
    required String model,
    required List<String> photos,
  }) async {
    try {
      _formData.motorcycleLicensePlateNumber = licensePlateNumber;
      _formData.motorcycleColor = color;
      _formData.motorcycleYear = year;
      _formData.motorcycleModel = model;
      _formData.motorcyclePhotos = photos;
      await _saveData();
      return true;
    } catch (e) {
      _error = 'Error saving vehicle info: $e';
      notifyListeners();
      return false;
    }
  }

  // Submit Registration with hardcoded service type
  Future<bool> submitRegistration() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use hardcoded 'parcel' as service type
      const serviceType = 'parcel';
      log('Using hardcoded service type for registration: $serviceType');

      final dio = Dio();
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));

      // Base form data with hardcoded service type
      Map<String, dynamic> formMap = {
        'username': _formData.username,
        'address': _formData.address,
        'dob': _formData.dob,
        'phone': _formData.phone,
        'isDriver': 'true',
        'registrationType': 'gmail',
        'serviceType': serviceType, // Hardcoded 'parcel'
      };

      // Only add motorcycle details if all required fields are present
      if (_formData.hasMotorcycleDetails) {
        formMap.addAll({
          'motorcycleLicensePlateNumber':
              _formData.motorcycleLicensePlateNumber,
          'motorcycleColor': _formData.motorcycleColor,
          'motorcycleYear': _formData.motorcycleYear,
          'motorcycleModel': _formData.motorcycleModel,
        });
      }

      final formData = FormData();

      // Add all regular fields
      formMap.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          formData.fields.add(MapEntry(key, value.toString()));
          log('Added field $key: $value');
        }
      });

      // Handle required file uploads
      if (_formData.profilePicture?.isNotEmpty == true) {
        formData.files.add(MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(_formData.profilePicture!,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        ));
        log('Added profile picture');
      }

      if (_formData.driverLicense?.isNotEmpty == true) {
        formData.files.add(MapEntry(
          'driverLicense',
          await MultipartFile.fromFile(_formData.driverLicense!,
              filename: 'license_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        ));
        log('Added driver license');
      }

      if (_formData.voterID?.isNotEmpty == true) {
        formData.files.add(MapEntry(
          'voterID',
          await MultipartFile.fromFile(_formData.voterID!,
              filename: 'voter_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        ));
        log('Added voter ID');
      }

      if (_formData.passport?.isNotEmpty == true) {
        formData.files.add(MapEntry(
          'passport',
          await MultipartFile.fromFile(_formData.passport!,
              filename:
                  'passport_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        ));
        log('Added passport');
      }

      if (_formData.proofOfAddress?.isNotEmpty == true) {
        formData.files.add(MapEntry(
          'proofOfAddress',
          await MultipartFile.fromFile(_formData.proofOfAddress!,
              filename: 'address_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        ));
        log('Added proof of address');
      }

      // Add motorcycle photos if motorcycle details are present
      if (formMap.containsKey('motorcycleLicensePlateNumber') &&
          _formData.motorcyclePhotos.isNotEmpty) {
        for (var i = 0; i < _formData.motorcyclePhotos.length; i++) {
          try {
            formData.files.add(MapEntry(
              'motorcyclePhotos',
              await MultipartFile.fromFile(_formData.motorcyclePhotos[i],
                  filename:
                      'motorcycle_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg'),
            ));
            log('Added motorcycle photo $i: ${_formData.motorcyclePhotos[i]}');
          } catch (e) {
            log('Error adding motorcycle photo $i: $e');
          }
        }
      }

      log('Sending registration request to: $baseUrl/auth/register');
      log('Service type being sent: $serviceType');

      final response = await dio.post(
        '$baseUrl/auth/register',
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        log('Registration successful');
        await _prefs.remove(_registrationDataKey);
        return true;
      } else {
        log('Registration failed with status: ${response.statusCode}');
        _error = response.data['error'] ??
            response.data['message'] ??
            'Registration failed';
        return false;
      }
    } on DioException catch (e) {
      log('Network error: ${e.message}');
      log('Error response: ${e.response?.data}');
      _error = e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          'Network error occurred';
      return false;
    } catch (e) {
      log('Error: $e');
      _error = 'Registration error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all saved data
  Future<void> clearData() async {
    try {
      await _prefs.remove(_registrationDataKey);
      _formData = DriverRegistrationModel();
      notifyListeners();
    } catch (e) {
      _error = 'Error clearing data: $e';
      notifyListeners();
    }
  }
}