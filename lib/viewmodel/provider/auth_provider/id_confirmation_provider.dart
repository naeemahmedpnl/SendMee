import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';


class IdConfirmationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

    // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

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
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields['isDriver'] = 'false'
      ..files.add(await http.MultipartFile.fromPath('idcardFront', frontPath, filename: 'front.jpg'))
      ..files.add(await http.MultipartFile.fromPath('idcardBack', backPath, filename: 'back.jpg'));
       

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return true;
      }
      
      _error = 'Upload failed with status: ${response.statusCode}';
      return false;
      
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}