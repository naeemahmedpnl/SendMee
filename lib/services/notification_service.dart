
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


  // Save image URL to shared preferences
  Future<void> _saveDeliveryProofImage(String notificationId, String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('delivery_proof_$notificationId', imageUrl);
    } catch (e) {
      log('Error saving delivery proof image: $e');
    }
  }


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


void _handleBackgroundMessage(RemoteMessage message) {
  log('Handling background message: ${message.messageId}');
  
  String? notificationMessage = message.notification?.body;
  bool isParcelDelivery = 
      notificationMessage?.contains('parcel delivery') == true ||
      notificationMessage?.contains('Parcel Delivered') == true;
  
  // Check for delivery proof image in the data payload
  if (message.data.containsKey('deliveryProofImage')) {
    final deliveryProofImage = message.data['deliveryProofImage'];
    log('Background message contains delivery proof image: $deliveryProofImage');
    
    // Store it for the UI to access later
    _saveDeliveryProofImage('latest_background', deliveryProofImage);
    
    // Also store a flag indicating we need to navigate when app is opened
    if (isParcelDelivery) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('navigate_to_payment', true);
      });
    }
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
