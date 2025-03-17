import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_strings.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/viewmodel/provider/auth_provider/change_password_provider.dart';
import 'package:sendme/viewmodel/provider/auth_provider/id_confirmation_provider.dart';
import 'package:sendme/viewmodel/provider/cancel_trip_request.dart';
import 'package:sendme/viewmodel/provider/choose_driver_provider.dart';
import 'package:sendme/viewmodel/provider/driver_provider.dart';
import 'package:sendme/viewmodel/provider/driver_registration_provider.dart';
import 'package:sendme/viewmodel/provider/location_provider.dart';
import 'package:sendme/viewmodel/provider/map_provider.dart';
import 'package:sendme/viewmodel/provider/message_provider/chat_provider.dart';
import 'package:sendme/viewmodel/provider/message_provider/chatroom_provider.dart';
import 'package:sendme/viewmodel/provider/payment_provider.dart';
import 'package:sendme/viewmodel/provider/profile_provider.dart';
import 'package:sendme/viewmodel/provider/ratings_provider/driver_rating_provider.dart';
import 'package:sendme/viewmodel/provider/ratings_provider/rating_provider.dart';
import 'package:sendme/viewmodel/provider/ridebook_provider.dart';
import 'package:sendme/viewmodel/provider/trip_history_provider.dart';
import 'package:sendme/views/Driver_panel/ride_screens/location_provider.dart';
import 'package:sendme/views/User_panel/common_splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';


  // Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
   await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  // Initialize notification service globally
  final notificationService = NotificationService();
  await notificationService.requestNotificationPermissions();


  // Background message handler setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );


// This navigation code should be moved to a widget with a BuildContext
// For now, we'll remove it from main() since it's using context which isn't available here
// You should move this code to a widget where context is available
SharedPreferences.getInstance().then((prefs) {
  bool shouldNavigate = prefs.getBool('navigate_to_payment') ?? false;
  if (shouldNavigate) {
    // Clear the flag
    prefs.setBool('navigate_to_payment', false);
    
    // Save the image URL for later use
    // The actual navigation should happen in a widget with context
  }
});


  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'), 
          // Add this line to disable logs
    useOnlyLangCode: true,
    // Add this line to completely turn off logging
    // logging: false,
      // startLocale: Locale(savedLanguage),
      child: 
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RideProvider()),
        
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
        ChangeNotifierProvider(create: (_) => CancelTripRequest()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => DriverRatingProvider()),
        ChangeNotifierProvider(create: (_) => RideBookingProvider()),
        ChangeNotifierProvider(create: (_) => ChooseDriverProvider()),
        ChangeNotifierProvider(create: (_) => ChatRoomProvider()),
        ChangeNotifierProvider(create: (_) => ChatMessageProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => IdConfirmationProvider()),
        ChangeNotifierProvider(create: (_) => TripHistoryProvider()),
        ChangeNotifierProvider(create: (_) => DriverRegistrationProvider(prefs),
       ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: AppTextTheme.getLightTextTheme(context),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/driver')) {
          return AppDriverRoutes.generateRoute(settings);
        }
        return AppRoutes.generateRoute(settings);
      },
      home: CommonSplashView(),
    );
  }
}
