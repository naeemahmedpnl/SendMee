// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
//       FlutterLocalNotificationsPlugin();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   NotificationService() {
//     initializeNotifications();
//     setupTokenListener();  // Add token listener in constructor
//   }

//   // Initialize notifications
//   void initializeNotifications() async {
//     // Android initialization settings
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization settings
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings();

//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse details) async {
//         log('Notification clicked');
//       },
//     );

//     // Listen to FCM messages when app is in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       showNotification(
//         title: message.notification?.title ?? 'Notification',
//         body: message.notification?.body ?? '',
//       );
//     });
//   }

//   // Request notification permissions
//   Future<void> requestNotificationPermissions() async {
//     try {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       log('Notification permissions granted');
//     } catch (e) {
//       log('Error requesting notification permissions: $e');
//     }
//   }

//   // Show local notification
//   Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'ride_deleted',    // channel id
//       'Ride App',        // channel name
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   // Get FCM token
//   Future<String?> getFCMToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         await saveNewToken(token);
//         log('FCM Token generated: $token');
//       }
//       return token;
//     } catch (e) {
//       log('Error getting FCM token: $e');
//       return null;
//     }
//   }

//   // Setup token refresh listener
//   void setupTokenListener() {
//     _firebaseMessaging.onTokenRefresh.listen((String newToken) {
//       log('New FCM Token received: $newToken');
//       saveNewToken(newToken);
//     });
//   }

//   // Save token to SharedPreferences
//   Future<void> saveNewToken(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('fcm_token', token);
//       log('FCM Token saved successfully');
//     } catch (e) {
//       log('Error saving FCM token: $e');
//     }
//   }

//   // Get saved token
//   Future<String?> getSavedToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getString('fcm_token');
//     } catch (e) {
//       log('Error getting saved token: $e');
//       return null;
//     }
//   }
// }





import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();


   DateTime? _lastNotificationTime;
  static const Duration _notificationCooldown = Duration(seconds: 5);

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Check if enough time has passed since last notification
    if (_lastNotificationTime != null && 
        DateTime.now().difference(_lastNotificationTime!) < _notificationCooldown) {
      log('Notification blocked: Too soon after previous notification');
      return;
    }

    try {
      final int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

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


  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    initializeNotifications();
    setupTokenListener();
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
      
      await _localNotifications.initialize(initSettings);

      // Handle FCM messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle when user taps on notification when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      // Get initial FCM token
      await getFCMToken();

    } catch (e) {
      log('Error initializing notifications: $e');
    }
  }

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

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Received message in foreground: ${message.notification?.title}');

    if (message.notification != null) {
      await showNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    log('Handling background message: ${message.messageId}');
    // Handle any background message navigation here
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