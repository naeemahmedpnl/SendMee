// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:sendme/services/notification_service.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChooseDriverScreen extends StatefulWidget {
//   final String tripId;
//   const ChooseDriverScreen({super.key, required this.tripId});

//   @override
//   State<ChooseDriverScreen> createState() => _ChooseDriverScreenState();
// }

// class _ChooseDriverScreenState extends State<ChooseDriverScreen> {
//   final NotificationService _notificationService = NotificationService();

//   // Socket Related Variables
//   IO.Socket? socket;
//   bool isConnected = false;

//   // Location Related Variables
//   Position? currentPosition;
//   bool myLocationEnabled = false;
//   bool _isLocationInitialized = false;

//   // Map Related Variables
//   String mapTheme = "";
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   bool _isMapControllerInitialized = false;
//   bool _hasMovedToUserLocation = false;

//   // Audio Related Variables
//   final AudioPlayer audioPlayer = AudioPlayer();
//   double notificationVolume = 1.0;
//   bool canVibrate = false;

//   // Authentication
//   String? _token;

//   // State Variables
//   DateTime? lastBackPressTime;
//   Timer? connectivityTimer;
//   bool isInternetConnected = true;
//   StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

//   // Initial Map Position (Mexico City)
//   static const CameraPosition _kInitialPosition = CameraPosition(
//     target: LatLng(-25.7479, 28.2293),
//     zoom: 14.4746,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//     _setupConnectivityListener();
//   }

//   Future<void> _initializeServices() async {
//     await _getToken();
//     await _initializeAudioPlayer();
//     await _checkVibrationCapability();
//     await _getCurrentLocation();

//     if (socket == null || !socket!.connected) {
//       connectToSocket();
//     }

//     loadMapTheme();
//   }

//   void _setupConnectivityListener() {
//     if (!mounted) return;

//     connectivitySubscription = Connectivity()
//         .onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       if (!mounted) return;

//       final hasConnection = results.contains(ConnectivityResult.mobile) ||
//           results.contains(ConnectivityResult.wifi) ||
//           results.contains(ConnectivityResult.ethernet);

//       if (hasConnection) {
//         if (!isInternetConnected && mounted) {
//           setState(() => isInternetConnected = true);
//           if (socket == null || !socket!.connected) {
//             connectToSocket();
//           }
//         }
//       } else {
//         _handleNoInternet();
//       }
//     });

//     _checkInitialConnectivity();
//   }

//   Future<void> _checkInitialConnectivity() async {
//     try {
//       final results = await Connectivity().checkConnectivity();
//       final hasConnection = results.contains(ConnectivityResult.mobile) ||
//           results.contains(ConnectivityResult.wifi) ||
//           results.contains(ConnectivityResult.ethernet);

//       if (!hasConnection) {
//         _handleNoInternet();
//       } else {
//         setState(() => isInternetConnected = true);
//       }
//     } catch (e) {
//       log('Error checking initial connectivity: $e');
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     if (_isLocationInitialized) return;

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return;
//         }
//       }

//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       if (!mounted) return;

//       setState(() {
//         currentPosition = position;
//         myLocationEnabled = true;
//         _isLocationInitialized = true;
//       });

//       if (_isMapControllerInitialized && !_hasMovedToUserLocation) {
//         final GoogleMapController controller = await _controller.future;
//         controller.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               target: LatLng(position.latitude, position.longitude),
//               zoom: 15,
//             ),
//           ),
//         );
//         setState(() {
//           _hasMovedToUserLocation = true;
//         });
//       }
//     } catch (e) {
//       log('Error getting location: $e');
//     }
//   }

//   void connectToSocket() {
//     try {
//       if (socket == null || socket?.disconnected == true) {
//         socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
//           'transports': ['websocket'],
//           'autoConnect': true,
//           'reconnection': true,
//           'reconnectionAttempts': 5,
//           'reconnectionDelay': 1000,
//         });
//       }

//       socket?.connect();

//       socket?.onConnect((_) {
//         log('Socket connected successfully');
//         if (mounted) {
//           setState(() => isConnected = true);
//         }
//       });

//       socket?.onDisconnect((_) {
//         log('Socket disconnected');
//         if (mounted) {
//           setState(() => isConnected = false);
//         }
//       });

//       socket?.on('driver_accepted_trip', (data) async {
//         log('Driver accepted trip event received: $data');
//         await handleDriverAcceptedEvent(data);
//       });

//       socket?.onError((err) => log('Socket error: $err'));
//       socket?.onConnectError((err) => log('Socket connect error: $err'));
//     } catch (e) {
//       log('Error connecting to socket: $e');
//     }
//   }

//   Future<void> handleDriverAcceptedEvent(dynamic data) async {
//   if (!mounted) return;

//   try {
//     if (data == null) {
//       log('Received null data in driver accepted event');
//       return;
//     }

//     String driverUsername = data['driver']?['user']?['username'] ?? 'unknown_driver'.tr();

//     final response = await http.put(
//       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/${data['_id']}'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $_token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);

//       await _notificationService.showNotification(
//         title: 'trip_request_accepted'.tr(),
//         body: 'driver_accepted_trip'.tr(args: [driverUsername]),
//         // payload: data.toString(),
//       );

//       socket?.emit('user_accepted_other_driver', {
//         'tripId': data['_id'],
//         'driverIds': [],
//       });

//       if (mounted) {
//         Navigator.pushNamed(
//           context,
//           AppRoutes.rideDetails,
//           arguments: {
//             'tripDetails': responseData,
//             'initialTripDetails': data,
//           },
//         );
//       }

//       _playNotification();
//     }
//   } catch (e) {
//     log('Error handling driver accepted event: $e');
//     _handleError('failed_to_accept_trip'.tr());
//   }
// }


//   Future<void> _cancelTrip() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final tripId = widget.tripId;
//     final token = prefs.getString('token');

//     log('Attempting to cancel trip ID: $tripId');

//     if (token == null) {
//       _handleError('missing_token'.tr());
//       return;
//     }

//     final bool? shouldCancel = await _showCancelConfirmationDialog();
//     if (shouldCancel != true) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(15),
           
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'cancelling_trip'.tr(),
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     final response = await http.delete(
//       Uri.parse('${Constants.apiBaseUrl}/trip/cancel-pending-trip/$tripId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }

//     if (response.statusCode == 200) {
//       await prefs.remove('currentTripId');

//       socket?.disconnect();
//       socket = null;

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('trip_cancelled_successfully'.tr()),
//             backgroundColor: Colors.green,
//           ),
//         );

//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           AppRoutes.parcelScreen,
//           (route) => false,
//         );
//       }
//     } else {
//       String errorMessage;
//       try {
//         final errorData = json.decode(response.body);
//         errorMessage = errorData['message'] ?? 'failed_to_cancel_trip'.tr();
//       } catch (e) {
//         errorMessage = response.statusCode == 404
//             ? 'trip_not_found'.tr()
//             : 'failed_to_cancel_trip'.tr();
//       }
//       _handleError(errorMessage);
//     }
//   } catch (e) {
//     log('Error in _cancelTrip: $e');
//     if (Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }
//     _handleError('failed_to_cancel_trip'.tr());
//   }
// }

// // Cancel Confirmation Dialog
// Future<bool?> _showCancelConfirmationDialog() async {
//   return showDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.9),
//             borderRadius: BorderRadius.circular(15),
           
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.warning_rounded,
//                 color: Colors.yellow,
//                 size: 50,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'cancel_trip_confirmation'.tr(),
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'cancel_trip_subtitle'.tr(),
//                 style: TextStyle(
//                   color: const Color.fromARGB(255, 22, 22, 22),
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 25),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Navigator.of(context).pop(false),
//                       style: TextButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           side: const BorderSide(color: Colors.grey),
//                         ),
//                       ),
//                       child: Text(
//                         'no'.tr(),
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.yellow[700],
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         'yes'.tr(),
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }


// // Will Pop Function
// void _onPopInvoked(bool didPop) async {
//   if (didPop) return;

//   if (lastBackPressTime == null ||
//       DateTime.now().difference(lastBackPressTime!) >
//           const Duration(seconds: 2)) {
//     setState(() => lastBackPressTime = DateTime.now());
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('tap_again_to_close'.tr()),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//     return;
//   }
//   await SystemNavigator.pop();
// }

// // // Handle Error Function
// void _handleError(String messageKey) {
//   if (!mounted) return;

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(messageKey),
//       backgroundColor: Colors.red,
//       duration: const Duration(seconds: 3),
//       action: SnackBarAction(
//         label: 'dismiss'.tr(),
//         onPressed: () {},
//         textColor: Colors.white,
//       ),
//     ),
//   );
// }

// // Handle No Internet Function
// void _handleNoInternet() {
//   if (isInternetConnected) {
//     setState(() => isInternetConnected = false);
//     _showNoInternetSnackBar();
//   }
// }

// // Show No Internet SnackBar Function
// void _showNoInternetSnackBar() {
//   if (!mounted) return;

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text('no_internet_connection'.tr()),
//       duration: const Duration(days: 365),
//       backgroundColor: Colors.red,
//       action: SnackBarAction(
//         label: 'retry'.tr(),
//         onPressed: _checkInternetConnection,
//         textColor: Colors.white,
//       ),
//     ),
//   );
// }





//   // Future<bool> _onWillPop() async {
//   //   if (lastBackPressTime == null ||
//   //       DateTime.now().difference(lastBackPressTime!) >
//   //           const Duration(seconds: 2)) {
//   //     setState(() => lastBackPressTime = DateTime.now());
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text(('tap_again_to_close'.tr())),
//   //         duration: const Duration(seconds: 2),
//   //       ),
//   //     );
//   //     return false;
//   //   }
//   //   await SystemNavigator.pop();
//   //   return true;
//   // }

//   Future<void> _initializeAudioPlayer() async {
//     try {
//       await audioPlayer.setSource(AssetSource('sound/notification.wav'));
//       await audioPlayer.setVolume(notificationVolume);
//     } catch (e) {
//       log('Error initializing audio player: $e');
//     }
//   }

//   Future<void> _checkVibrationCapability() async {
//     try {
//       // Implement vibration check here if needed
//       canVibrate = false;
//     } catch (e) {
//       log('Error checking vibration capability: $e');
//       canVibrate = false;
//     }
//   }

//   Future<void> _getToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _token = prefs.getString('token');
//       });
//     } catch (e) {
//       log('Error getting token: $e');
//     }
//   }

//   void _playNotification() async {
//     try {
//       await audioPlayer.play(AssetSource('sound/notifications.wav'));
//       if (canVibrate) {
//         // Implement vibration here if needed
//       }
//     } catch (e) {
//       log('Error playing notification: $e');
//     }
//   }

//   // void _handleError(String messageKey) {
//   //   if (!mounted) return;

//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Text(tr(messageKey)),
//   //       backgroundColor: Colors.red,
//   //       duration: const Duration(seconds: 3),
//   //       action: SnackBarAction(
//   //         label: 'Dismiss',
//   //         onPressed: () {},
//   //         textColor: Colors.white,
//   //       ),
//   //     ),
//   //   );
//   // }

//   // void _handleNoInternet() {
//   //   if (isInternetConnected) {
//   //     setState(() => isInternetConnected = false);
//   //     _showNoInternetSnackBar();
//   //   }
//   // }

//   // void _showNoInternetSnackBar() {
//   //   if (!mounted) return;

//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Text(tr('no_internet_connection')),
//   //       duration: const Duration(days: 365),
//   //       backgroundColor: Colors.red,
//   //       action: SnackBarAction(
//   //         label: ('retry'.tr()),
//   //         onPressed: _checkInternetConnection,
//   //         textColor: Colors.white,
//   //       ),
//   //     ),
//   //   );
//   // }

//   Future<void> _checkInternetConnection() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         if (!isInternetConnected) {
//           setState(() => isInternetConnected = true);
//           if (socket == null || !socket!.connected) {
//             connectToSocket();
//           }
//         }
//       } else {
//         _handleNoInternet();
//       }
//     } on SocketException catch (_) {
//       _handleNoInternet();
//     }
//   }

//   Future<void> loadMapTheme() async {
//     try {
//       String theme = await DefaultAssetBundle.of(context)
//           .loadString('assets/map_theme/night_theme.json');
//       if (mounted) {
//         setState(() => mapTheme = theme);
//       }
//     } catch (e) {
//       log('Error loading map theme: $e');
//     }
//   }

//   @override
//   void dispose() {
//     // Reset state flags
//     _isLocationInitialized = false;
//     _hasMovedToUserLocation = false;

//     // Clean up socket listeners
//     socket?.off('driver_accepted_trip');
//     socket?.off('connect');
//     socket?.off('disconnect');
//     socket?.off('error');
//     socket?.off('connect_error');

//     // Disconnect socket
//     socket?.disconnect();
//     socket = null;

//     // Dispose map controller
//     if (_isMapControllerInitialized) {
//       _controller.future.then((controller) => controller.dispose());
//     }

//     // Dispose audio player
//     audioPlayer.dispose();

//     // Clean up connectivity subscription
//     connectivitySubscription?.cancel();
//     connectivityTimer?.cancel();

//     super.dispose();
//   }
// @override
// Widget build(BuildContext context) {
//   return PopScope(
//     canPop: false,
//     onPopInvoked: _onPopInvoked,
//     child: Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _kInitialPosition,
//             myLocationEnabled: myLocationEnabled,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: true,
//             mapToolbarEnabled: false,
//             onMapCreated: (GoogleMapController controller) {
//               if (!_isMapControllerInitialized) {
//                 _controller.complete(controller);
//                 _isMapControllerInitialized = true;
//               }
//               if (mapTheme.isNotEmpty) {
//                 controller.setMapStyle(mapTheme);
//               }
//             },
//           ),

//           // No internet connection indicator
//           if (!isInternetConnected)
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 10,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.red.withOpacity(0.8),
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text(
//                   'no_internet_connection'.tr(),
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),

//           // Cancel trip button
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 10,
//             left: 10,
//             child: FloatingActionButton(
//               onPressed: _cancelTrip,
//               backgroundColor: Colors.red,
//               mini: true,
//               child: const Icon(Icons.close),
//             ),
//           ),

//           // Loading indicators
//           if (isConnected)
//             const Center(
//               child: CircularProgressIndicator(color: Colors.black),
//             )
//           else
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'choose_driver.connecting'.tr(),
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const CircularProgressIndicator(color: Colors.black),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }






// }


import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Driver Request Timer Model
class DriverRequestTimer {
  final String requestId;
  final DateTime startTime;
  Timer? timer;
  double progress = 1.0;

  DriverRequestTimer({required this.requestId}) : startTime = DateTime.now();
}

class ChooseDriverScreen extends StatefulWidget {
  final String tripId;
  const ChooseDriverScreen({super.key, required this.tripId});

  @override
  State<ChooseDriverScreen> createState() => _ChooseDriverScreenState();
}

class _ChooseDriverScreenState extends State<ChooseDriverScreen> {
  final NotificationService _notificationService = NotificationService();

  // Socket Related Variables
  IO.Socket? socket;
  bool isConnected = false;

  // Location Related Variables
  Position? currentPosition;
  bool myLocationEnabled = false;
  // bool _isLocationInitialized = false;

  // Map Related Variables
  String mapTheme = "";
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool _isMapControllerInitialized = false;
  // bool _hasMovedToUserLocation = false;

  // Driver Request Related Variables
  List<Map<String, dynamic>> driverRequests = [];
  Map<String, DriverRequestTimer> requestTimers = {};
  final int maxDriverRequests = 5;
  final int requestTimeout = 30;

  // Audio Related Variables
  final AudioPlayer audioPlayer = AudioPlayer();
  double notificationVolume = 1.0;
  bool canVibrate = false;

  // Authentication
  String? _token;

  // State Variables
  DateTime? lastBackPressTime;
  Timer? connectivityTimer;
  bool isInternetConnected = true;
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  // Initial Map Position
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(-25.7479, 28.2293),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupConnectivityListener();
  }

  Future<void> _initializeServices() async {
    await _getToken();
    // await _initializeAudioPlayer();
    // await _checkVibrationCapability();
    // await _getCurrentLocation();

    if (socket == null || !socket!.connected) {
      connectToSocket();
    }

    loadMapTheme();
  }




  Future<void> _checkVibrationCapability() async {
    try {
      // Implement vibration check here if needed
      canVibrate = false;
    } catch (e) {
      log('Error checking vibration capability: $e');
      canVibrate = false;
    }
  }

  Future<void> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _token = prefs.getString('token');
      });
    } catch (e) {
      log('Error getting token: $e');
    }
  }

  void _playNotification() async {
    try {
      await audioPlayer.play(AssetSource('sound/notifications.wav'));
      if (canVibrate) {
        // Implement vibration here if needed
      }
    } catch (e) {
      log('Error playing notification: $e');
    }
  }



  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!isInternetConnected) {
          setState(() => isInternetConnected = true);
          if (socket == null || !socket!.connected) {
            connectToSocket();
          }
        }
      } else {
        _handleNoInternet();
      }
    } on SocketException catch (_) {
      _handleNoInternet();
    }
  }

  Future<void> loadMapTheme() async {
    try {
      String theme = await DefaultAssetBundle.of(context)
          .loadString('assets/map_theme/night_theme.json');
      if (mounted) {
        setState(() => mapTheme = theme);
      }
    } catch (e) {
      log('Error loading map theme: $e');
    }
  }

  
// Handle No Internet Function
void _handleNoInternet() {
  if (isInternetConnected) {
    setState(() => isInternetConnected = false);
    _showNoInternetSnackBar();
  }
}

// Show No Internet SnackBar Function
void _showNoInternetSnackBar() {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('no_internet_connection'.tr()),
      duration: const Duration(days: 365),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'retry'.tr(),
        onPressed: _checkInternetConnection,
        textColor: Colors.white,
      ),
    ),
  );
}

  void _setupConnectivityListener() {
    if (!mounted) return;

    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!mounted) return;

      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (hasConnection) {
        if (!isInternetConnected && mounted) {
          setState(() => isInternetConnected = true);
          if (socket == null || !socket!.connected) {
            connectToSocket();
          }
        }
      } else {
        _handleNoInternet();
      }
    });

    // _checkInitialConnectivity();
  }

  // Initialize socket connection
  void connectToSocket() {
    try {
      socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      socket?.connect();

      socket?.onConnect((_) {
        log('Socket connected successfully');
        if (mounted) {
          setState(() => isConnected = true);
          joinTripRoom();
        }
      });

      socket?.onDisconnect((_) {
        log('Socket disconnected');
        if (mounted) {
          setState(() => isConnected = false);
        }
      });

      socket?.on('driver_accepted_trip', handleDriverAcceptedEvent);

      socket?.onError((err) => log('Socket error: $err'));
      socket?.onConnectError((err) => log('Socket connect error: $err'));
    } catch (e) {
      log('Error connecting to socket: $e');
    }
  }

  void joinTripRoom() {
    socket?.emit('join-room', widget.tripId);
  }

  // Handle driver acceptance
  Future<void> handleDriverAcceptedEvent(dynamic data) async {
    if (!mounted) return;

    try {
      setState(() {
        if (driverRequests.length < maxDriverRequests) {
          bool driverExists = driverRequests.any(
              (request) => request['driver']?['_id'] == data['driver']?['_id']);

          if (!driverExists) {
            // _playNotification();
            driverRequests.add(data);
            String requestId = data['_id'];
            initializeRequestTimer(requestId);
          }
        }
      });

      final driverUsername = data['driver']?['username'] ?? 'Unknown Driver';
      await _notificationService.showNotification(
        title: 'Driver Available',
        body: '$driverUsername has accepted your trip request',
      );
    } catch (e) {
      log('Error handling driver acceptance: $e');
    }
  }

  // Timer management
  void initializeRequestTimer(String requestId) {
    DriverRequestTimer requestTimer = DriverRequestTimer(requestId: requestId);
    requestTimers[requestId] = requestTimer;

    const updateInterval = Duration(milliseconds: 100);
    requestTimer.timer = Timer.periodic(updateInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsedSeconds =
          DateTime.now().difference(requestTimer.startTime).inMilliseconds / 1000;

      if (elapsedSeconds >= requestTimeout) {
        removeRequest(requestId);
        timer.cancel();
      } else {
        setState(() {
          requestTimer.progress = 1.0 - (elapsedSeconds / requestTimeout);
        });
      }
    });
  }

  void removeRequest(String requestId) {
    setState(() {
      driverRequests.removeWhere((request) => request['_id'] == requestId);
      requestTimers[requestId]?.timer?.cancel();
      requestTimers.remove(requestId);
    });
  }

  // Handle user acceptance/decline
  Future<void> acceptDriverOffer(String tripId) async {
    try {
      final response = await http.put(
        Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        socket?.emit('user_accepted_other_driver', {
          'tripId': tripId,
          'driverIds': driverRequests
              .where((req) => req['_id'] != tripId)
              .map((req) => req['driver']?['_id'])
              .toList(),
        });

        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.rideDetails,
            arguments: {
              'tripDetails': responseData,
              'initialTripDetails':
                  driverRequests.firstWhere((req) => req['_id'] == tripId),
            },
          );
        }
      }
    } catch (e) {
      _handleError('failed_to_accept_trip'.tr());
    }
  }

  void declineDriverOffer(String tripId) {
    removeRequest(tripId);
    socket?.emit('user_declined', {'tripId': tripId});
  }

  // Cancel trip functionality
  Future<void> _cancelTrip() async {
    try {
      final bool? shouldCancel = await _showCancelConfirmationDialog();
      if (shouldCancel != true) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const CancellingDialog(),
      );

      final response = await http.delete(
        Uri.parse('${Constants.apiBaseUrl}/trip/cancel-pending-trip/${widget.tripId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Remove loading dialog
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentTripId');

        socket?.disconnect();
        socket = null;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('trip_cancelled_successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.parcelScreen,
            (route) => false,
          );
        }
      } else {
        _handleError('failed_to_cancel_trip'.tr());
      }
    } catch (e) {
      log('Error in _cancelTrip: $e');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _handleError('failed_to_cancel_trip'.tr());
    }
  }

  // // Handle Error Function
void _handleError(String messageKey) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(messageKey),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'dismiss'.tr(),
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );

    void _onPopInvoked(bool didPop) async {
  if (didPop) return;

  if (lastBackPressTime == null ||
      DateTime.now().difference(lastBackPressTime!) >
          const Duration(seconds: 2)) {
    setState(() => lastBackPressTime = DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('tap_again_to_close'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }
  await SystemNavigator.pop();
}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kInitialPosition,
              myLocationEnabled: myLocationEnabled,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_isMapControllerInitialized) {
                  _controller.complete(controller);
                  _isMapControllerInitialized = true;
                }
                if (mapTheme.isNotEmpty) {
                  controller.setMapStyle(mapTheme);
                }
              },
            ),
            
            // No internet indicator
            if (!isInternetConnected)
              NoInternetBanner(),

            // Cancel trip button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: CancelButton(onPressed: _cancelTrip),
            ),

            // Driver requests panel
            if (driverRequests.isNotEmpty)
              DriverRequestsPanel(
                requests: driverRequests,
                timers: requestTimers,
                onAccept: acceptDriverOffer,
                onDecline: declineDriverOffer,
              )
            else
              // Loading indicator
              Center(
                child: LoadingIndicator(isConnected: isConnected),
              ),
          ],
        ),
      ),
    );
  }



  @override
  void dispose() {
    for (var timer in requestTimers.values) {
      timer.timer?.cancel();
    }
    requestTimers.clear();

    socket?.clearListeners();
    socket?.dispose();
    socket = null;

    audioPlayer.dispose();
    connectivitySubscription?.cancel();
    connectivityTimer?.cancel();

    super.dispose();
  }
}

// Cancel Confirmation Dialog
Future<bool?> _showCancelConfirmationDialog() async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
           
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.yellow,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                'cancel_trip_confirmation'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'cancel_trip_subtitle'.tr(),
                style: TextStyle(
                  color: const Color.fromARGB(255, 22, 22, 22),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Text(
                        'no'.tr(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'yes'.tr(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  }



    void _onPopInvoked(bool didPop) async {
  if (didPop) return;

  if (lastBackPressTime == null ||
      DateTime.now().difference(lastBackPressTime!) >
          const Duration(seconds: 2)) {
    setState(() => lastBackPressTime = DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('tap_again_to_close'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
    return;
  }
  await SystemNavigator.pop();
}
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kInitialPosition,
              myLocationEnabled: myLocationEnabled,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_isMapControllerInitialized) {
                  _controller.complete(controller);
                  _isMapControllerInitialized = true;
                }
                if (mapTheme.isNotEmpty) {
                  controller.setMapStyle(mapTheme);
                }
              },
            ),
            
            // No internet indicator
            if (!isInternetConnected)
              NoInternetBanner(),

            // Cancel trip button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: CancelButton(onPressed: _cancelTrip),
            ),

            // Driver requests panel
            if (driverRequests.isNotEmpty)
              DriverRequestsPanel(
                requests: driverRequests,
                timers: requestTimers,
                onAccept: acceptDriverOffer,
                onDecline: declineDriverOffer,
              )
            else
              // Loading indicator
              Center(
                child: LoadingIndicator(isConnected: isConnected),
              ),
          ],
        ),
      ),
    );
  }
}

// Separate widget classes for UI components
class CancellingDialog extends StatelessWidget {
  const CancellingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
            const SizedBox(height: 20),
            Text(
              'cancelling_trip'.tr(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoInternetBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.red.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'no_internet_connection'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.red,
      mini: true,
      child: const Icon(Icons.close),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final bool isConnected;

  const LoadingIndicator({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isConnected ? 'waiting_for_drivers'.tr() : 'connecting'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        const CircularProgressIndicator(color: Colors.black),
      ],
    );
  }
}

class DriverRequestsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Map<String, DriverRequestTimer> timers;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const DriverRequestsPanel({
    super.key,
    required this.requests,
    required this.timers,
    required this.onAccept,
    required this.onDecline,
    });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'available_drivers'.tr(args: [requests.length.toString()]),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final timer = timers[request['_id']];
                  return DriverCard(
                    request: request,
                    timer: timer,
                    onAccept: () => onAccept(request['_id']),
                    onDecline: () => onDecline(request['_id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final DriverRequestTimer? timer;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const DriverCard({
    super.key,
    required this.request,
    this.timer,
    required this.onAccept,
    required this.onDecline,
  });

  Color _getProgressColor(double progress) {
    if (progress > 0.6) return Colors.green;
    if (progress > 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final driver = request['driver'] ?? {};
    final double progress = timer?.progress ?? 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    driver['profilePicture'] ?? 'https://placeholder.com/user',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['username'] ?? 'Unknown Driver',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${(driver['rating'] ?? 0.0).toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(request['estimatedFare'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${(progress * 30).toInt()}s',
                      style: TextStyle(
                        color: _getProgressColor(progress),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('decline'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('accept'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}