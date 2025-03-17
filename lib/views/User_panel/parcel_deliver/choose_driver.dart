
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/views/User_panel/parcel_deliver/show_rider_details.dart';
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

// Theme constants
class AppTheme {
  static const Color primaryColor = Color(0xFF86E30F); 
  static const Color cardColor = Color(0xFFF5FFE8); 
  static const Color backgroundColor = Color(0xFFF8F9FA); 
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

  // Map Related Variables
  String mapTheme = "";
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool _isMapControllerInitialized = false;

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
        content: const Text('No internet connection'),
        duration: const Duration(days: 365),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
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
  }



// Update the socket event handling method
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

    // Updated socket event listener
    socket?.on('driver_accepted_trip', (data) async {
      log('Driver accepted trip event received: $data');
      
      if (!mounted) return;

      try {
        // Validate data structure
        if (data == null || data['_id'] == null) {
          log('Invalid driver acceptance data');
          return;
        }

        setState(() {
          if (driverRequests.length < maxDriverRequests) {
            bool driverExists = driverRequests.any(
                (request) => request['_id'] == data['_id']);

            if (!driverExists) {
              driverRequests.add(data);
              initializeRequestTimer(data['_id']);
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
    });
  } catch (e) {
    log('Error connecting to socket: $e');
  }
}

Future<void> acceptDriverOffer(String tripId) async {
  log('BEGIN acceptDriverOffer for tripId: $tripId');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    log('Token not found');
    return;
  }

  try {
    log('Showing loading dialog...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const CancellingDialog(), 
    );

    log('Making API request to accept driver offer...');
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    log('Accept Driver Offer Response: ${response.statusCode}');
    log('Response Body: ${response.body}');


     if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    
    // Save trip ID to SharedPreferences
    await prefs.setString('currentTripId', tripId);
    
    // Find the corresponding driver request
    final driverRequest = driverRequests.firstWhere(
      (req) => req['_id'] == tripId,
      orElse: () => {},
    );
    
    // Dismiss loading dialog
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // IMPORTANT: Create the proper nested structure that ShowRiderDetails expects
    final navigationData = {
      'tripDetails': {
        'tripDetails': {  // Add this extra nesting level
          '_id': tripId,
          'passenger': {'_id': driverRequest['passenger'] ?? ''},
          'status': 'user_accepted'
        }
      },
      'initialTripDetails': driverRequest.isNotEmpty ? driverRequest : {
        'driver': {
          '_id': driverRequest['driver']?['_id'] ?? '',
          'userid': {
            '_id': driverRequest['driver']?['userid']?['_id'] ?? '',
            'phone': driverRequest['driver']?['userid']?['phone'] ?? ''
          },
          'username': driverRequest['driver']?['username'] ?? 'Driver',
          'ratingAverage': driverRequest['driver']?['ratingAverage'] ?? 0.0,
          'profilePicture': driverRequest['driver']?['profilePicture'] ?? ''
        },
        'pickup': driverRequest['pickup'] ?? '0,0',
        'destination': driverRequest['destination'] ?? '0,0',
        'driverLocation': {
          'latitude': driverRequest['driverLocation']?['latitude'] ?? 0.0,
          'longitude': driverRequest['driverLocation']?['longitude'] ?? 0.0
        },
        'driverEstimatedFare': driverRequest['driverEstimatedFare'] ?? 0.0
      }
    };
    
  //   if (mounted) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ShowRiderDetails(
  //           tripDetails: navigationData['tripDetails'],
  //           initialTripDetails: navigationData['initialTripDetails'],
  //         ),
  //       ),
  //     );
  //   }
  // }

    // if (response.statusCode == 200) {
    //   final responseData = jsonDecode(response.body);
      
    //   // Save trip ID to SharedPreferences
    //   await prefs.setString('currentTripId', tripId);
    //   log('Saved trip ID to SharedPreferences: $tripId');

    //   // Find the corresponding driver request
    //   final driverRequest = driverRequests.firstWhere(
    //     (req) => req['_id'] == tripId,
    //     orElse: () => {},
    //   );

    //   // Dismiss loading dialog
    //   if (mounted && Navigator.canPop(context)) {
    //     Navigator.pop(context);
    //   }
      
    //   // IMPORTANT: Create properly structured data for ShowRiderDetails
    //   final navigationData = {
    //     'tripDetails': responseData['tripDetails'] ?? {
    //       '_id': tripId,
    //       'passenger': {'_id': responseData['tripDetails']?['passenger'] ?? ''},
    //       'status': 'user_accepted'
    //     },
    //     'initialTripDetails': driverRequest.isNotEmpty ? driverRequest : {
    //       'driver': {
    //         '_id': driverRequest['driver']?['_id'] ?? '',
    //         'userid': {
    //           '_id': driverRequest['driver']?['userid']?['_id'] ?? '',
    //           'phone': driverRequest['driver']?['userid']?['phone'] ?? ''
    //         },
    //         'username': driverRequest['driver']?['username'] ?? 'Driver',
    //         'ratingAverage': driverRequest['driver']?['ratingAverage'] ?? 0.0
    //       },
    //       'pickup': driverRequest['pickup'] ?? '0,0',
    //       'destination': driverRequest['destination'] ?? '0,0',
    //       'driverLocation': driverRequest['driverLocation'] ?? {
    //         'latitude': 0.0,
    //         'longitude': 0.0
    //       },
    //       'driverEstimatedFare': driverRequest['driverEstimatedFare'] ?? 0.0
    //     }
    //   };
      
    //   // Log the data we're navigating with
    //   log('Navigating with data: $navigationData');

      // Use Navigator.push instead of pushReplacement for more reliable navigation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowRiderDetails(
              tripDetails: navigationData['tripDetails'] ?? {}, // Added null check with empty map as default
              initialTripDetails: navigationData['initialTripDetails'] ?? {},
            ),
          ),
        );
      }
    } else {
      // Handle error response
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _handleError('Failed to accept trip: ${response.statusCode}');
    }
  } catch (e) {
    log('Error in acceptDriverOffer: $e');
    log('Stack trace: ${StackTrace.current}');
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _handleError('Failed to accept trip: ${e.toString()}');
  }
}

// Future<void> acceptDriverOffer(String tripId) async {
//   log('BEGIN acceptDriverOffer for tripId: $tripId');
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');

//   if (token == null) {
//     log('Token not found');
//     return;
//   }

//   try {
//     log('Showing loading dialog...');
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => const CancellingDialog(), 
//     );

//     log('Making API request to accept driver offer...');
//     final response = await http.put(
//       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     log('Accept Driver Offer Response: ${response.statusCode}');
//     log('Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
      
//       // Save trip ID to SharedPreferences
//       await prefs.setString('currentTripId', tripId);
//       log('Saved trip ID to SharedPreferences: $tripId');

//       // Find the corresponding driver request
//       log('Looking for driver request with tripId: $tripId');
//       final driverRequest = driverRequests.firstWhere(
//         (req) => req['_id'] == tripId,
//         orElse: () => {},
//       );
//       log('Found driver request: ${driverRequest.isNotEmpty ? 'YES' : 'NO'}');

//       // Prepare navigation data
//       final navigationData = {
//         'tripDetails': responseData['tripDetails'],
//         'initialTripDetails': driverRequest.isNotEmpty ? driverRequest : {
//           '_id': tripId,
//           'status': 'user_accepted'
//         },
//         'tripId': tripId  // Make sure you include this!
//       };
//       log('Prepared navigation data: $navigationData');

//       // Dismiss loading dialog
//       if (mounted && Navigator.canPop(context)) {
//         log('Dismissing loading dialog');
//         Navigator.pop(context);
//       }

//       // Add a timestamp before navigation
//       final beforeNav = DateTime.now();
//       log('ABOUT TO NAVIGATE at ${beforeNav.toString()}');

//       // Navigate to next screen with complete data
//       if (mounted) {
//         log('=== NAVIGATION START === pushing to ${AppRoutes.rideDetails}');
//         Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => const ShowRiderDetails(
//       tripDetails: {
//         'tripDetails': {
//           'passenger': {'_id': 'actualPassengerId'},
//           '_id': 'actualTripId'
//         }
//       },
//       initialTripDetails: {
//         'driver': {
//           'userid': {
//             '_id': 'actualDriverId',
//             'phone': 'driverPhoneNumber'
//           },
//           'username': 'Driver Name',
//           'ratingAverage': 4.5
//         },
//         'pickup': '24.8806697, 67.0690683',
//         'destination': '24.8822133, 67.0673898',
//         'driverLocation': {
//           'latitude': 24.8807527,
//           'longitude': 67.069163
//         }
//       }
//     ),
//   ),
// );
//         // Navigator.pushReplacementNamed(
//         //   context,
//         //   AppRoutes.rideDetails,
//         //   arguments: navigationData,
//         // );
//         log('=== NAVIGATION COMMAND SENT ===');
        
//         // Add a small delay and check if still mounted
//         Future.delayed(const Duration(milliseconds: 100), () {
//           if (mounted) {
//             log('Still mounted after navigation: YES');
//           } else {
//             log('Still mounted after navigation: NO');
//           }
//         });
//       } else {
//         log('Widget not mounted, cannot navigate');
//       }
//     } else if (response.statusCode == 400) {
//       // Detailed logging for 400 status
//       log('Received 400 error response');
//       try {
//         final errorBody = jsonDecode(response.body);
//         log('400 Error Details: $errorBody');
        
//         final errorMessage = errorBody['message'] ?? 'Unknown error';
//         log('Specific Error Message: $errorMessage');

//         _handleDetailedError(
//           statusCode: response.statusCode, 
//           errorMessage: errorMessage,
//           fullErrorBody: errorBody
//         );
//       } catch (parseError) {
//         log('Error parsing 400 response body: $parseError');
//         _handleError('Failed to parse error response');
//       }
//     } else {
//       log('Received error response: ${response.statusCode}');
//       _handleError('Failed to accept trip: ${response.statusCode}');
//     }
//   } catch (e) {
//     log('Error in acceptDriverOffer: $e');
//     log('Stack trace: ${StackTrace.current}');
//     _handleError('Failed to accept trip');
//   } finally {
//     // Ensure loading dialog is dismissed
//     if (mounted && Navigator.canPop(context)) {
//       log('Ensuring dialog is dismissed in finally block');
//       Navigator.pop(context);
//     }
//     log('END acceptDriverOffer for tripId: $tripId');
//   }
// }









// Future<void> acceptDriverOffer(String tripId) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');

//   if (token == null) {
//     log('Token not found');
//     return;
//   }

//   try {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => const CancellingDialog(), 
//     );

//     final response = await http.put(
//       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     log('Accept Driver Offer Response: ${response.statusCode}');
//     log('Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
      
//       // Save trip ID to SharedPreferences
//       await prefs.setString('currentTripId', tripId);
//       log('Saved trip ID to SharedPreferences: $tripId');

//       // Find the corresponding driver request
//       final driverRequest = driverRequests.firstWhere(
//         (req) => req['_id'] == tripId,
//         orElse: () => {},
//       );

//       // Dismiss loading dialog
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       // Navigate to next screen with complete data
//       if (mounted) {
//         Navigator.pushReplacementNamed(
//           context,
//           AppRoutes.rideDetails,
//           arguments: {
//             'tripDetails': responseData['tripDetails'],
//             'initialTripDetails': driverRequest.isNotEmpty ? driverRequest : {
//               '_id': tripId,
//               'status': 'user_accepted'
//             },
         
//           },
//         );
//       }
//     } else if (response.statusCode == 400) {
//       // Detailed logging for 400 status
//       try {
//         final errorBody = jsonDecode(response.body);
//         log('400 Error Details: $errorBody');
        
//         final errorMessage = errorBody['message'] ?? 'Unknown error';
//         log('Specific Error Message: $errorMessage');

//         _handleDetailedError(
//           statusCode: response.statusCode, 
//           errorMessage: errorMessage,
//           fullErrorBody: errorBody
//         );
//       } catch (parseError) {
//         log('Error parsing 400 response body: $parseError');
//         _handleError('Failed to parse error response');
//       }
//     } else {
//       _handleError('Failed to accept trip: ${response.statusCode}');
//     }
//   } catch (e) {
//     log('Error in acceptDriverOffer: $e');
//     _handleError('Failed to accept trip');
//   } finally {
//     // Ensure loading dialog is dismissed
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }
//   }
// }

// Future<void> acceptDriverOffer(String tripId) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');

//   if (token == null) {
//     log('Token not found');
//     return;
//   }

//   try {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => const CancellingDialog(), 
//     );

//     final response = await http.put(
//       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     log('Accept Driver Offer Response: ${response.statusCode}');
//     log('Response Body: ${response.body}');

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
      
//       // Save trip ID to SharedPreferences
//       await prefs.setString('currentTripId', tripId);
//       log('Saved trip ID to SharedPreferences: $tripId');

//       // Dismiss loading dialog
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       // Navigate to next screen immediately
//       Navigator.pushReplacementNamed(
//         context,
//         AppRoutes.rideDetails,
//         arguments: {
//           'tripDetails': responseData['tripDetails'],
//           'tripId': tripId
//         },
//       );
//     } else if (response.statusCode == 400) {
//       // Detailed logging for 400 status
//       try {
//         final errorBody = jsonDecode(response.body);
//         log('400 Error Details: $errorBody');
        
//         final errorMessage = errorBody['message'] ?? 'Unknown error';
//         log('Specific Error Message: $errorMessage');

//         _handleDetailedError(
//           statusCode: response.statusCode, 
//           errorMessage: errorMessage,
//           fullErrorBody: errorBody
//         );
//       } catch (parseError) {
//         log('Error parsing 400 response body: $parseError');
//         _handleError('Failed to parse error response');
//       }
//     } else {
//       _handleError('Failed to accept trip: ${response.statusCode}');
//     }
//   } catch (e) {
//     log('Error in acceptDriverOffer: $e');
//     _handleError('Failed to accept trip');
//   } finally {
//     // Ensure loading dialog is dismissed
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }
//   }
// }


// Enhanced error handling method
  void _handleDetailedError({
  required int statusCode, 
  required String errorMessage,
  Map<String, dynamic>? fullErrorBody
}) {
  log('Detailed Error Handling:');
  log('Status Code: $statusCode');
  log('Error Message: $errorMessage');
  
  if (fullErrorBody != null) {
    fullErrorBody.forEach((key, value) {
      log('Error Detail - $key: $value');
    });
  }

  // Show user-friendly error dialog
  _showErrorDialog(
    context,
    'Trip Acceptance Failed',
    errorMessage,
  );
}

// Show error dialog to user
void _showErrorDialog(BuildContext context, String title, String message) {
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      );
    },
  );
}

// // Modify the acceptDriverOffer method
// Future<void> acceptDriverOffer(String tripId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');

//     if (token == null) {
//       log('Token not found');
//       return;
//     }

//   try {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => const CancellingDialog(), 
//     );

//     final response = await http.put(
//       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
      
//       socket?.on('trip_confirmed', (confirmationData) {
//         if (confirmationData['tripId'] == tripId) {
//           // Navigate to next screen
//           Navigator.pushReplacementNamed(
//             context,
//             AppRoutes.rideDetails,
//             arguments: {
//               'tripDetails': responseData['tripDetails'],
//             },
//           );
//         }
//       });
//     } else {
//       _handleError('Failed to accept trip: ${response.statusCode}');
//     }
//   } catch (e) {
//     log('Error in acceptDriverOffer: $e');
//     _handleError('Failed to accept trip');
//   } finally {
//     // Ensure loading dialog is dismissed
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }
//   }
// }




  // // Initialize socket connection
  // void connectToSocket() {
  //   try {
  //     socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
  //       'transports': ['websocket'],
  //       'autoConnect': false,
  //       'reconnection': true,
  //       'reconnectionAttempts': 5,
  //       'reconnectionDelay': 1000,
  //     });

  //     socket?.connect();

  //     socket?.onConnect((_) {
  //       log('Socket connected successfully');
  //       if (mounted) {
  //         setState(() => isConnected = true);
  //         joinTripRoom();
  //       }
  //     });

  //     socket?.onDisconnect((_) {
  //       log('Socket disconnected');
  //       if (mounted) {
  //         setState(() => isConnected = false);
  //       }
  //     });

  //     socket?.on('driver_accepted_trip', (data) async {
  //       log('Driver accepted trip event received: $data');
  //       await handleDriverAcceptedEvent(data);
  //     });

  //     socket?.onError((err) => log('Socket error: $err'));
  //     socket?.onConnectError((err) => log('Socket connect error: $err'));
  //   } catch (e) {
  //     log('Error connecting to socket: $e');
  //   }
  // }

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


//   Future<void> acceptDriverOffer(String tripId) async {
//   try {
//     // Show loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => const CancellingDialog(), 
//     );

//     final response = await http.put(
//       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $_token',
//       },
//     );

//     log('User accepted trip API response: ${response.statusCode} - ${response.body}');

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
      
//       log('User accepted trip response data: $responseData');
      
//       // Find the driver request data that matches the tripId
//       final driverRequest = driverRequests.firstWhere(
//         (req) => req['_id'] == tripId,
//         orElse: () => {}
//       );
      
//       log('Selected driver request: $driverRequest');
      
//       // Prepare to emit event, making sure it includes all required data
//       // Standardize the structure to match what both server and driver expect
//       final eventData = {
//         'status': 'user_accepted',
//         'tripDetails': responseData['tripDetails'] ?? {
//           '_id': tripId,
//           'status': 'user_accepted',
//           'pickup': driverRequest['pickup'],
//           'destination': driverRequest['destination'],
//           'driverEstimatedFare': driverRequest['driverEstimatedFare'],
//         },
//         'tripId': tripId
//       };
      
//       log('Emitting user_accepted_trip event: $eventData');
      
//       // Emit event to notify driver through socket
//       socket?.emit('user_accepted_trip', eventData);

//       // Notify other drivers they weren't selected
//       socket?.emit('user_accepted_other_driver', {
//         'tripId': tripId,
//         'driverIds': driverRequests
//             .where((req) => req['_id'] != tripId)
//             .map((req) => req['driver']?['_id'])
//             .toList(),
//       });

//       // Wait to ensure socket events are sent
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       // Hide loading indicator
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       if (mounted) {
//         final dataToPass = {
//           'tripDetails': responseData['tripDetails'] ?? eventData['tripDetails'],
//           'initialTripDetails': driverRequest.isNotEmpty ? driverRequest : {
//             '_id': tripId,
//             'status': 'user_accepted'
//           },
//         };
        
//         log('Navigating to ride details with data: $dataToPass');
        
//         Navigator.pushReplacementNamed(
//           context,
//           AppRoutes.rideDetails,
//           arguments: dataToPass,
//         );
//       }
//     } else {
//       // Hide loading indicator if still showing
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//       _handleError('Failed to accept trip: ${response.statusCode}');
//     }
//   } catch (e) {
//     log('Error in acceptDriverOffer: $e');
//     // Hide loading indicator if still showing
//     if (mounted && Navigator.canPop(context)) {
//       Navigator.pop(context);
//     }
//     _handleError('Failed to accept trip: ${e.toString()}');
//   }
// }

  // Future<void> acceptDriverOffer(String tripId) async {
  //   try {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) => const CancellingDialog(), 
  //     );

  //     final response = await http.put(
  //       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $_token',
  //       },
  //     );

  //     // Hide loading indicator
  //     if (Navigator.canPop(context)) {
  //       Navigator.pop(context);
  //     }

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
        
  //       log('User accepted trip response: ${response.body}');
        
  //       // Emit event to notify driver through socket
  //       socket?.emit('user_accepted_trip', {
  //         'status': 'user_accepted',
  //         'tripDetails': responseData['tripDetails'],
  //         'tripId': tripId
  //       });

  //       // Notify other drivers they weren't selected
  //       socket?.emit('user_accepted_other_driver', {
  //         'tripId': tripId,
  //         'driverIds': driverRequests
  //             .where((req) => req['_id'] != tripId)
  //             .map((req) => req['driver']?['_id'])
  //             .toList(),
  //       });

  //       if (mounted) {
  //         // Add a delay to ensure socket events are sent before navigation
  //         await Future.delayed(const Duration(milliseconds: 300));
          
  //         Navigator.pushNamed(
  //           context,
  //           AppRoutes.rideDetails,
  //           arguments: {
  //             'tripDetails': responseData['tripDetails'],
  //             'initialTripDetails':
  //                 driverRequests.firstWhere((req) => req['_id'] == tripId),
  //           },
  //         );
  //       }
  //     } else {
  //       _handleError('Failed to accept trip: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log('Error in acceptDriverOffer: $e');
  //     _handleError('Failed to accept trip');
  //   }
  // }

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
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentTripId');

        socket?.disconnect();
        socket = null;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip cancelled successfully'),
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
        _handleError('Failed to cancel trip');
      }
    } catch (e) {
      log('Error in _cancelTrip: $e');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _handleError('Failed to cancel trip');
    }
  }

  // Handle Error Function
  void _handleError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  // Show Cancel Confirmation Dialog
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
                  color: AppTheme.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cancel Trip?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to cancel this trip? This action cannot be undone.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 22, 22, 22),
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
                        child: const Text(
                          'No',
                          style: TextStyle(
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
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
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
        const SnackBar(
          content: Text('Tap again to close'),
          duration: Duration(seconds: 2),
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
              const NoInternetBanner(),

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
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(height: 20),
            Text(
              'Accepting trip...',
              style: TextStyle(
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
  const NoInternetBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.red.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          'No internet connection',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
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
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      elevation: 4,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isConnected ? 'Waiting for drivers' : 'Connecting...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: Colors.white),
        ],
      ),
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
          color: AppTheme.backgroundColor,
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
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Available Drivers (${requests.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                ],
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
    if (progress > 0.6) return AppTheme.primaryColor;
    if (progress > 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final driver = request['driver'] ?? {};
    final double progress = timer?.progress ?? 1.0;
    final vehicleType = driver['vehicleDetails']?['vehicleType'] ?? 'Car';
    final vehicleName = driver['vehicleDetails']?['vehicleName'] ?? 'Standard';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.primaryColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  backgroundImage: NetworkImage(
                    driver['profilePicture'] ?? 'https://placeholder.com/user',
                  ),
                  onBackgroundImageError: (_, __) {},
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
                          color: Colors.black
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${(driver['ratingAverage'] ?? 0.0).toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            vehicleType.toLowerCase().contains('bike') 
                                ? Icons.motorcycle 
                                : Icons.directions_car,
                            size: 16,
                            color: Colors.black,
                          ),
                          Text(
                            ' $vehicleName',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
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
                      '\$${(request['driverEstimatedFare'] ?? request['estimatedFare'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: _getProgressColor(progress),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(progress * 30).toInt()}s',
                          style: TextStyle(
                            color: _getProgressColor(progress),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
              borderRadius: BorderRadius.circular(2),
              minHeight: 4,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
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