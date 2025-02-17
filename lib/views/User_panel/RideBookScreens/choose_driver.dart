// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'dart:developer';
// // // import 'package:easy_localization/easy_localization.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // // import 'package:provider/provider.dart';
// // // import 'package:sendme/utils/constant/api_base_url.dart';
// // // import 'package:sendme/utils/location_utils.dart';

// // // // import 'package:sendme/viewmodel/provider/user_accept.dart';
// // // import 'package:sendme/views/User_panel/RideBookScreens/show_rider_details.dart';
// // // import 'package:sendme/views/User_panel/RideBookScreens/widgets/driver_request_card.dart';
// // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:http/http.dart' as http;

// // // class ChooseDriverScreen extends StatefulWidget {
// // //   final String tripId;

// // //   const ChooseDriverScreen({Key? key, required this.tripId}) : super(key: key);

// // //   @override
// // //   _ChooseDriverScreenState createState() => _ChooseDriverScreenState();
// // // }

// // // class _ChooseDriverScreenState extends State<ChooseDriverScreen> {
// // //   IO.Socket? socket;
// // //   bool isConnected = false;
// // //   Map<String, dynamic> tripDetails = {};
// // //   bool isDriverAccepted = false;
// // //   String mapTheme = "";
// // //   final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
// // //   bool _isMapControllerInitialized = false;
// // //   String? _token;

// // //    // Add this to store multiple driver requests
// // //   List<Map<String, dynamic>> driverRequests = [];

// // //   static const CameraPosition _kKarachi = CameraPosition(
// // //     target: LatLng(24.8607, 67.0011),
// // //     zoom: 14.4746,
// // //   );

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     log('ChooseDriverScreen - initState with tripId: ${widget.tripId}');
// // //     _getToken();
// // //     connectToSocket();
// // //     loadMapTheme();
// // //   }

// // //   Future<void> _getToken() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     setState(() {
// // //       _token = prefs.getString('token');
// // //     });
// // //     log('Token retrieved: $_token');
// // //   }

// // //   void connectToSocket() {
// // //     log("ChooseDriverScreen - Attempting to connect to socket");
// // //     socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
// // //       'transports': ['websocket'],
// // //       'autoConnect': false,
// // //       'reconnection': true,
// // //       'reconnectionAttempts': 5,
// // //       'reconnectionDelay': 1000,
// // //     });

// // //     socket?.connect();

// // //     socket?.onConnect((_) {
// // //       log('ChooseDriverScreen - Socket connected successfully');
// // //       if (mounted) {
// // //         setState(() {
// // //           isConnected = true;
// // //         });
// // //       }
// // //       joinTripRoom();
// // //     });

// // //     socket?.onConnectError((err) => log('ChooseDriverScreen - Socket connect error: $err'));
// // //     socket?.onError((err) => log('ChooseDriverScreen - Socket error: $err'));

// // //     socket?.on('driver_accepted_trip', (data) {
// // //       log('ChooseDriverScreen - Received driver_accepted_trip event: ${json.encode(data)}');
// // //       handleDriverAccepted(data);
// // //     });

// // //     socket?.onAny((event, data) {
// // //       log('ChooseDriverScreen - Received socket event: $event with data: ${json.encode(data)}');
// // //     });
// // //   }

// // //   void joinTripRoom() {
// // //     socket?.emit('join-room', widget.tripId);
// // //     log('ChooseDriverScreen - Emitted join-room event for tripId: ${widget.tripId}');
// // //   }

// // //   void handleDriverAccepted(dynamic data) {
// // //     log('ChooseDriverScreen - handleDriverAccepted called with data: ${json.encode(data)}');

// // //     if (!mounted) {
// // //       log('ChooseDriverScreen - Widget is no longer mounted. Skipping state update.');
// // //       return;
// // //     }

// // //     setState(() {
// // //       // Add new driver request to the list if it doesn't exist
// // //       if (!driverRequests.any((request) => request['_id'] == data['_id'])) {
// // //         driverRequests.add(data);
// // //       }
// // //       isDriverAccepted = true;
// // //     });

// // //     // Calculate driver info for the new request
// // //     calculateDriverToPickupInfo(data);
// // //   }

// // //   Future<void> calculateDriverToPickupInfo(Map<String, dynamic> driverRequest) async {
// // //     if (!mounted) return;

// // //     if (driverRequest['driverLocation'] != null && driverRequest['pickup'] != null) {
// // //       LatLng driverLatLng = LatLng(
// // //         driverRequest['driverLocation']['latitude'],
// // //         driverRequest['driverLocation']['longitude']
// // //       );
// // //       LatLng pickupLatLng = _parseLatLng(driverRequest['pickup']);

// // //       Map<String, dynamic> info = await LocationUtils.calculateDriverToPickupDistanceAndTime(
// // //         driverLatLng,
// // //         pickupLatLng
// // //       );

// // //       setState(() {
// // //         // Update the specific driver request with pickup info
// // //         int index = driverRequests.indexWhere((request) => request['_id'] == driverRequest['_id']);
// // //         if (index != -1) {
// // //           driverRequests[index]['driverToPickupInfo'] = 'choose_driver.pickup_info'.tr(
// // //             args: [info['distance'], info['duration']]
// // //           );
// // //         }
// // //       });
// // //     }
// // //   }

// // //   LatLng _parseLatLng(String latLngString) {
// // //     List<String> parts = latLngString.split(',');
// // //     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
// // //   }

// // //   Future<void> acceptDriverOffer(String tripId) async {
// // //   log('ChooseDriverScreen - Accepting driver offer for trip: $tripId');
// // //   if (!mounted) return;

// // //   try {
// // //     if (_token == null) {
// // //       throw Exception('choose_driver.no_token'.tr());
// // //     }

// // //     final response = await http.put(
// // //       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
// // //       headers: {
// // //         'Content-Type': 'application/json',
// // //         'Authorization': 'Bearer $_token',
// // //       },
// // //     );

// // //     log('Response status code: ${response.statusCode}');
// // //     log('Response body: ${response.body}');

// // //     if (response.statusCode == 200) {
// // //       final responseData = jsonDecode(response.body);
// // //       log('User accept API response: $responseData');

// // //       // Notify socket about acceptance
// // //       socket?.emit('user_accepted', {
// // //         'tripId': tripId,
// // //       });

// // //       if (mounted) {
// // //         // Navigate to ride details screen
// // //         Navigator.pushReplacement(
// // //           context,
// // //           MaterialPageRoute(
// // //             builder: (context) => ShowRiderDetails(
// // //               tripDetails: {
// // //                 'tripDetails': responseData, // API response
// // //               },
// // //               initialTripDetails: tripDetails, // Current trip details with driver info
// // //             ),
// // //           ),
// // //         );
// // //       }
// // //     } else {
// // //       final errorData = jsonDecode(response.body);
// // //       throw Exception(errorData['message'] ?? 'choose_driver.accept_failed'.tr());
// // //     }
// // //   } catch (e) {
// // //     log('Error accepting driver offer: $e');
// // //     if (mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text('choose_driver.accept_trip_failed'.tr()),
// // //           backgroundColor: Colors.red,
// // //           duration: const Duration(seconds: 3),
// // //         ),
// // //       );
// // //     }
// // //   }
// // // }

// // // @override
// // //   void dispose() {
// // //     log('ChooseDriverScreen - dispose');
// // //     socket?.off('driver_accepted_trip');
// // //     socket?.disconnect();
// // //     socket?.dispose();
// // //     socket = null;
// // //     super.dispose();
// // //   }

// // //   // Future<void> acceptDriverOffer(String tripId) async {
// // //   //   log('ChooseDriverScreen - Accepting driver offer for trip: $tripId');
// // //   //   if (!mounted) {
// // //   //     log('ChooseDriverScreen - Widget is no longer mounted. Skipping accept driver offer.');
// // //   //     return;
// // //   //   }

// // //   //   try {
// // //   //     if (_token == null) {
// // //   //       throw Exception('choose_driver.no_token'.tr());
// // //   //     }

// // //   //     final response = await http.put(
// // //   //       Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
// // //   //       headers: {
// // //   //         'Content-Type': 'application/json',
// // //   //         'Authorization': 'Bearer $_token',
// // //   //       },
// // //   //     );

// // //   //     if (response.statusCode == 200) {
// // //   //       final responseData = jsonDecode(response.body);
// // //   //       log('User accept API response: $responseData');

// // //   //       if (mounted) {
// // //   //         Navigator.pushNamed(
// // //   //           context,
// // //   //           AppRoutes.rideDetails,
// // //   //           arguments: {
// // //   //             'tripDetails': responseData,
// // //   //             'initialTripDetails': tripDetails
// // //   //           },
// // //   //         );
// // //   //       }
// // //   //     } else {
// // //   //       throw Exception('choose_driver.accept_failed'.tr());
// // //   //     }
// // //   //   } catch (e) {
// // //   //     log('ChooseDriverScreen - Error accepting driver offer: $e');
// // //   //     if (mounted) {
// // //   //       ScaffoldMessenger.of(context).showSnackBar(
// // //   //         SnackBar(content: Text('choose_driver.accept_trip_failed'.tr())),
// // //   //       );
// // //   //     }
// // //   //   }
// // //   // }

// // //  // Update decline handler to remove specific driver request
// // //   void declineDriverOffer(String tripId) {
// // //     log('ChooseDriverScreen - Declining driver offer for trip: $tripId');
// // //     setState(() {
// // //       driverRequests.removeWhere((request) => request['_id'] == tripId);
// // //       if (driverRequests.isEmpty) {
// // //         isDriverAccepted = false;
// // //       }
// // //     });

// // //     socket?.emit('user_declined', {
// // //       'tripId': tripId,
// // //     });
// // //   }

// // //   // void declineDriverOffer(String tripId) {
// // //   //   log('ChooseDriverScreen - Declining driver offer for trip: $tripId');
// // //   //   Provider.of<TripProvider>(context, listen: false).reset();
// // //   //   socket?.emit('user_declined', {
// // //   //     'tripId': tripId,
// // //   //   });
// // //   // }

// // //   void loadMapTheme() {
// // //     DefaultAssetBundle.of(context)
// // //         .loadString('assets/map_theme/night_theme.json')
// // //         .then((value) {
// // //       if (mounted) {
// // //         setState(() {
// // //           mapTheme = value;
// // //         });
// // //       }
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     log('ChooseDriverScreen - build method called. isDriverAccepted: $isDriverAccepted');
// // //     return Scaffold(
// // //       body: Stack(
// // //         children: [
// // //            GoogleMap(
// // //             initialCameraPosition: _kKarachi,
// // //             onMapCreated: (GoogleMapController controller) {
// // //               if (!_isMapControllerInitialized) {
// // //                 _controller.complete(controller);
// // //                 _isMapControllerInitialized = true;
// // //               }
// // //               if (mapTheme.isNotEmpty) {
// // //                 controller.setMapStyle(mapTheme);
// // //               }
// // //             },
// // //           ),
// // //           Align(
// // //             alignment: Alignment.bottomCenter,
// // //             child: Container(
// // //               width: double.infinity,
// // //               height: MediaQuery.of(context).size.height * 0.7,
// // //               decoration: const BoxDecoration(
// // //                 color: Colors.black,
// // //                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// // //               ),
// // //               child: Column(
// // //                 children: [
// // //                   Padding(
// // //                     padding: const EdgeInsets.all(16.0),
// // //                     child: Text(
// // //                       isDriverAccepted
// // //                           ? 'choose_driver.available_drivers'.tr()
// // //                           : 'choose_driver.waiting_for_driver'.tr(),
// // //                       style: const TextStyle(
// // //                         color: Colors.white,
// // //                         fontSize: 20,
// // //                         fontWeight: FontWeight.bold
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   Expanded(
// // //                     child: isDriverAccepted
// // //                         ? ListView.builder(
// // //                             itemCount: driverRequests.length,
// // //                             padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                             itemBuilder: (context, index) {
// // //                               return Padding(
// // //                                 padding: const EdgeInsets.only(bottom: 16),
// // //                                 child: _buildDriverCard(driverRequests[index]),
// // //                               );
// // //                             },
// // //                           )
// // //                         : Center(
// // //                             child: Column(
// // //                               mainAxisAlignment: MainAxisAlignment.center,
// // //                               children: [
// // //                                 const CircularProgressIndicator(),
// // //                                 const SizedBox(height: 20),
// // //                                 Text(
// // //                                   isConnected
// // //                                       ? 'choose_driver.waiting_message'.tr()
// // //                                       : 'choose_driver.connecting'.tr(),
// // //                                   style: const TextStyle(color: Colors.white),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildDriverCard(Map<String, dynamic> tripDetails) {
// // //     final driver = tripDetails['driver'] ?? {};
// // //     final driverEstimatedFare = tripDetails['driverEstimatedFare'] ?? 0.0;
// // //     final tripId = tripDetails['_id'] ?? '';

// // //     return CustomDriverCard(
// // //       driverName: driver['username'] ?? 'choose_driver.unknown'.tr(),
// // //       driverRating: '${getStarRating(driver['ratingAverage'])} (${'choose_driver.trips'.tr(args: [(driver['tripsCount'] ?? 0).toString()])})',
// // //       driverImageUrl: driver['profilePicture'] ?? '',
// // //       price: driverEstimatedFare.toStringAsFixed(2),
// // //       arrivalTime: 'choose_driver.eta'.tr(
// // //         args: [tripDetails['driverToPickupInfo']?.split('|').last.trim() ?? 'choose_driver.calculating'.tr()]
// // //       ),
// // //       onAccept: () => acceptDriverOffer(tripId),
// // //       onDecline: () => declineDriverOffer(tripId),
// // //       tripId: tripId,
// // //       driverToPickupInfo: tripDetails['driverToPickupInfo'] ?? 'choose_driver.calculating'.tr(),
// // //     );
// // //   }

// // //   String getStarRating(dynamic rating) {
// // //     if (rating == null) return 'choose_driver.rating_na'.tr();
// // //     double numericRating = double.tryParse(rating.toString()) ?? 0;
// // //     int fullStars = numericRating.floor();
// // //     bool hasHalfStar = (numericRating - fullStars) >= 0.4;
// // //     String stars = '⭐' * fullStars + (hasHalfStar ? '½' : '');
// // //     return stars;
// // //   }
// // // }

// // import 'dart:async';
// // import 'dart:convert';
// // import 'dart:developer';

// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:provider/provider.dart';
// // import 'package:sendme/utils/constant/api_base_url.dart';
// // import 'package:sendme/utils/location_utils.dart';
// // import 'package:sendme/utils/routes/user_panel_routes.dart';
// // import 'package:sendme/utils/theme/app_colors.dart';
// // import 'package:sendme/utils/theme/app_text_theme.dart';
// // // import 'package:sendme/utils/theme/app_colors.dart';
// // // import 'package:sendme/utils/theme/app_text_theme.dart';

// // import 'package:sendme/viewmodel/provider/user_accept.dart';
// // // import 'package:sendme/views/User_panel/RideBookScreens/widgets/cancel_trip_screen.dart';

// // import 'package:sendme/views/User_panel/RideBookScreens/widgets/driver_request_card.dart';
// // // import 'package:sendme/widgets/custom_button.dart';

// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;

// // class ChooseDriverScreen extends StatefulWidget {
// //   final String tripId;

// //   const ChooseDriverScreen({Key? key, required this.tripId}) : super(key: key);

// //   @override
// //   _ChooseDriverScreenState createState() => _ChooseDriverScreenState();
// // }

// // class _ChooseDriverScreenState extends State<ChooseDriverScreen> {
// //   // SOCKET RELATED VARIABLES
// //   IO.Socket? socket;
// //   bool isConnected = false;

// //   // TRIP RELATED VARIABLES
// //   Map<String, dynamic> tripDetails = {};
// //   bool isDriverAccepted = false;

// //   // MAP RELATED VARIABLES
// //   String mapTheme = "";
// //   final Completer<GoogleMapController> _controller =
// //       Completer<GoogleMapController>();
// //   bool _isMapControllerInitialized = false;

// //   // AUTHENTICATION
// //   String? _token;

// //   // INITIAL CAMERA POSITION
// //   static const CameraPosition _kKarachi = CameraPosition(
// //     target: LatLng(24.8607, 67.0011),
// //     zoom: 14.4746,
// //   );

// //   @override
// //   void initState() {
// //     super.initState();
// //     log('ChooseDriverScreen - initState with tripId: ${widget.tripId}');
// //     _getToken();
// //     connectToSocket();
// //     loadMapTheme();
// //   }

// //   // FETCH USER TOKEN
// //   Future<void> _getToken() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       _token = prefs.getString('token');
// //     });
// //     log('Token retrieved: $_token');
// //   }

// //   // CONNECT TO SOCKET SERVER
// //   void connectToSocket() {
// //     log("ChooseDriverScreen - Attempting to connect to socket");
// //     socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
// //       'transports': ['websocket'],
// //       'autoConnect': false,
// //       'reconnection': true,
// //       'reconnectionAttempts': 5,
// //       'reconnectionDelay': 1000,
// //     });

// //     socket?.connect();

// //     // SOCKET EVENT LISTENERS
// //     socket?.onConnect((_) {
// //       log('ChooseDriverScreen - Socket connected successfully');
// //       if (mounted) {
// //         setState(() {
// //           isConnected = true;
// //         });
// //       }
// //       joinTripRoom();
// //     });

// //     // socket?.onDisconnect((_) {
// //     //   log('ChooseDriverScreen - Socket disconnected');
// //     //   if (mounted) {
// //     //     setState(() {
// //     //       isConnected = true;
// //     //     });
// //     //   }
// //     // });

// //     socket?.onConnectError(
// //         (err) => log('ChooseDriverScreen - Socket connect error: $err'));
// //     socket?.onError((err) => log('ChooseDriverScreen - Socket error: $err'));

// //     socket?.on('driver_accepted_trip', (data) {
// //       log('ChooseDriverScreen - Received driver_accepted_trip event: ${json.encode(data)}');
// //       handleDriverAccepted(data);
// //     });

// //     socket?.onAny((event, data) {
// //       log('ChooseDriverScreen - Received socket event: $event with data: ${json.encode(data)}');
// //     });

// //     log('ChooseDriverScreen - All socket event listeners set up');
// //   }

// //   // JOIN TRIP ROOM
// //   void joinTripRoom() {
// //     socket?.emit('join-room', widget.tripId);
// //     log('ChooseDriverScreen - Emitted join-room event for tripId: ${widget.tripId}');
// //   }

// //   // HANDLE DRIVER ACCEPTANCE
// //   void handleDriverAccepted(dynamic data) {
// //     log('ChooseDriverScreen - handleDriverAccepted called with data: ${json.encode(data)}');

// //     if (!mounted) {
// //       log('ChooseDriverScreen - Widget is no longer mounted. Skipping state update.');
// //       return;
// //     }

// //     setState(() {
// //       tripDetails = data;
// //       isDriverAccepted = true;
// //     });
// //     log("Updated trip details: $tripDetails");

// //     calculateDriverToPickupInfo();
// //   }

// //   // CALCULATE DRIVER TO PICKUP DISTANCE AND TIME
// //   Future<void> calculateDriverToPickupInfo() async {
// //     if (!mounted) {
// //       log('ChooseDriverScreen - Widget is no longer mounted. Skipping driver to pickup calculation.');
// //       return;
// //     }

// //     if (tripDetails['driverLocation'] != null &&
// //         tripDetails['pickup'] != null) {
// //       LatLng driverLatLng = LatLng(tripDetails['driverLocation']['latitude'],
// //           tripDetails['driverLocation']['longitude']);
// //       LatLng pickupLatLng = _parseLatLng(tripDetails['pickup']);

// //       Map<String, dynamic> info =
// //           await LocationUtils.calculateDriverToPickupDistanceAndTime(
// //               driverLatLng, pickupLatLng);

// //       if (mounted) {
// //         setState(() {
// //           tripDetails['driverToPickupInfo'] =
// //               "To pickup: ${info['distance']} | ${info['duration']}";
// //         });
// //         log("Updated driverToPickupInfo: ${tripDetails['driverToPickupInfo']}");
// //       } else {
// //         log('ChooseDriverScreen - Widget is no longer mounted after calculation. Skipping state update.');
// //       }
// //     }
// //   }

// //   // PARSE STRING TO LATLNG
// //   LatLng _parseLatLng(String latLngString) {
// //     List<String> parts = latLngString.split(',');
// //     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
// //   }

// //   // ACCEPT DRIVER OFFER
// //   Future<void> acceptDriverOffer(String tripId) async {
// //     log('ChooseDriverScreen - Accepting driver offer for trip: $tripId');
// //     if (!mounted) {
// //       log('ChooseDriverScreen - Widget is no longer mounted. Skipping accept driver offer.');
// //       return;
// //     }

// //     try {
// //       if (_token == null) {
// //         throw Exception('No token available');
// //       }

// //       final response = await http.put(
// //         Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
// //         headers: {
// //           'Content-Type': 'application/json',
// //           'Authorization': 'Bearer $_token',
// //         },
// //       );

// //       if (response.statusCode == 200) {
// //         final responseData = jsonDecode(response.body);
// //         log('User accept API response: $responseData');

// //         if (mounted) {
// //           // NAVIGATE TO SHOW RIDE DETAILS SCREEN
// //           Navigator.pushNamed(
// //             context,
// //             AppRoutes.rideDetails,
// //             arguments: {
// //               'tripDetails': responseData,
// //               'initialTripDetails': tripDetails
// //             },
// //           );
// //         }
// //       } else {
// //         throw Exception('Failed to accept trip: ${response.body}');
// //       }
// //     } catch (e) {
// //       log('ChooseDriverScreen - Error accepting driver offer: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //               content: Text('Failed to accept trip. Please try again.')),
// //         );
// //       }
// //     }
// //   }

// //   // DECLINE DRIVER OFFER
// //   void declineDriverOffer(String tripId) {
// //     log('ChooseDriverScreen - Declining driver offer for trip: $tripId');
// //     Provider.of<TripProvider>(context, listen: false).reset();
// //     socket?.emit('user_declined', {
// //       'tripId': tripId,
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     log('ChooseDriverScreen - dispose');
// //     socket?.off('driver_accepted_trip');
// //     socket?.disconnect();
// //     socket?.dispose();
// //     socket = null;
// //     super.dispose();
// //   }

// //   // LOAD MAP THEME
// //   void loadMapTheme() {
// //     DefaultAssetBundle.of(context)
// //         .loadString('assets/map_theme/night_theme.json')
// //         .then((value) {
// //       if (mounted) {
// //         setState(() {
// //           mapTheme = value;
// //         });
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // final screenWidth = MediaQuery.of(context).size.width;
// //     log('ChooseDriverScreen - build method called. isDriverAccepted: $isDriverAccepted');
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: _kKarachi,
// //             onMapCreated: (GoogleMapController controller) {
// //               if (!_isMapControllerInitialized) {
// //                 _controller.complete(controller);
// //                 _isMapControllerInitialized = true;
// //               }
// //               if (mapTheme.isNotEmpty) {
// //                 controller.setMapStyle(mapTheme);
// //               }
// //             },
// //           ),
// //           Align(
// //             alignment: Alignment.bottomCenter,
// //             child: Container(
// //               width: double.infinity,
// //               height: MediaQuery.of(context).size.height * 0.7,
// //               decoration: const BoxDecoration(
// //                 color: Colors.black,
// //                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //               ),
// //               child: Column(
// //                 children: [
// //                   Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Text(
// //                       isDriverAccepted
// //                           ? 'Driver Available'
// //                           : 'Waiting for Driver',
// //                       style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold),
// //                     ),
// //                   ),
// //                   isDriverAccepted
// //                       ? _buildDriverCard(tripDetails)
// //                       : Center(
// //                           child: Column(
// //                             mainAxisAlignment: MainAxisAlignment.center,
// //                             children: [
// //                               CircularProgressIndicator(),
// //                               SizedBox(height: 20),
// //                               Text(
// //                                 isConnected
// //                                     ? 'Waiting for driver...'
// //                                     : 'Connecting...',
// //                                 style: TextStyle(color: Colors.white),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                   Positioned(
// //                     top: 90,
// //                     bottom: 0,
// //                     left: 20,
// //                     right: 20,
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(16.0),
// //                       child: GestureDetector(
// //                         onTap: () {
// //                           // Navigator.push(
// //                           //   context,
// //                           //   MaterialPageRoute(
// //                           //     builder: (context) => CancelTripScreen(
// //                           //       tripDetails: tripDetails,
// //                           //       initialTripDetails: tripDetails,
// //                           //     ),
// //                           //   ),
// //                           // );
// //                         },
// //                         child: Container(
// //                           // width: screenWidth * 0.8,
// //                           height: 50,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.primary,
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               "CANCEL RIDE",
// //                               style: AppTextTheme.getLightTextTheme(context)
// //                                   .titleLarge,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // BUILD DRIVER CARD
// //   Widget _buildDriverCard(Map<String, dynamic> tripDetails) {
// //     final driver = tripDetails['driver'] ?? {};
// //     final driverEstimatedFare = tripDetails['driverEstimatedFare'] ?? 0.0;
// //     final tripId = tripDetails['_id'] ?? '';

// //     return CustomDriverCard(
// //       driverName: driver['username'] ?? 'Unknown',
// //       driverRating:
// //           '${getStarRating(driver['ratingAverage'])} (${driver['tripsCount'] ?? 0} trips)',
// //       driverImageUrl: driver['profilePicture'] ?? '',
// //       price: driverEstimatedFare.toStringAsFixed(2),
// //       arrivalTime:
// //           'ETA: ${tripDetails['driverToPickupInfo']?.split('|').last.trim() ?? 'Calculating...'}',
// //       onAccept: () => acceptDriverOffer(tripId),
// //       onDecline: () => declineDriverOffer(tripId),
// //       tripId: tripId,
// //       driverToPickupInfo: tripDetails['driverToPickupInfo'] ?? 'Calculating...',
// //     );
// //   }

// //   // GET STAR RATING
// //   String getStarRating(dynamic rating) {
// //     if (rating == null) return '⭐ N/A';
// //     double numericRating = double.tryParse(rating.toString()) ?? 0;
// //     int fullStars = numericRating.floor();
// //     bool hasHalfStar = (numericRating - fullStars) >= 0.4;
// //     String stars = '⭐' * fullStars + (hasHalfStar ? '½' : '');
// //     return stars;
// //   }
// // }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:sendme/utils/location_utils.dart';
// import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:sendme/utils/theme/app_colors.dart';
// import 'package:sendme/utils/theme/app_text_theme.dart';
// import 'package:sendme/views/User_panel/RideBookScreens/widgets/driver_request_card.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// // Models
// class DriverRequestTimer {
//   final String requestId;
//   final DateTime startTime;
//   Timer? timer;
//   double progress = 1.0;

//   DriverRequestTimer({required this.requestId}) : startTime = DateTime.now();
// }

// class ChooseDriverScreen extends StatefulWidget {
//   final String tripId;
//   const ChooseDriverScreen({Key? key, required this.tripId}) : super(key: key);

//   @override
//   _ChooseDriverScreenState createState() => _ChooseDriverScreenState();
// }

// class _ChooseDriverScreenState extends State<ChooseDriverScreen> {
//   // Socket Related Variables
//   IO.Socket? socket;
//   bool isConnected = false;

//   // Map Related Variables
//   String mapTheme = "";
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   bool _isMapControllerInitialized = false;

//   // Driver Request Related Variables
//   List<Map<String, dynamic>> driverRequests = [];
//   Map<String, DriverRequestTimer> requestTimers = {};
//   final int maxDriverRequests = 5;
//   final int requestTimeout = 30;

//   // Audio Related Variables
//   final AudioPlayer audioPlayer = AudioPlayer();
//   double notificationVolume = 1.0;
//   bool canVibrate = false;

//   // Authentication
//   String? _token;

//   // Initial Camera Position
//   static const CameraPosition _kInitialPosition = CameraPosition(
//     target: LatLng(24.8607, 67.0011),
//     zoom: 14.4746,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _initializeServices();
//   }

//   Future<void> _initializeServices() async {
//     await _getToken();
//     await _initializeAudioPlayer();
//     await _checkVibrationCapability();
//     connectToSocket();
//     loadMapTheme();
//   }

//   Future<void> _initializeAudioPlayer() async {
//     try {
//       await audioPlayer.setSource(AssetSource('sound/notification.mp3'));
//       await audioPlayer.setVolume(notificationVolume);
//     } catch (e) {
//       log('Error initializing audio player: $e');
//     }
//   }

//   Future<void> _checkVibrationCapability() async {
//     // canVibrate = await Vibrate.canVibrate;
//   }

//   Future<void> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _token = prefs.getString('token');
//     });
//   }

//   void connectToSocket() {
//     try {
//       socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
//         'transports': ['websocket'],
//         'autoConnect': false,
//         'reconnection': true,
//         'reconnectionAttempts': 5,
//         'reconnectionDelay': 1000,
//       });

//       socket?.connect();

//       socket?.onConnect((_) async {
//         log('Socket connected successfully');
//         // Use Future.delayed to avoid setState during build
//         if (mounted) {
//           await Future.microtask(() {
//             setState(() => isConnected = true);
//           });
//           joinTripRoom();
//         }
//       });

//       socket?.onDisconnect((_) async {
//         log('Socket disconnected');
//         // Use Future.delayed to avoid setState during build
//         if (mounted) {
//           await Future.microtask(() {
//             setState(() => isConnected = false);
//           });
//         }
//       });

//       socket?.on('driver_accepted_trip', (data) async {
//         // Handle driver acceptance in a separate async function
//         await handleDriverAcceptedEvent(data);
//       });

//       socket?.onError((err) => log('Socket error: $err'));
//       socket?.onConnectError((err) => log('Socket connect error: $err'));
//     } catch (e) {
//       log('Error connecting to socket: $e');
//     }
//   }

//   // Separate function to handle driver acceptance
//   Future<void> handleDriverAcceptedEvent(dynamic data) async {
//     if (!mounted) return;

//     try {
//       await Future.microtask(() {
//         setState(() {
//           if (driverRequests.length < maxDriverRequests) {
//             bool driverExists = driverRequests.any((request) =>
//                 request['driver']?['_id'] == data['driver']?['_id']);

//             if (!driverExists) {
//               _playNotification();
//               driverRequests.add(data);
//               String requestId = data['_id'];
//               initializeRequestTimer(requestId);
//               calculateDriverToPickupInfo(data, driverRequests.length - 1);
//             }
//           }
//         });
//       });
//     } catch (e) {
//       log('Error handling driver acceptance: $e');
//     }
//   }

//   // Timer initialization with better error handling
//   void initializeRequestTimer(String requestId) {
//     try {
//       DriverRequestTimer requestTimer =
//           DriverRequestTimer(requestId: requestId);
//       requestTimers[requestId] = requestTimer;

//       const updateInterval = Duration(milliseconds: 100);
//       requestTimer.timer = Timer.periodic(updateInterval, (timer) async {
//         if (!mounted) {
//           timer.cancel();
//           return;
//         }

//         final elapsedSeconds =
//             DateTime.now().difference(requestTimer.startTime).inMilliseconds /
//                 1000;

//         if (elapsedSeconds >= requestTimeout) {
//           await removeRequest(requestId);
//           timer.cancel();
//         } else {
//           if (mounted) {
//             await Future.microtask(() {
//               setState(() {
//                 requestTimer.progress = 1.0 - (elapsedSeconds / requestTimeout);
//               });
//             });
//           }
//         }
//       });
//     } catch (e) {
//       log('Error initializing timer: $e');
//     }
//   }

//   // Make removeRequest async
//   Future<void> removeRequest(String requestId) async {
//     if (!mounted) return;

//     try {
//       await Future.microtask(() {
//         setState(() {
//           driverRequests.removeWhere((request) => request['_id'] == requestId);
//           requestTimers[requestId]?.timer?.cancel();
//           requestTimers.remove(requestId);
//         });
//       });
//     } catch (e) {
//       log('Error removing request: $e');
//     }
//   }

//   // Better cleanup in dispose
//   @override
//   void dispose() {
//     try {
//       // Cancel all timers
//       for (var timer in requestTimers.values) {
//         timer.timer?.cancel();
//       }
//       requestTimers.clear();

//       // Clean socket connection
//       socket?.clearListeners();
//       socket?.dispose();
//       socket = null;

//       // Dispose audio player
//       audioPlayer.dispose();
//     } catch (e) {
//       log('Error in dispose: $e');
//     }

//     super.dispose();
//   }

//   void joinTripRoom() {
//     socket?.emit('join-room', widget.tripId);
//   }

//   void handleDriverAccepted(dynamic data) {
//     if (!mounted) return;

//     try {
//       setState(() {
//         if (driverRequests.length < maxDriverRequests) {
//           bool driverExists = driverRequests.any(
//               (request) => request['driver']?['_id'] == data['driver']?['_id']);

//           if (!driverExists) {
//             _playNotification();
//             driverRequests.add(data);
//             String requestId = data['_id'];
//             initializeRequestTimer(requestId);
//             calculateDriverToPickupInfo(data, driverRequests.length - 1);
//           }
//         }
//       });
//     } catch (e) {
//       log('Error handling driver acceptance: $e');
//     }
//   }

//   void _playNotification() async {
//     try {
//       await audioPlayer.play(AssetSource('sound/notifications.wav'));
//       if (canVibrate) {
//         // Vibrate.feedback(FeedbackType.success);
//       }
//     } catch (e) {
//       log('Error playing notification: $e');
//     }
//   }

//   Future<void> calculateDriverToPickupInfo(
//       Map<String, dynamic> driverData, int index) async {
//     if (!mounted) return;

//     try {
//       if (driverData['driverLocation'] != null &&
//           driverData['pickup'] != null) {
//         LatLng driverLatLng = LatLng(driverData['driverLocation']['latitude'],
//             driverData['driverLocation']['longitude']);
//         LatLng pickupLatLng = _parseLatLng(driverData['pickup']);

//         Map<String, dynamic> info =
//             await LocationUtils.calculateDriverToPickupDistanceAndTime(
//                 driverLatLng, pickupLatLng);

//         if (mounted) {
//           setState(() {
//             driverRequests[index]['driverToPickupInfo'] =
//                 "To pickup: ${info['distance']} | ${info['duration']}";
//           });
//         }
//       }
//     } catch (e) {
//       log('Error calculating pickup info: $e');
//     }
//   }

//   LatLng _parseLatLng(String latLngString) {
//     List<String> parts = latLngString.split(',');
//     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
//   }

//   Future<void> acceptDriverOffer(String tripId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/$tripId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);

//         socket?.emit('user_accepted_other_driver', {
//           'tripId': tripId,
//           'driverIds': driverRequests
//               .where((req) => req['_id'] != tripId)
//               .map((req) => req['driver']?['_id'])
//               .toList(),
//         });

//         if (mounted) {
//           Navigator.pushNamed(
//             context,
//             AppRoutes.rideDetails,
//             arguments: {
//               'tripDetails': responseData,
//               'initialTripDetails':
//                   driverRequests.firstWhere((req) => req['_id'] == tripId),
//             },
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Failed to accept trip. Please try again.')),
//         );
//       }
//     }
//   }

//   void declineDriverOffer(String tripId, int index) {
//     removeRequest(tripId);
//     socket?.emit('user_declined', {'tripId': tripId});
//   }

//   Color _getProgressColor(double progress) {
//     if (progress > 0.6) return Colors.green;
//     if (progress > 0.3) return Colors.orange;
//     return Colors.red;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _kInitialPosition,
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
//           _buildDriverRequestsPanel(),
//         ],
//       ),
//     );
//   }

//   // Update the main container dimensions
//   Widget _buildDriverRequestsPanel() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         height: MediaQuery.of(context).size.height * 0.75, // Increased height
//         decoration: const BoxDecoration(
//           color: AppColors.backgroundLight,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 10,
//               offset: Offset(0, -5),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Add drag indicator
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             _buildPanelHeader(),
//             Expanded(
//               child: driverRequests.isEmpty
//                   ? _buildWaitingWidget()
//                   : _buildDriverList(),
//             ),
//             _buildCancelButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPanelHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             '  Available Drivers (${driverRequests.length})',
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           if (driverRequests.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.sort, color: Colors.black),
//               onPressed: _showSortOptions,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDriverList() {
//     return ListView.builder(
//       itemCount: driverRequests.length,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemBuilder: (context, index) {
//         final tripDetails = driverRequests[index];
//         final requestId = tripDetails['_id'];
//         final timerInfo = requestTimers[requestId];

//         return _buildDriverCard(tripDetails, timerInfo);
//       },
//     );
//   }

//   Widget _buildDriverCard(
//       Map<String, dynamic> tripDetails, DriverRequestTimer? timerInfo) {
//     return CustomDriverCard(
//       driverName: tripDetails['driver']?['username'] ?? 'Unknown',
//       driverRating: getStarRating(tripDetails['driver']?['ratingAverage']),
//       driverImageUrl: tripDetails['driver']?['profilePicture'] ?? '',
//       price: (tripDetails['driverEstimatedFare'] ?? 0.0).toStringAsFixed(2),
//       arrivalTime: tripDetails['driverToPickupInfo']?.split('|').last.trim() ??
//           'Calculating...',
//       onAccept: () => acceptDriverOffer(tripDetails['_id']),
//       onDecline: () => declineDriverOffer(tripDetails['_id'],
//           driverRequests.indexWhere((req) => req['_id'] == tripDetails['_id'])),
//       tripId: tripDetails['_id'],
//       driverToPickupInfo: tripDetails['driverToPickupInfo'] ?? 'Calculating...',
//       timerProgress: timerInfo?.progress,
//     );
//   }

//   Widget _buildDriverInfo(
//       Map<String, dynamic> tripDetails, DriverRequestTimer? timerInfo) {
//     final driver = tripDetails['driver'] ?? {};
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundImage: NetworkImage(driver['profilePicture'] ?? ''),
//         radius: 25,
//       ),
//       title: Text(
//         driver['username'] ?? 'Unknown',
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(getStarRating(driver['ratingAverage'])),
//           Text(
//             tripDetails['driverToPickupInfo'] ?? 'Calculating...',
//             style: const TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             '\$${(tripDetails['driverEstimatedFare'] ?? 0.0).toStringAsFixed(2)}',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: Colors.green,
//             ),
//           ),
//           if (timerInfo != null)
//             Text(
//               '${(timerInfo.progress * requestTimeout).toStringAsFixed(0)}s',
//               style: TextStyle(
//                 color: _getProgressColor(timerInfo.progress),
//                 fontSize: 12,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(Map<String, dynamic> tripDetails) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         TextButton(
//           onPressed: () => declineDriverOffer(
//               tripDetails['_id'],
//               driverRequests
//                   .indexWhere((req) => req['_id'] == tripDetails['_id'])),
//           child: const Text('Decline', style: TextStyle(color: Colors.red)),
//         ),
//         ElevatedButton(
//           onPressed: () => acceptDriverOffer(tripDetails['_id']),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//           child: const Text('Accept'),
//         ),
//       ],
//     );
//   }

//   Widget _buildWaitingWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(color: Colors.black),
//           const SizedBox(height: 20),
//           Text(
//             isConnected ? 'Waiting for drivers...' : 'Connecting...',
//             style: const TextStyle(color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCancelButton() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: GestureDetector(
//         onTap: () async {
//           try {
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.clear();
//             log('SharedPreferences data cleared successfully');
//             if (context.mounted) {
//               Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
//             }
//           } catch (e) {
//             log('Error clearing SharedPreferences: $e');
//             if (context.mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Error clearing data'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             }
//           }
//         },
//         child: Container(
//           height: 50,
//           decoration: BoxDecoration(
//             color: AppColors.buttonColor,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Center(
//             child: Text(
//               "CANCEL RIDE",
//               style: AppTextTheme.getLightTextTheme(context).titleLarge,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSortOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.attach_money),
//               title: const Text('Sort by Price'),
//               onTap: () {
//                 _sortDrivers('price');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.star),
//               title: const Text('Sort by Rating'),
//               onTap: () {
//                 _sortDrivers('rating');
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.timer),
//               title: const Text('Sort by Time Remaining'),
//               onTap: () {
//                 _sortDrivers('time');
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _sortDrivers(String criteria) {
//     setState(() {
//       switch (criteria) {
//         case 'price':
//           driverRequests.sort((a, b) => (a['driverEstimatedFare'] ?? 0.0)
//               .compareTo(b['driverEstimatedFare'] ?? 0.0));
//           break;
//         case 'rating':
//           driverRequests.sort((a, b) => (b['driver']?['ratingAverage'] ?? 0.0)
//               .compareTo(a['driver']?['ratingAverage'] ?? 0.0));
//           break;
//         case 'time':
//           driverRequests.sort((a, b) {
//             final aTimer = requestTimers[a['_id']]?.progress ?? 0;
//             final bTimer = requestTimers[b['_id']]?.progress ?? 0;
//             return bTimer.compareTo(aTimer);
//           });
//           break;
//       }
//     });
//   }



//   String getStarRating(dynamic rating) {
//     if (rating == null) return '⭐ N/A';
//     double numericRating = double.tryParse(rating.toString()) ?? 0;
//     int fullStars = numericRating.floor();
//     bool hasHalfStar = (numericRating - fullStars) >= 0.4;
//     String stars = '⭐' * fullStars + (hasHalfStar ? '½' : '');
//     return stars;
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



//   // Error Handling Methods
//   void _handleError(String message) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//         action: SnackBarAction(
//           label: 'Dismiss',
//           onPressed: () {},
//           textColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   // Network Connectivity Check
//   Future<bool> _checkConnectivity() async {
//     try {
//       final result = await InternetAddress.lookup('google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }
// }

// // Add these styles to your theme file
// class AppStyles {
//   static final cardDecoration = BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(12),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.1),
//         blurRadius: 8,
//         offset: const Offset(0, 4),
//       ),
//     ],
//   );

//   static final buttonStyle = ElevatedButton.styleFrom(
//     backgroundColor: Colors.green,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(20),
//     ),
//     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//   );
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
  bool _isLocationInitialized = false;

  // Map Related Variables
  String mapTheme = "";
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool _isMapControllerInitialized = false;
  bool _hasMovedToUserLocation = false;

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

  // Initial Map Position (Mexico City)
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
    await _initializeAudioPlayer();
    await _checkVibrationCapability();
    await _getCurrentLocation();

    if (socket == null || !socket!.connected) {
      connectToSocket();
    }

    loadMapTheme();
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

    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);

      if (!hasConnection) {
        _handleNoInternet();
      } else {
        setState(() => isInternetConnected = true);
      }
    } catch (e) {
      log('Error checking initial connectivity: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLocationInitialized) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        myLocationEnabled = true;
        _isLocationInitialized = true;
      });

      if (_isMapControllerInitialized && !_hasMovedToUserLocation) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
        setState(() {
          _hasMovedToUserLocation = true;
        });
      }
    } catch (e) {
      log('Error getting location: $e');
    }
  }

  void connectToSocket() {
    try {
      if (socket == null || socket?.disconnected == true) {
        socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
          'reconnection': true,
          'reconnectionAttempts': 5,
          'reconnectionDelay': 1000,
        });
      }

      socket?.connect();

      socket?.onConnect((_) {
        log('Socket connected successfully');
        if (mounted) {
          setState(() => isConnected = true);
        }
      });

      socket?.onDisconnect((_) {
        log('Socket disconnected');
        if (mounted) {
          setState(() => isConnected = false);
        }
      });

      socket?.on('driver_accepted_trip', (data) async {
        log('Driver accepted trip event received: $data');
        await handleDriverAcceptedEvent(data);
      });

      socket?.onError((err) => log('Socket error: $err'));
      socket?.onConnectError((err) => log('Socket connect error: $err'));
    } catch (e) {
      log('Error connecting to socket: $e');
    }
  }

  Future<void> handleDriverAcceptedEvent(dynamic data) async {
  if (!mounted) return;

  try {
    if (data == null) {
      log('Received null data in driver accepted event');
      return;
    }

    String driverUsername = data['driver']?['user']?['username'] ?? 'unknown_driver'.tr();

    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/trip/user-accept/${data['_id']}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      await _notificationService.showNotification(
        title: 'trip_request_accepted'.tr(),
        body: 'driver_accepted_trip'.tr(args: [driverUsername]),
        // payload: data.toString(),
      );

      socket?.emit('user_accepted_other_driver', {
        'tripId': data['_id'],
        'driverIds': [],
      });

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.rideDetails,
          arguments: {
            'tripDetails': responseData,
            'initialTripDetails': data,
          },
        );
      }

      _playNotification();
    }
  } catch (e) {
    log('Error handling driver accepted event: $e');
    _handleError('failed_to_accept_trip'.tr());
  }
}


  Future<void> _cancelTrip() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final tripId = widget.tripId;
    final token = prefs.getString('token');

    log('Attempting to cancel trip ID: $tripId');

    if (token == null) {
      _handleError('missing_token'.tr());
      return;
    }

    final bool? shouldCancel = await _showCancelConfirmationDialog();
    if (shouldCancel != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
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
      ),
    );

    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/trip/cancel-pending-trip/$tripId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (response.statusCode == 200) {
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
      String errorMessage;
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'failed_to_cancel_trip'.tr();
      } catch (e) {
        errorMessage = response.statusCode == 404
            ? 'trip_not_found'.tr()
            : 'failed_to_cancel_trip'.tr();
      }
      _handleError(errorMessage);
    }
  } catch (e) {
    log('Error in _cancelTrip: $e');
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    _handleError('failed_to_cancel_trip'.tr());
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


// Will Pop Function
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

// Handle Error Function
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





  // Future<bool> _onWillPop() async {
  //   if (lastBackPressTime == null ||
  //       DateTime.now().difference(lastBackPressTime!) >
  //           const Duration(seconds: 2)) {
  //     setState(() => lastBackPressTime = DateTime.now());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(('tap_again_to_close'.tr())),
  //         duration: const Duration(seconds: 2),
  //       ),
  //     );
  //     return false;
  //   }
  //   await SystemNavigator.pop();
  //   return true;
  // }

  Future<void> _initializeAudioPlayer() async {
    try {
      await audioPlayer.setSource(AssetSource('sound/notification.wav'));
      await audioPlayer.setVolume(notificationVolume);
    } catch (e) {
      log('Error initializing audio player: $e');
    }
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

  // void _handleError(String messageKey) {
  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(tr(messageKey)),
  //       backgroundColor: Colors.red,
  //       duration: const Duration(seconds: 3),
  //       action: SnackBarAction(
  //         label: 'Dismiss',
  //         onPressed: () {},
  //         textColor: Colors.white,
  //       ),
  //     ),
  //   );
  // }

  // void _handleNoInternet() {
  //   if (isInternetConnected) {
  //     setState(() => isInternetConnected = false);
  //     _showNoInternetSnackBar();
  //   }
  // }

  // void _showNoInternetSnackBar() {
  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(tr('no_internet_connection')),
  //       duration: const Duration(days: 365),
  //       backgroundColor: Colors.red,
  //       action: SnackBarAction(
  //         label: ('retry'.tr()),
  //         onPressed: _checkInternetConnection,
  //         textColor: Colors.white,
  //       ),
  //     ),
  //   );
  // }

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

  @override
  void dispose() {
    // Reset state flags
    _isLocationInitialized = false;
    _hasMovedToUserLocation = false;

    // Clean up socket listeners
    socket?.off('driver_accepted_trip');
    socket?.off('connect');
    socket?.off('disconnect');
    socket?.off('error');
    socket?.off('connect_error');

    // Disconnect socket
    socket?.disconnect();
    socket = null;

    // Dispose map controller
    if (_isMapControllerInitialized) {
      _controller.future.then((controller) => controller.dispose());
    }

    // Dispose audio player
    audioPlayer.dispose();

    // Clean up connectivity subscription
    connectivitySubscription?.cancel();
    connectivityTimer?.cancel();

    super.dispose();
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

          // No internet connection indicator
          if (!isInternetConnected)
            Positioned(
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
            ),

          // Cancel trip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FloatingActionButton(
              onPressed: _cancelTrip,
              backgroundColor: Colors.red,
              mini: true,
              child: const Icon(Icons.close),
            ),
          ),

          // Loading indicators
          if (isConnected)
            const Center(
              child: CircularProgressIndicator(color: Colors.black),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'choose_driver.connecting'.tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(color: Colors.black),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}






}
