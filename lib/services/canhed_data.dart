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

