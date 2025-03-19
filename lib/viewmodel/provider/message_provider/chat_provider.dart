

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sendme/models/messeage_model.dart';

class ChatMessageProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;

  String get baseUrl => Constants.apiBaseUrl;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Send Message
  Future<bool> sendMessage({
    required String chatroomId,
    required String message,
    String messageType = "text"
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        log('No token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/sendMessage/$chatroomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "message": message,
          "messageType": messageType
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Create new message from response
        if (responseData['message'] != null) {
          final newMessage = Message.fromJson(responseData['message']);
          _messages.insert(0, newMessage);
          notifyListeners();
        }
        return true;
      }

      log('Failed to send message: ${response.body}');
      return false;
    } catch (e) {
      log('Error sending message: $e');
      return false;
    }
  }

  // Get Messages
  Future<void> getMessages(String chatroomId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        log('No token found');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.post( 
        Uri.parse('$baseUrl/chat/getMessage/$chatroomId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['messages'] != null && data['messages'] is List) {
          _messages = (data['messages'] as List)
              .map((messageData) => Message.fromJson(messageData))
              .toList();
          
          // Sort messages by timestamp if needed
          _messages.sort((a, b) => b.createdOn.compareTo(a.createdOn));
        } else {
          _messages = [];
        }
      } else {
        log('Failed to get messages: ${response.body}');
        _messages = [];
      }
    } catch (e) {
      log('Error getting messages: $e');
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to handle errors
  void _handleError(String message, dynamic error) {
    log('$message: $error');
    _isLoading = false;
    notifyListeners();
  }

  // Clear messages
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  // Debug method to print message data
  void debugPrintMessages() {
    log('Current messages:');
    for (var message in _messages) {
      log('ID: ${message.id}');
      log('Content: ${message.content}');
      log('Sender: ${message.senderId}');
      log('Created: ${message.createdOn}');
      log('-------------------');
    }
  }
}