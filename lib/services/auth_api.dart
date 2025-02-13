import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://api.yourapp.com"; // Replace with your API URL

  Future<http.Response> login(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }

  Future<http.Response> signup(String email, String password) {
    return http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }
}
