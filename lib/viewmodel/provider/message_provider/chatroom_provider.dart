
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:shared_preferences/shared_preferences.dart';

// class ChatRoomProvider with ChangeNotifier {
//   String? _chatroomId;
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _messages = [];
//   late io.Socket socket;

//   // Getters
//   String? get chatroomId => _chatroomId;
//   bool get isLoading => _isLoading;
//   List<Map<String, dynamic>> get messages => _messages;
//   String get baseUrl => Constants.apiBaseUrl;

//   // Initialize socket connection
//   void initSocket() {
//     socket = io.io(baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();
    
//     socket.on('connect', (_) => log('Socket connected'));
//     socket.on('receive-message', _handleNewMessage);
//     socket.on('disconnect', (_) => log('Socket disconnected'));
//   }

//   // Handle new socket message
//   void _handleNewMessage(dynamic data) {
//     final message = Map<String, dynamic>.from(data);
//     if (message['chat_Room_Id'] == _chatroomId) {
//       _messages.add(message);
//       notifyListeners();
//     }
//   }

//   // Get authentication token
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   // Check existing room
//   Future<String?> checkExistingRoom(String targetUserId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final token = await _getToken();
//       if (token == null) {
//         log('No authentication token found');
//         return null;
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/chat/getRooms'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final rooms = responseData['rooms'] as List;
        
//         for (var room in rooms) {
//           List<String> users = List<String>.from(room['users']);
//           if (users.contains(targetUserId)) {
//             _chatroomId = room['_id'];
//             await _saveRoomId(_chatroomId!);
//             return _chatroomId;
//           }
//         }
//       }
      
//       return null;
//     } catch (e) {
//       log('Error checking existing rooms: $e');
//       return null;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Save room ID
//   Future<void> _saveRoomId(String roomId) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('chatroom_id', roomId);
//   }

//   // Send message
//   Future<bool> sendMessage(String message) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final token = await _getToken();
//       if (token == null || _chatroomId == null) return false;

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/sendMessage/$_chatroomId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'message': message,
//           'messageType': 'text',
//         }),
//       );

//       return response.statusCode == 200;
//     } catch (e) {
//       log('Error sending message: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Get messages
//   Future<void> getMessages() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final token = await _getToken();
//       if (token == null || _chatroomId == null) return;

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/getMessage/$_chatroomId'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         _messages = List<Map<String, dynamic>>.from(responseData['messages']);
//         notifyListeners();
//       }
//     } catch (e) {
//       log('Error getting messages: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Create chatroom
//   Future<bool> createChatroom({
//     required String targetUserId,
//     String roomType = "Driver"
//   }) async {
//     try {
//       final existingRoomId = await checkExistingRoom(targetUserId);
//       if (existingRoomId != null) {
//         log('Found existing chatroom: $existingRoomId');
//         return true;
//       }

//       _isLoading = true;
//       notifyListeners();

//       final token = await _getToken();
//       if (token == null) return false;

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/createChatroom'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           "userId": targetUserId,
//           "roomType": roomType
//         }),
//       );

//       final responseData = jsonDecode(response.body);

//       if (responseData['message'] == "chatRoom created successfully") {
//         _chatroomId = responseData['result']['_id'];
//         await _saveRoomId(_chatroomId!);
//         return true;
//       }

//       return false;
//     } catch (e) {
//       log('Error creating chatroom: $e');
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Cleanup
//   @override
//   void dispose() {
//     socket.disconnect();
//     super.dispose();
//   }

//   // Clear chat room
//   Future<void> clearChatRoom() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('chatroom_id');
//     _chatroomId = null;
//     _messages.clear();
//     notifyListeners();
//   }
// }


import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoomProvider with ChangeNotifier {
  String? _chatroomId;
  bool _isLoading = false;
  bool _isSending = false;
  Set<String> _messageIds = {}; // Track message IDs
  List<Map<String, dynamic>> _messages = [];
  late io.Socket socket;

  // Getters
  String? get chatroomId => _chatroomId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  List<Map<String, dynamic>> get messages => _messages;
  String get baseUrl => Constants.apiBaseUrl;

  void initSocket() {
    socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    
    socket.on('connect', (_) => log('Socket connected'));
    socket.on('receive-message', _handleNewMessage);
    socket.on('disconnect', (_) => log('Socket disconnected'));
  }

  // Modified to handle duplicate messages
  void _handleNewMessage(dynamic data) {
    final message = Map<String, dynamic>.from(data);
    if (message['chat_Room_Id'] == _chatroomId) {
      final messageId = message['_id'];
      if (messageId != null && !_messageIds.contains(messageId)) {
        _messageIds.add(messageId);
        _messages.add(message);
        _messages.sort((a, b) => 
          DateTime.parse(a['createdOn']).compareTo(DateTime.parse(b['createdOn']))
        );
        notifyListeners();
      }
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> sendMessage(String message) async {
    try {
      if (_isSending) return false;
      _isSending = true;
      
      final token = await _getToken();
      if (token == null || _chatroomId == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/chat/sendMessage/$_chatroomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'messageType': 'text',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Error sending message: $e');
      return false;
    } finally {
      _isSending = false;
    }
  }

  // Modified to handle unique messages
  Future<void> getMessages() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token == null || _chatroomId == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/chat/getMessage/$_chatroomId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newMessages = List<Map<String, dynamic>>.from(responseData['messages']);
        
        // Clear existing messages and IDs
        _messages.clear();
        _messageIds.clear();

        // Add only unique messages
        for (var message in newMessages) {
          final messageId = message['_id'];
          if (messageId != null && !_messageIds.contains(messageId)) {
            _messageIds.add(messageId);
            _messages.add(message);
          }
        }

        // Sort messages by timestamp
        _messages.sort((a, b) => 
          DateTime.parse(a['createdOn']).compareTo(DateTime.parse(b['createdOn']))
        );
        
        notifyListeners();
      }
    } catch (e) {
      log('Error getting messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> checkExistingRoom(String targetUserId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token == null) {
        log('No authentication token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/chat/getRooms'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final rooms = responseData['rooms'] as List;
        
        for (var room in rooms) {
          List<String> users = List<String>.from(room['users']);
          if (users.contains(targetUserId)) {
            _chatroomId = room['_id'];
            await _saveRoomId(_chatroomId!);
            return _chatroomId;
          }
        }
      }
      
      return null;
    } catch (e) {
      log('Error checking existing rooms: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveRoomId(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatroom_id', roomId);
  }

  Future<bool> createChatroom({
    required String targetUserId,
    String roomType = "Driver"
  }) async {
    try {
      final existingRoomId = await checkExistingRoom(targetUserId);
      if (existingRoomId != null) {
        log('Found existing chatroom: $existingRoomId');
        return true;
      }

      _isLoading = true;
      notifyListeners();

      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/chat/createChatroom'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "userId": targetUserId,
          "roomType": roomType
        }),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['message'] == "chatRoom created successfully") {
        _chatroomId = responseData['result']['_id'];
        await _saveRoomId(_chatroomId!);
        return true;
      }

      return false;
    } catch (e) {
      log('Error creating chatroom: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    _messages.clear();
    _messageIds.clear();
    super.dispose();
  }

  Future<void> clearChatRoom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatroom_id');
    _chatroomId = null;
    _messages.clear();
    _messageIds.clear();
    notifyListeners();
  }
}