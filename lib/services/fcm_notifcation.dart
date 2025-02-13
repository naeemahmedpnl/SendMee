
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Notification channels
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Setup FCM handlers
    _setupFCMHandlers();

    // Create notification channel
    await _createNotificationChannel();
  }

  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> _createNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _setupFCMHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle when notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final userLanguage = prefs.getString('language') ?? 'es';

    // Get localized notification content
    final notificationData = _getLocalizedNotificationContent(
      message.data,
      userLanguage,
    );

    // Show notification
    await _showNotification(
      title: notificationData['title'] ?? message.notification?.title ?? '',
      body: notificationData['body'] ?? message.notification?.body ?? '',
      data: message.data,
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages
    print("Handling a background message: ${message.messageId}");
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap
    print("Notification tapped: ${message.data}");
  }

  Map<String, String> _getLocalizedNotificationContent(Map<String, dynamic> data, String language) {
    // Notification messages for different languages
    final messages = {
      'en': {
        'trip_accepted': 'Trip Request Accepted',
        'driver_accepted': 'Driver {name} has accepted your trip request',
        'trip_started': 'Your trip has started',
        'trip_completed': 'Trip completed',
        'payment_received': 'Payment received'
      },
      'es': {
        'trip_accepted': 'Solicitud de viaje aceptada',
        'driver_accepted': 'El conductor {name} ha aceptado tu solicitud de viaje',
        'trip_started': 'Tu viaje ha comenzado',
        'trip_completed': 'Viaje completado',
        'payment_received': 'Pago recibido'
      }
    };

    final notificationType = data['type'] as String?;
    if (notificationType == null) return {'title': '', 'body': ''};

    String title = messages[language]?[notificationType] ?? messages['en']?[notificationType] ?? '';
    String body = messages[language]?['${notificationType}_body'] ?? messages['en']?['${notificationType}_body'] ?? '';

    // Replace variables in message
    if (data['driverName'] != null) {
      body = body.replaceAll('{name}', data['driverName']);
    }

    return {
      'title': title,
      'body': body
    };
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: json.encode(data),
    );
  }

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> deleteFCMToken() async {
    await _firebaseMessaging.deleteToken();
  }

  void onTokenRefresh(Function(String) callback) {
    _firebaseMessaging.onTokenRefresh.listen(callback);
  }
}