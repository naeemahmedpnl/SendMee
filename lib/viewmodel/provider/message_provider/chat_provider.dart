// // import 'package:flutter/foundation.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:sendme/utils/constant/api_base_url.dart';
// // import 'dart:developer' as developer;

// // class ChatProvider with ChangeNotifier {
// //   List<Message> _messages = [];
// //   List<Message> get messages => _messages;

// //   String? _currentChatroomId;
// //   String? get currentChatroomId => _currentChatroomId;

// //   bool _isLoading = false;
// //   bool get isLoading => _isLoading;

// //   String get baseUrl => Constants.apiBaseUrl;

// //   Future<void> initialize() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     _currentChatroomId = prefs.getString('chatroom_id');
// //     log('Initializing ChatProvider', name: 'ChatProvider');
// //     log('Current Chatroom ID: $_currentChatroomId', name: 'ChatProvider');
    
// //     // Log all SharedPreferences keys and values
// //     log('All SharedPreferences:', name: 'ChatProvider');
// //     prefs.getKeys().forEach((key) {
// //       log('$key: ${prefs.get(key)}', name: 'ChatProvider');
// //     });
// //   }

// //   Future<void> getMessages(String chatroomId) async {
// //     _isLoading = true;
// //     notifyListeners();

// //     log('Getting messages for chatroom: $chatroomId', name: 'ChatProvider');

// //     final token = await _getToken();
// //     if (token == null) {
// //       log('No authentication token found', name: 'ChatProvider', error: 'Authentication Error');
// //       _isLoading = false;
// //       notifyListeners();
// //       return;
// //     }

// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/chat/getMessage/$chatroomId'),
// //         headers: {'Authorization': 'Bearer $token'},
// //       );

// //       log('getMessage Response Status: ${response.statusCode}', name: 'ChatProvider');
// //       log('getMessage Response Body: ${response.body}', name: 'ChatProvider');

// //       if (response.statusCode == 200) {
// //         final List<dynamic> messageData = jsonDecode(response.body);
// //         _messages = messageData.map((data) => Message.fromJson(data)).toList();
// //         _currentChatroomId = chatroomId;
// //         log('Parsed ${_messages.length} messages', name: 'ChatProvider');
// //         notifyListeners();
// //       } else {
// //         log('Failed to fetch messages. Status code: ${response.statusCode}', name: 'ChatProvider', error: 'API Error');
// //       }
// //     } catch (e) {
// //       log('Error fetching messages', name: 'ChatProvider', error: e.toString());
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   Future<void> sendMessage(String content) async {
// //     log('Attempting to send message: $content', name: 'ChatProvider');

// //     if (_currentChatroomId == null) {
// //       log('No active chatroom', name: 'ChatProvider', error: 'Chatroom Error');
// //       return;
// //     }

// //     final token = await _getToken();
// //     if (token == null) {
// //       log('No authentication token found', name: 'ChatProvider', error: 'Authentication Error');
// //       return;
// //     }

// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/chat/sendMessage/$_currentChatroomId'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //         body: jsonEncode({
// //           "message": content,
// //           "messageType": "text"
// //         }),
// //       );

// //       log('sendMessage Response Status: ${response.statusCode}', name: 'ChatProvider');
// //       log('sendMessage Response Body: ${response.body}', name: 'ChatProvider');

// //       if (response.statusCode == 200) {
// //         _messages.add(Message(content: content, isSentByMe: true));
// //         log('Message sent successfully and added to local list', name: 'ChatProvider');
// //         notifyListeners();
// //       } else {
// //         log('Failed to send message. Status code: ${response.statusCode}', name: 'ChatProvider', error: 'API Error');
// //       }
// //     } catch (e) {
// //       log('Error sending message', name: 'ChatProvider', error: e.toString());
// //     }
// //   }

// //   Future<String?> _getToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final token = prefs.getString('token');
// //     log('Retrieved token: ${token != null ? 'Token found' : 'Token not found'}', name: 'ChatProvider');
// //     return token;
// //   }
// // }

// // class Message {
// //   final String content;
// //   final bool isSentByMe;

// //   Message({required this.content, required this.isSentByMe});

// //   factory Message.fromJson(Map<String, dynamic> json) {
// //     log('Parsing message from JSON: $json', name: 'Message');
// //     return Message(
// //       content: json['message'] ?? '',
// //       isSentByMe: json['isSentByMe'] ?? false, // Adjust this based on your API response
// //     );
// //   }
// // }



// import 'dart:developer';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:sendme/models/messeage_model.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChatProvider with ChangeNotifier {
//   List<Message> _messages = [];
//   List<Message> get messages => _messages;

//   String? _currentChatroomId;
//   String? get currentChatroomId => _currentChatroomId;

//   String? _currentUserId;
//   String? get currentUserId => _currentUserId;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String get baseUrl => Constants.apiBaseUrl;

//   IO.Socket? socket;

//   Future<void> initialize() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Get all keys
//     final keys = prefs.getKeys();
    
//     log('📱 SharedPreferences Data:');
//     log('----------------------------------------');
    
//     // Print each key-value pair
//     for (String key in keys) {
//       final value = prefs.get(key);
//       log('🔑 Key: $key');
//       log('📄 Value: $value');
//       log('📝 Type: ${value.runtimeType}');
//       log('----------------------------------------');
//     }
    
//     // Print total count
//     log('Total Items: ${keys.length}');
//     _currentChatroomId = prefs.getString('chatroom_id');
//     _currentUserId = prefs.getString('user');
//     log('Initializing ChatProvider', name: 'ChatProvider');
//     log('Current Chatroom ID: $_currentChatroomId', name: 'ChatProvider');
//     log('Current User ID: $_currentUserId', name: 'ChatProvider');
    
//     // Log all SharedPreferences keys and values
//     log('All SharedPreferences:', name: 'ChatProvider');
//     prefs.getKeys().forEach((key) {
//       log('$key: ${prefs.get(key)}', name: 'ChatProvider');
//     });
//     _initializeSocket();
//   }

//   void _initializeSocket() {
//     socket = IO.io('${Constants.apiBaseUrl}', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket?.connect();
//     socket?.on('connect', (_) => print('Connected to Socket.IO server'));
//     socket?.on('receive-message', _handleNewMessage);
//   }

//   void _handleNewMessage(dynamic data) {
//     final newMessage = Message.fromJson(data);
//     _messages.insert(0, newMessage); 
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     socket?.disconnect();
//     super.dispose();
//   }

//   Future<void> getMessages(String chatroomId) async {
//     _isLoading = true;
//     notifyListeners();

//     log('Getting messages for chatroom: $chatroomId', name: 'ChatProvider');

//     final token = await _getToken();
//     if (token == null) {
//       log('No authentication token found', name: 'ChatProvider', error: 'Authentication Error');
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/getMessage/$chatroomId'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       log('getMessage Response Status: ${response.statusCode}', name: 'ChatProvider');
//       log('getMessage Response Body: ${response.body}', name: 'ChatProvider');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         if (responseData.containsKey('messages')) {
//           final List<dynamic> messageData = responseData['messages'];
//           _messages = messageData.map((data) => Message.fromJson(data)).toList();
//           _currentChatroomId = chatroomId;
//           log('Parsed ${_messages.length} messages', name: 'ChatProvider');
//         } else {
//           log('Response does not contain "messages" key', name: 'ChatProvider', error: 'API Response Error');
//           _messages = [];
//         }
//         notifyListeners();
//       } else {
//         log('Failed to fetch messages. Status code: ${response.statusCode}', name: 'ChatProvider', error: 'API Error');
//       }
//     } catch (e, stackTrace) {
//       log('Error fetching messages', name: 'ChatProvider', error: e.toString());
//       log('Stack trace: $stackTrace', name: 'ChatProvider');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> sendMessage(String content) async {
//     log('Attempting to send message: $content', name: 'ChatProvider');

//     if (_currentChatroomId == null) {
//       log('No active chatroom', name: 'ChatProvider', error: 'Chatroom Error');
//       return;
//     }

//     final token = await _getToken();
//     if (token == null) {
//       log('No authentication token found', name: 'ChatProvider', error: 'Authentication Error');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/sendMessage/$_currentChatroomId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           "message": content,
//           "messageType": "text"
//         }),
//       );

//       if (response.statusCode == 200) {
//         log('Message sent successfully', name: 'ChatProvider');
//         // Don't add the message to the local list here
//         // The socket will receive the message and add it
//       } else {
//         log('Failed to send message. Status code: ${response.statusCode}', name: 'ChatProvider', error: 'API Error');
//       }
//     } catch (e, stackTrace) {
//       log('Error sending message', name: 'ChatProvider', error: e.toString());
//       log('Stack trace: $stackTrace', name: 'ChatProvider');
//     }
//   }



// Future<void> sendImageMessage(List<File> images) async {
//     if (_currentChatroomId == null) {
//       log('No active chatroom', name: 'ChatProvider');
//       return;
//     }

//     final token = await _getToken();
//     if (token == null) {
//       log('No authentication token found', name: 'ChatProvider');
//       return;
//     }

//     try {
//       List<String> base64Images = [];
      
//       // Convert images to base64
//       for (var image in images) {
//         List<int> imageBytes = await image.readAsBytes();
//         String base64Image = 'data:image/png;base64,${base64Encode(imageBytes)}';
//         base64Images.add(base64Image);
//       }

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/sendMessage/$_currentChatroomId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           "messageType": "image",
//           "files": base64Images,
//         }),
//       );

//       if (response.statusCode == 200) {
//         log('Image sent successfully', name: 'ChatProvider');
//       } else {
//         log(
//           'Failed to send image. Status: ${response.statusCode}',
//           name: 'ChatProvider',
//         );
//       }
//     } catch (e, stackTrace) {
//       log('Error sending image', name: 'ChatProvider', error: e.toString());
//       log('Stack trace: $stackTrace', name: 'ChatProvider');
//     }
//   }

 

//   // Image picker method
//   Future<void> pickAndSendImages() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final List<XFile> images = await picker.pickMultiImage();
      
//       if (images.isNotEmpty) {
//         List<File> imageFiles = images.map((xFile) => File(xFile.path)).toList();
//         await sendImageMessage(imageFiles);
//       }
//     } catch (e) {
//       log('Error picking images', name: 'ChatProvider', error: e.toString());
//     }
//   }



//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     log('Retrieved token: ${token != null ? 'Token found' : 'Token not found'}', name: 'ChatProvider');
//     return token;
//   }
// }




// import 'dart:developer';
// // import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// import 'package:sendme/models/messeage_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;


// class ChatProvider with ChangeNotifier {
//   List<Message> _messages = [];
//   List<Message> get messages => _messages;

//   String? _currentChatroomId;
//   String? get currentChatroomId => _currentChatroomId;

//   String? _currentUserId;
//   String? get currentUserId => _currentUserId;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String get baseUrl => Constants.apiBaseUrl;

//   IO.Socket? socket;

//   Future<void> initialize() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _currentChatroomId = prefs.getString('chatroom_id');
//       // _currentUserId = prefs.getString('_id');
      
//       // Add more detailed logging
//       log('Initializing ChatProvider');
//       log('Current Chatroom ID: $_currentChatroomId');
//       log('Current User ID: $_currentUserId');
      
//       if (_currentUserId == null) {
//         log('Warning: Current user ID is null during initialization');
//         throw Exception('User ID not found');
//       }

//       // Verify user authentication
//       final token = await _getToken();
//       if (token == null) {
//         log('Warning: No authentication token found during initialization');
//         throw Exception('Authentication token not found');
//       }

//       _initializeSocket();
//     } catch (e) {
//       log('Error initializing ChatProvider: $e');
//       rethrow;
//     }
//   }

//   void _initializeSocket() {
//     try {
//       socket = IO.io('${Constants.apiBaseUrl}', <String, dynamic>{
//         'transports': ['websocket'],
//         'autoConnect': false,
//       });

//       socket?.connect();
      
//       socket?.on('connect', (_) {
//         log('Socket connected with userId: $_currentUserId');
//       });

//       socket?.on('disconnect', (_) {
//         log('Socket disconnected');
//       });

//       socket?.on('error', (error) {
//         log('Socket error: $error');
//       });

//       socket?.on('receive-message', _handleNewMessage);
//     } catch (e) {
//       log('Error initializing socket: $e');
//     }
//   }

//   void _handleNewMessage(dynamic data) {
//     try {
//       log('Received new message: $data');
//       final newMessage = Message.fromJson(data);
      
//       _messages.add(newMessage);
//       notifyListeners();
      
//       log('Message added - From: ${newMessage.senderId}, Current User: $_currentUserId');
//     } catch (e) {
//       log('Error handling new message: $e');
//     }
//   }

//   Future<void> sendMessage(String content) async {
//     if (_currentUserId == null) {
//       log('Cannot send message: Current user ID is null');
//       throw Exception('User not initialized');
//     }

//     if (_currentChatroomId == null) {
//       log('Cannot send message: No active chatroom');
//       throw Exception('No active chatroom');
//     }

//     if (content.trim().isEmpty) {
//       log('Cannot send empty message');
//       return;
//     }

//     final token = await _getToken();
//     if (token == null) {
//       log('Cannot send message: No token');
//       throw Exception('Authentication token not found');
//     }

//     try {
//       // Create message locally first
//       final newMessage = Message(
//         senderId: _currentUserId!, // Safe to use ! here as we checked above
//         content: content,
//         messageType: 'text',
//         createdOn: DateTime.now(),
//         id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
//       );

//       // Add to local messages immediately
//       _messages.add(newMessage);
//       notifyListeners();

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/sendMessage/$_currentChatroomId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           "message": content,
//           "messageType": "text"
//         }),
//       );

//       if (response.statusCode != 200) {
//         // Remove message if send failed
//         _messages.remove(newMessage);
//         notifyListeners();
//         throw Exception('Failed to send message: ${response.statusCode}');
//       }

//       log('Message sent successfully. From: $_currentUserId');
//     } catch (e) {
//       log('Error sending message: $e');
//       rethrow;
//     }
//   }

//   Future<void> getMessages(String chatroomId) async {
//     if (_currentUserId == null) {
//       log('Cannot get messages: User not initialized');
//       throw Exception('User not initialized');
//     }

//     _isLoading = true;
//     notifyListeners();

//     final token = await _getToken();
//     if (token == null) {
//       _isLoading = false;
//       notifyListeners();
//       throw Exception('Authentication token not found');
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/getMessage/$chatroomId'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       log('Get messages response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         if (responseData.containsKey('messages')) {
//           final List<dynamic> messageData = responseData['messages'];
//           _messages = messageData.map((data) => Message.fromJson(data)).toList();
//           _currentChatroomId = chatroomId;
          
//           _messages.forEach((msg) {
//             log('Message - From: ${msg.senderId}, Type: ${msg.messageType}');
//           });
//         } else {
//           log('No messages found in response');
//           _messages = [];
//         }
//       } else {
//         throw Exception('Failed to fetch messages: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error fetching messages: $e');
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//   Future<String?> _getToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       log('Retrieved token: ${token != null ? 'Token found' : 'Token not found'}');
//       return token;
//     } catch (e) {
//       log('Error getting token: $e');
//       return null;
//     }
//   }

//   void clearChat() {
//     _messages = [];
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     try {
//       socket?.disconnect();
//       socket?.dispose();
//       clearChat();
//       super.dispose();
//     } catch (e) {
//       log('Error disposing ChatProvider: $e');
//     }
//   }

//   // Rest of your code remains the same...
// }

// // class ChatProvider with ChangeNotifier {
// //   List<Message> _messages = [];
// //   List<Message> get messages => _messages;

// //   String? _currentChatroomId;
// //   String? get currentChatroomId => _currentChatroomId;

// //   String? _currentUserId;
// //   String? get currentUserId => _currentUserId;

// //   bool _isLoading = false;
// //   bool get isLoading => _isLoading;

// //   String get baseUrl => Constants.apiBaseUrl;

// //   IO.Socket? socket;

// //   Future<void> initialize() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       _currentChatroomId = prefs.getString('chatroom_id');
// //       _currentUserId = prefs.getString('user_id');
      
// //       // Add more detailed logging
// //       log('Initializing ChatProvider');
// //       log('Current Chatroom ID: $_currentChatroomId');
// //       log('Current User ID: $_currentUserId');
      
// //       // Verify user authentication
// //       final token = await _getToken();
// //       if (token == null) {
// //         log('Warning: No authentication token found during initialization');
// //       }

// //       _initializeSocket();
// //     } catch (e) {
// //       log('Error initializing ChatProvider: $e');
// //       rethrow; // Rethrow to handle in UI
// //     }
// //   }

// //   void _initializeSocket() {
// //     try {
// //       socket = IO.io('${Constants.apiBaseUrl}', <String, dynamic>{
// //         'transports': ['websocket'],
// //         'autoConnect': false,
// //       });

// //       socket?.connect();
      
// //       socket?.on('connect', (_) {
// //         log('Socket connected with userId: $_currentUserId');
// //       });

// //       socket?.on('disconnect', (_) {
// //         log('Socket disconnected');
// //       });

// //       socket?.on('error', (error) {
// //         log('Socket error: $error');
// //       });

// //       socket?.on('receive-message', _handleNewMessage);
// //     } catch (e) {
// //       log('Error initializing socket: $e');
// //     }
// //   }

// //   void _handleNewMessage(dynamic data) {
// //     try {
// //       log('Received new message: $data');
// //       final newMessage = Message.fromJson(data);
      
// //       // Add message to end instead of beginning
// //       _messages.add(newMessage);
// //       notifyListeners();
      
// //       log('Message added - From: ${newMessage.senderId}, Current User: $_currentUserId');
// //     } catch (e) {
// //       log('Error handling new message: $e');
// //     }
// //   }

// //   Future<void> getMessages(String chatroomId) async {
// //     _isLoading = true;
// //     notifyListeners();

// //     final token = await _getToken();
// //     if (token == null) {
// //       log('No authentication token found');
// //       _isLoading = false;
// //       notifyListeners();
// //       return;
// //     }

// //     try {
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/chat/getMessage/$chatroomId'),
// //         headers: {'Authorization': 'Bearer $token'},
// //       );

// //       log('Get messages response status: ${response.statusCode}');

// //       if (response.statusCode == 200) {
// //         final Map<String, dynamic> responseData = jsonDecode(response.body);
// //         if (responseData.containsKey('messages')) {
// //           final List<dynamic> messageData = responseData['messages'];
// //           // Don't reverse the messages here
// //           _messages = messageData.map((data) => Message.fromJson(data)).toList();
// //           _currentChatroomId = chatroomId;
          
// //           // Log message details for debugging
// //           _messages.forEach((msg) {
// //             log('Message - From: ${msg.senderId}, Type: ${msg.messageType}');
// //           });
// //         } else {
// //           log('No messages found in response');
// //           _messages = [];
// //         }
// //       } else {
// //         log('Failed to fetch messages: ${response.statusCode}');
// //         throw Exception('Failed to fetch messages');
// //       }
// //     } catch (e) {
// //       log('Error fetching messages: $e');
// //       rethrow;
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   Future<void> sendMessage(String content) async {
// //     if (content.trim().isEmpty || _currentChatroomId == null) {
// //       log('Cannot send message: ${content.trim().isEmpty ? "Empty content" : "No chatroom"}');
// //       return;
// //     }

// //     final token = await _getToken();
// //     if (token == null) {
// //       log('Cannot send message: No token');
// //       return;
// //     }

// //     try {
// //       // Create message locally first
// //       final newMessage = Message(
// //         senderId: _currentUserId!,
// //         content: content,
// //         messageType: 'text',
// //         createdOn: DateTime.now(), 
// //         id: '',
// //       );

// //       // Add to local messages immediately
// //       _messages.add(newMessage);
// //       notifyListeners();

// //       final response = await http.post(
// //         Uri.parse('$baseUrl/chat/sendMessage/$_currentChatroomId'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //         body: jsonEncode({
// //           "message": content,
// //           "messageType": "text"
// //         }),
// //       );

// //       if (response.statusCode != 200) {
// //         // Remove message if send failed
// //         _messages.remove(newMessage);
// //         notifyListeners();
// //         throw Exception('Failed to send message');
// //       }

// //       log('Message sent successfully. From: $_currentUserId');
// //     } catch (e) {
// //       log('Error sending message: $e');
// //       rethrow;
// //     }
// //   }
























// //   Future<void> sendImageMessage(List<File> images) async {
// //     if (_currentChatroomId == null) {
// //       log('No active chatroom');
// //       return;
// //     }

// //     final token = await _getToken();
// //     if (token == null) {
// //       log('No authentication token found');
// //       return;
// //     }

// //     try {
// //       List<String> base64Images = [];
      
// //       // Convert images to base64
// //       for (var image in images) {
// //         List<int> imageBytes = await image.readAsBytes();
// //         String base64Image = 'data:image/png;base64,${base64Encode(imageBytes)}';
// //         base64Images.add(base64Image);
// //       }

// //       log('Sending ${base64Images.length} images');

// //       final response = await http.post(
// //         Uri.parse('$baseUrl/chat/sendMessage/$_currentChatroomId'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $token',
// //         },
// //         body: jsonEncode({
// //           "messageType": "image",
// //           "files": base64Images,
// //         }),
// //       );

// //       log('Send image response: ${response.body}');

// //       if (response.statusCode == 200) {
// //         log('Images sent successfully');
// //       } else {
// //         log('Failed to send images. Status: ${response.statusCode}');
// //       }
// //     } catch (e) {
// //       log('Error sending images: $e');
// //     }
// //   }

// //   Future<void> pickAndSendImages() async {
// //     try {
// //       final ImagePicker picker = ImagePicker();
      
// //       // Show options dialog
// //       final source = await showImageSourceDialog();
// //       if (source == null) return;

// //       List<XFile> imageFiles;
// //       if (source == ImageSource.camera) {
// //         final XFile? image = await picker.pickImage(
// //           source: ImageSource.camera,
// //           imageQuality: 70,
// //         );
// //         imageFiles = image != null ? [image] : [];
// //       } else {
// //         imageFiles = await picker.pickMultiImage(imageQuality: 70);
// //       }
      
// //       if (imageFiles.isNotEmpty) {
// //         List<File> files = imageFiles.map((xFile) => File(xFile.path)).toList();
// //         await sendImageMessage(files);
// //       }
// //     } catch (e) {
// //       log('Error picking images: $e');
// //     }
// //   }

// //   Future<ImageSource?> showImageSourceDialog() async {
// //     // This should be implemented in the UI layer, but keeping here for reference
// //     // You should move this to your UI code
// //     return ImageSource.gallery; // Default to gallery for now
// //   }

// //   Future<String?> _getToken() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('token');
// //       log('Retrieved token: ${token != null ? 'Token found' : 'Token not found'}');
// //       return token;
// //     } catch (e) {
// //       log('Error getting token: $e');
// //       return null;
// //     }
// //   }

// //   void clearChat() {
// //     _messages = [];
// //     notifyListeners();
// //   }

// //   @override
// //   void dispose() {
// //     try {
// //       socket?.disconnect();
// //       socket?.dispose();
// //       clearChat();
// //       super.dispose();
// //     } catch (e) {
// //       log('Error disposing ChatProvider: $e');
// //     }
// //   }
// // }




// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ChatMessageProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _messages = [];
//   bool _isLoading = false;
  

//    // Use a getter for the base URL
//   String get baseUrl => Constants.apiBaseUrl;

//   List<Map<String, dynamic>> get messages => _messages;
//   bool get isLoading => _isLoading;

//   // Send Message
//   Future<bool> sendMessage({
//     required String chatroomId,
//     required String message,
//     String messageType = "text"
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('token');

//       if (token == null) {
//         log('No token found');
//         return false;
//       }

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/sendMessage/$chatroomId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           "message": message,
//           "messageType": messageType
//         }),
//       );

//       if (response.statusCode == 200) {
//         // Message sent successfully
//         await getMessages(chatroomId); // Refresh messages list
//         return true;
//       }

//       log('Failed to send message: ${response.body}');
//       return false;
//     } catch (e) {
//       log('Error sending message: $e');
//       return false;
//     }
//   }

//   // Get Messages
//   Future<void> getMessages(String chatroomId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final prefs = await SharedPreferences.getInstance();
//       final String? token = prefs.getString('token');

//       if (token == null) {
//         log('No token found');
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('$baseUrl/chat/getMessage/$chatroomId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _messages = List<Map<String, dynamic>>.from(data['messages']);
//         _isLoading = false;
//         notifyListeners();
//         return;
//       }

//       log('Failed to get messages: ${response.body}');
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       log('Error getting messages: $e');
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Clear messages (useful when leaving chat)
//   void clearMessages() {
//     _messages = [];
//     notifyListeners();
//   }
// }



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