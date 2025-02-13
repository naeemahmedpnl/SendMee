// import 'dart:convert';
import 'package:sendme/models/user_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class UserDataCache {
  static User? _userData;

  static Future<User?> getUserData() async {
    return _userData;
  }

  static Future<void> setUserData(Map<String, dynamic> data) async {
    _userData = User.fromJson(data);
  }

  static Future<void> clearUserData() async {
    _userData = null;
  }
}

// // class UserDataCache {
//   static const String _userDataKey = 'userData';
//   static const String _lastFetchTimeKey = 'lastUserDataFetchTime';
//   static const Duration _cacheDuration = Duration(hours: 1);

//   static Future<Map<String, dynamic>?> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastFetchTime = prefs.getInt(_lastFetchTimeKey) ?? 0;
//     final currentTime = DateTime.now().millisecondsSinceEpoch;

//     if (currentTime - lastFetchTime < _cacheDuration.inMilliseconds) {
//       final cachedData = prefs.getString(_userDataKey);
//       if (cachedData != null) {
//         return json.decode(cachedData);
//       }
//     }

//     return null;
//   }

//   static Future<void> setUserData(Map<String, dynamic> userData) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userDataKey, json.encode(userData));
//     await prefs.setInt(_lastFetchTimeKey, DateTime.now().millisecondsSinceEpoch);
//   }
// }