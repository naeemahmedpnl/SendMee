
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/views/User_panel/parcel_deliver/choose_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonSplashView extends StatefulWidget {
  const CommonSplashView({super.key});

  @override
  State<CommonSplashView> createState() => _CommonSplashViewState();
}

class _CommonSplashViewState extends State<CommonSplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }


  Future<void> _initializeApp() async {
  try {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check and request only essential permissions
    await _requestEssentialPermissions();

    // Initialize notifications
    final notificationService = NotificationService();
     notificationService.initializeNotifications();
    
    String? fcmToken = await notificationService.getFCMToken();
    log('Initial FCM Token: $fcmToken');

    await _checkTokenAndNavigate();
    
  } catch (e) {
    log('Error during app initialization: $e');
    if (mounted) {
      _showErrorDialog('Failed to initialize app services');
    }
  }
}

Future<void> _requestEssentialPermissions() async {
  // Check and request notification permission
  var notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }

  // Check and request location permission
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Show dialog to enable location services
    await _showLocationServiceDialog();
    return;
  }

  LocationPermission locationStatus = await Geolocator.checkPermission();
  if (locationStatus == LocationPermission.denied) {
    locationStatus = await Geolocator.requestPermission();
    if (locationStatus == LocationPermission.denied || 
        locationStatus == LocationPermission.deniedForever) {
      await _showLocationServiceDialog();
    }
  }
}

Future<bool> _showLocationServiceDialog() async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off,
              size: 60,
              color: AppColors.buttonColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Location Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              'Please enable location services to use the app.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(44),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                      await Geolocator.openLocationSettings();
                    },
                    child: const Text(
                      'Enable Location',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  ) ?? false;
}


 



// Add this helper method for error dialog
  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Initialization Error',
              style: TextStyle(color: Colors.black)),
          content: Text(message, style: const TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                _initializeApp(); // Retry initialization
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
                // You might want to exit the app here
              },
            ),
          ],
        );
      },
    );
  }



Future<void> _checkTokenAndNavigate() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('userData');
    log('UserData: $userData');

    String? tripId = prefs.getString('currentTripId');
    int? tripExpiry = prefs.getInt('tripExpiry');
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    log('Trip ID: $tripId');
    log('Trip Expiry: $tripExpiry');
    log('Current Time: $currentTime');

    if (tripId != null && tripExpiry != null && currentTime < tripExpiry) {
      log("Navigating to ChooseDriverScreen...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChooseDriverScreen(tripId: tripId)),
      );
      return;
    }

    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      
      String? token = prefs.getString('token');
      bool isDriver = userMap['isDriver'] ?? false;
      String driverStatus = userMap['driverRoleStatus'] ?? '';
      String? email = userMap['email'];

      log('Token: $token');
      log('Is Driver: $isDriver');
      log('Driver Status: $driverStatus'); 
      log('Email: $email');

      // FCM Token Handling
      String? fcmToken = prefs.getString(isDriver ? 'driver_fcm_token' : 'fcm_token');
      if (fcmToken == null) {
        final notificationService = NotificationService();
        fcmToken = await notificationService.getFCMToken();
        if (fcmToken != null) {
          await prefs.setString(isDriver ? 'driver_fcm_token' : 'fcm_token', fcmToken);
        }
      }

      if (!mounted) return;

      if (token != null) {
        if (isDriver && (driverStatus == 'accepted' || driverStatus == 'unban')) {
          Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
        } else if (email == null) {
          Navigator.pushReplacementNamed(context, AppRoutes.userAccountCreate);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
        }
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
      }

    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
    }

  } catch (e) {
    log("❌ Error in navigation check: $e");
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
    }
  }
}



//   Future<void> _checkTokenAndNavigate() async {
//   try {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userData = prefs.getString('userData');
//     log('UserData: $userData');

//     if (userData != null) {
//       final Map<String, dynamic> userMap = jsonDecode(userData);
      
//       String? token = prefs.getString('token');
//       bool isDriver = userMap['isDriver'] ?? false;
//       String driverStatus = userMap['driverRoleStatus'] ?? '';
//       String? email = userMap['email'];

//       log('Token: $token');
//       log('Is Driver: $isDriver');
//       log('Driver Status: $driverStatus'); 
//       log('Email: $email');

//       // Verify FCM token exists
//       String? fcmToken = prefs.getString(isDriver ? 'driver_fcm_token' : 'fcm_token');
//       if (fcmToken == null) {
//         final notificationService = NotificationService();
//         fcmToken = await notificationService.getFCMToken();
//         if (fcmToken != null) {
//           await prefs.setString(
//               isDriver ? 'driver_fcm_token' : 'fcm_token', fcmToken);
//         }
//       }

//       if (!mounted) return;

//       if (token != null) {
//         // Check driver status first
//         if (isDriver && (driverStatus == 'accepted' || driverStatus == 'unban')) {
//           Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
//         } else if (email == null) {
//           // Only go to account create if email is missing
//           Navigator.pushReplacementNamed(context, AppRoutes.userAccountCreate);
//         } else {
//           // Regular user home
//           Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
//         }
//       } else {
//         Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
//       }

//     } else {
//       if (!mounted) return;
//       Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
//     }

//   } catch (e) {
//     log("❌ Error in navigation check: $e");
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, AppRoutes.userSignup);
//     }
//   }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: AppColors.primary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/sednmesplash.png',
                width: 317,
                height: 317,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkAndRequestLocationPermission() async {
    int attempts = 0;
    const maxAttempts = 3;
    const timeout = Duration(seconds: 10);

    while (attempts < maxAttempts) {
      try {
        bool serviceEnabled =
            await Geolocator.isLocationServiceEnabled().timeout(timeout);
        if (serviceEnabled) {
          LocationPermission permission =
              await Geolocator.checkPermission().timeout(timeout);
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            return true;
          }
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission().timeout(timeout);
            if (permission != LocationPermission.denied) {
              return true;
            }
          }
        } else {
          bool userEnabledLocation = await _showLocationServiceDialog();
          if (userEnabledLocation) {
            // Wait for a moment to allow the system to update the location service status
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
        }
      } catch (e) {
        log('Error checking location permission: $e');
      }
      attempts++;
    }
    return false;
  }



  Future<bool> _showProceedWithoutLocationDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Services Disabled',
                  style: TextStyle(color: Colors.black)),
              content: const Text(
                  'The app works best with location services enabled. Do you want to proceed without location services?',
                  style: TextStyle(color: Colors.black)),
              actions: [
                TextButton(
                  child: const Text('Exit App'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Proceed Anyway'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
