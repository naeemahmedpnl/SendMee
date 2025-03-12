


import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sendme/utils/constant/image_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  

// Track last notification time to prevent spam
  DateTime? _lastNotificationTime;
  static const Duration _notificationCooldown = Duration(seconds: 5);
  
  // Store the latest delivery proof image URL
  String? _latestDeliveryProofImage;

  // Getter for latest delivery proof image
  String? get latestDeliveryProofImage => _latestDeliveryProofImage;

Future<void> _handleForegroundMessage(RemoteMessage message) async {
  log('Received message in foreground: ${message.notification?.title}');

  // Extract delivery proof image if present and normalize the URL
  String? deliveryProofImage;
  if (message.data.containsKey('deliveryProofImage')) {
    final rawImageUrl = message.data['deliveryProofImage'];
    deliveryProofImage = ImageUrlUtils.getFullImageUrl(rawImageUrl);
    
    // Save the normalized image URL for later access
    await _saveDeliveryProofImageToPrefs(deliveryProofImage);
    
    // Set flag indicating we should show dialog
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_delivery_proof_dialog', true);
    
    log('Processed delivery proof image from notification: $deliveryProofImage');
  }

  if (message.notification != null) {
    await showNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: json.encode({
        'type': 'trip_notification',
        'deliveryProofImage': deliveryProofImage,
        // Add other relevant data
      }),
      deliveryProofImage: deliveryProofImage,
    );
  }
}

// Notification handling method
void _handleNotificationResponse(NotificationResponse response) async {
  final payload = response.payload;
  log('Notification tapped: ID=${response.id}, payload=$payload');

  try {
    if (payload != null && payload.isNotEmpty) {
      // Try to parse the payload as JSON
      if (payload.startsWith('{')) {
        final Map<String, dynamic> data = json.decode(payload);
        
        // Check if the payload contains an image URL
        if (data.containsKey('deliveryProofImage') && data['deliveryProofImage'] != null) {
          final imageUrl = ImageUrlUtils.getFullImageUrl(data['deliveryProofImage']);
          
          // Save the normalized URL and set flag to show dialog
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('latest_delivery_proof', imageUrl);
          await prefs.setBool('show_delivery_proof_dialog', true);
          
          log('Saved delivery proof image from notification tap: $imageUrl');
        }
      }
    }
  } catch (e) {
    log('Error processing notification payload: $e');
  }
}

// Update the save method to use a consistent key name
Future<void> _saveDeliveryProofImageToPrefs(String imageUrl) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latest_delivery_proof', imageUrl);
    

    
    log('Saved delivery proof image to prefs: $imageUrl');
  } catch (e) {
    log('Error saving delivery proof image: $e');
  }
}












  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? deliveryProofImage,
  }) async {
    // Check if enough time has passed since last notification
    if (_lastNotificationTime != null && 
        DateTime.now().difference(_lastNotificationTime!) < _notificationCooldown) {
      log('Notification blocked: Too soon after previous notification');
      return;
    }

    try {
      final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Save delivery proof image if provided
      if (deliveryProofImage != null) {
        _latestDeliveryProofImage = deliveryProofImage;
        _saveDeliveryProofImageToPrefs(deliveryProofImage);
        
        // Include image URL in payload for retrieval when tapped
        if (payload != null) {
          Map<String, dynamic> payloadMap;
          try {
            payloadMap = Map<String, dynamic>.from(
              payload.startsWith('{') ? 
                Map<String, dynamic>.from(json.decode(payload)) : 
                {'message': payload}
            );
          } catch (e) {
            payloadMap = {'message': payload};
          }
          
          payloadMap['imageUrl'] = deliveryProofImage;
          payload = json.encode(payloadMap);
        } else {
          payload = json.encode({'imageUrl': deliveryProofImage, 'click_action': 'FLUTTER_NOTIFICATION_CLICK'});
        }
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'ride_app_channel',
        'Ride Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        notificationId, 
        title,
        body,
        platformDetails,
        payload: payload,
      );
      
      // Update last notification time
      _lastNotificationTime = DateTime.now();
      
      log('Notification shown successfully: $title');
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  // Future<void> _saveDeliveryProofImageToPrefs(String imageUrl) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('latest_delivery_proof_image', imageUrl);
  //     log('Saved delivery proof image to prefs: $imageUrl');
  //   } catch (e) {
  //     log('Error saving delivery proof image: $e');
  //   }
  // }


  

  Future<String?> getLatestDeliveryProofImageFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('latest_delivery_proof_image');
    } catch (e) {
      log('Error getting delivery proof image: $e');
      return null;
    }
  }

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    initializeNotifications();
    setupTokenListener();
  }




  // Modify your notification service to handle the image URL properly

// // In the file where you handle FCM messages (likely in your NotificationService class)
// Future<void> _handleForegroundMessage(RemoteMessage message) async {
//   log('Received message in foreground: ${message.notification?.title}');

//   // Extract delivery proof image if present
//   String? deliveryProofImage;
//   if (message.data.containsKey('deliveryProofImage')) {
//     deliveryProofImage = message.data['deliveryProofImage'];
    
//     // Save the image URL to SharedPreferences for later retrieval
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('latest_delivery_proof', deliveryProofImage!);
//     log('Saved delivery proof image from notification: $deliveryProofImage');
//   }

//   if (message.notification != null) {
//     await showNotification(
//       title: message.notification?.title ?? 'New Notification',
//       body: message.notification?.body ?? '',
//       payload: json.encode({
//         'type': 'trip_notification',
//         'deliveryProofImage': deliveryProofImage,
//         // Add other relevant data
//       }),
//     );
//   }
// }

// When handling notification taps (likely in your main.dart or app initialization)
void _handleNotificationTap(NotificationResponse response) {
  try {
    if (response.payload != null) {
      final payloadData = json.decode(response.payload!);
      
      // Check if this is a delivery proof notification
      if (payloadData['deliveryProofImage'] != null) {
        // Navigate to an appropriate screen that can show the delivery proof
        // This could be done through a global navigator key or other navigation method
        
        // Store the data in SharedPreferences for access in the next screen
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('latest_delivery_proof', payloadData['deliveryProofImage']);
          prefs.setBool('show_delivery_proof_dialog', true);
        });
      }
    }
  } catch (e) {
    log('Error handling notification tap: $e');
  }
}

  Future<void> initializeNotifications() async {
    try {
      // Request permissions
      await requestNotificationPermissions();

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );
      
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Handle FCM messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle when user taps on notification when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      // Get initial FCM token
      await getFCMToken();

      // Load latest delivery proof image if available
      _latestDeliveryProofImage = await getLatestDeliveryProofImageFromPrefs();

    } catch (e) {
      log('Error initializing notifications: $e');
    }
  }

  // void _handleNotificationResponse(NotificationResponse response) async {
  //   final payload = response.payload;
  //   log('Notification tapped: ID=${response.id}, payload=$payload');

  //   try {
  //     if (payload != null && payload.isNotEmpty) {
  //       // Try to parse the payload as JSON
  //       if (payload.startsWith('{')) {
  //         final Map<String, dynamic> data = json.decode(payload);
          
  //         // Check if the payload contains an image URL
  //         if (data.containsKey('imageUrl')) {
  //           _latestDeliveryProofImage = data['imageUrl'];
  //           await _saveDeliveryProofImageToPrefs(_latestDeliveryProofImage!);
  //           log('Extracted image URL from notification payload: $_latestDeliveryProofImage');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     log('Error processing notification payload: $e');
  //   }
  // }

  // // Handle FCM foreground message
  // Future<void> _handleForegroundMessage(RemoteMessage message) async {
  //   log('Received message in foreground: ${message.notification?.title}');

  //   // Extract delivery proof image if present
  //   String? deliveryProofImage;
  //   if (message.data.containsKey('deliveryProofImage')) {
  //     deliveryProofImage = message.data['deliveryProofImage'];
  //   }

  //   if (message.notification != null) {
  //     await showNotification(
  //       title: message.notification?.title ?? 'New Notification',
  //       body: message.notification?.body ?? '',
  //       payload: message.data.isNotEmpty ? json.encode(message.data) : null,
  //       deliveryProofImage: deliveryProofImage,
  //     );
  //   }
  // }




  // // Track last notification time to prevent spam
  // DateTime? _lastNotificationTime;
  // static const Duration _notificationCooldown = Duration(seconds: 5);
  
  // // Map to store delivery proof images associated with notifications
  // final Map<int, String> _deliveryProofImages = {};

  // Future<void> showNotification({
  //   required String title,
  //   required String body,
  //   String? payload,
  //   String? deliveryProofImage,
  // }) async {
  //   // Check if enough time has passed since last notification
  //   if (_lastNotificationTime != null && 
  //       DateTime.now().difference(_lastNotificationTime!) < _notificationCooldown) {
  //     log('Notification blocked: Too soon after previous notification');
  //     return;
  //   }

  //   try {
  //     final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

  //     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //       'ride_app_channel',
  //       'Ride Notifications',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //     );

  //     const NotificationDetails platformDetails = NotificationDetails(
  //       android: androidDetails,
  //     );

  //     await _localNotifications.show(
  //       notificationId, 
  //       title,
  //       body,
  //       platformDetails,
  //       payload: payload,
  //     );
      
  //     // Store image URL if provided
  //     if (deliveryProofImage != null) {
  //       _deliveryProofImages[notificationId] = deliveryProofImage;
  //       log('Delivery proof image stored for notification ID: $notificationId');
        
  //       // Store in shared preferences for persistence
  //       _saveDeliveryProofImage(notificationId.toString(), deliveryProofImage);
  //     }
      
  //     // Update last notification time
  //     _lastNotificationTime = DateTime.now();
      
  //     log('Notification shown successfully: $title');
  //   } catch (e) {
  //     log('Error showing notification: $e');
  //   }
  // }

  // Save image URL to shared preferences
  Future<void> _saveDeliveryProofImage(String notificationId, String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('delivery_proof_${notificationId}', imageUrl);
    } catch (e) {
      log('Error saving delivery proof image: $e');
    }
  }

  // // Get delivery proof image URL for a notification
  // String? getDeliveryProofImage(int notificationId) {
  //   return _deliveryProofImages[notificationId];
  // }

  // Method to retrieve last delivery proof image (for showing in UI)
  Future<String?> getLastDeliveryProofImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final deliveryProofKeys = keys.where((key) => key.startsWith('delivery_proof_')).toList();
      
      if (deliveryProofKeys.isEmpty) return null;
      
      // Sort by key to get the most recent
      deliveryProofKeys.sort((a, b) => b.compareTo(a));
      
      return prefs.getString(deliveryProofKeys.first);
    } catch (e) {
      log('Error getting last delivery proof image: $e');
      return null;
    }
  }

  // factory NotificationService() {
  //   return _instance;
  // }

  // NotificationService._internal() {
  //   initializeNotifications();
  //   setupTokenListener();
  // }

  // Future<void> initializeNotifications() async {
  //   try {
  //     // Request permissions
  //     await requestNotificationPermissions();

  //     // Initialize local notifications
  //     const AndroidInitializationSettings androidSettings = 
  //         AndroidInitializationSettings('@mipmap/ic_launcher');
      
  //     const InitializationSettings initSettings = InitializationSettings(
  //       android: androidSettings,
  //     );
      
  //     await _localNotifications.initialize(
  //       initSettings,
  //       onDidReceiveNotificationResponse: _handleNotificationResponse,
  //     );

  //     // Handle FCM messages when app is in foreground
  //     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
  //     // Handle when user taps on notification when app is in background
  //     FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
  //     // Get initial FCM token
  //     await getFCMToken();

  //   } catch (e) {
  //     log('Error initializing notifications: $e');
  //   }
  // }

  // // Handle notification tap response
  // void _handleNotificationResponse(NotificationResponse response) {
  //   final notificationId = response.id;
  //   final payload = response.payload;
    
  //   log('Notification tapped: ID=$notificationId, payload=$payload');
    
  //   // Check if this notification has a delivery proof image
  //   final imageUrl = _deliveryProofImages[notificationId];
  //   if (imageUrl != null) {
  //     log('Notification has delivery proof image: $imageUrl');
  //     // Store the image URL in shared preferences for the UI to access
  //     _saveDeliveryProofImage('latest_tapped', imageUrl);
  //   }
  // }

  Future<void> requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted notification permissions');
      } else {
        log('User declined or has not accepted notification permissions');
      }
    } catch (e) {
      log('Error requesting notification permissions: $e');
    }
  }

  // Future<void> _handleForegroundMessage(RemoteMessage message) async {
  //   log('Received message in foreground: ${message.notification?.title}');

  //   // Check for delivery proof image in the data payload
  //   String? deliveryProofImage;
  //   if (message.data.containsKey('deliveryProofImage')) {
  //     deliveryProofImage = message.data['deliveryProofImage'];
  //     log('Message contains delivery proof image: $deliveryProofImage');
  //   }

  //   if (message.notification != null) {
  //     await showNotification(
  //       title: message.notification?.title ?? 'New Notification',
  //       body: message.notification?.body ?? '',
  //       payload: message.data.toString(),
  //       deliveryProofImage: deliveryProofImage,
  //     );
  //   }
  // }

  void _handleBackgroundMessage(RemoteMessage message) {
    log('Handling background message: ${message.messageId}');
    
    // Check for delivery proof image in the data payload
    if (message.data.containsKey('deliveryProofImage')) {
      final deliveryProofImage = message.data['deliveryProofImage'];
      log('Background message contains delivery proof image: $deliveryProofImage');
      
      // Store it for the UI to access later
      _saveDeliveryProofImage('latest_background', deliveryProofImage);
    }
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await saveNewToken(token);
        log('FCM Token generated: $token');
      }
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  void setupTokenListener() {
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      log('New FCM Token received: $newToken');
      saveNewToken(newToken);
    });
  }

  Future<void> saveNewToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      log('FCM Token saved successfully');
    } catch (e) {
      log('Error saving FCM token: $e');
    }
  }

  Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      log('Error getting saved token: $e');
      return null;
    }
  }

  // Method to unregister/cleanup notifications
  Future<void> dispose() async {
    await _localNotifications.cancelAll();  
  }
}