// import 'dart:developer';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:rideapp/utils/constant/api_base_url.dart';
// import 'package:rideapp/utils/routes/user_panel_routes.dart';
// import 'package:rideapp/utils/theme/app_colors.dart';
// import 'package:rideapp/utils/theme/app_text_theme.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/widgets/cancel_trip_screen.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/widgets/driver_contact_card.dart';
// import 'package:rideapp/utils/location_utils.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ShowRiderDetails extends StatefulWidget {
//   final Map<String, dynamic> tripDetails;
//   final Map<String, dynamic> initialTripDetails;

//   const ShowRiderDetails(
//       {Key? key, required this.tripDetails, required this.initialTripDetails})
//       : super(key: key);

//   @override
//   _ShowRiderDetailsState createState() => _ShowRiderDetailsState();
// }

// class _ShowRiderDetailsState extends State<ShowRiderDetails> {
//   String mapTheme = "";
//   late GoogleMapController mapController;
//   final DraggableScrollableController _sheetController =
//       DraggableScrollableController();
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   late IO.Socket socket;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSocket();
//  // Store driver ID in SharedPreferences
//   _storeDriverId();
//     log('ShowRiderDetails - initState');
//     log('Received tripDetails: ${widget.tripDetails}');
//     log('Received initialTripDetails: ${widget.initialTripDetails}');
//     _setUpMarkersAndPolylines();
//     DefaultAssetBundle.of(context)
//         .loadString('assets/map_theme/night_theme.json')
//         .then((value) {
//       mapTheme = value;
//     });
//     _sheetController.addListener(_onSheetChanged);
//   }

//   void _initializeSocket() {
//     socket = IO.io('${Constants.apiBaseUrl}', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();
//     socket.on('connect', (_) {
//       log('Connected to socket server');
//     });

//     socket.on('driver_location_updated', (data) {
//       log('Received driver location update: $data');
//       _updateDriverMarker(data['latitude'], data['longitude']);
//     });
//   }

//   Future<void> _storeDriverId() async {
//   try {
//     // Log the received data
//     log('Storing driver ID from initialTripDetails...');
//     final driverId = widget.initialTripDetails['driver']?['_id'];
//     final userId = widget.tripDetails['passenger']?['_id'];
//     log('Driver ID to store: $driverId');
//     log('User ID to store: $userId');

//     if (driverId != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('driverId', driverId);
//       log('Successfully stored driver ID in SharedPreferences: $driverId');
//     } else {
//       log('Error: Driver ID is null in initialTripDetails');
//     }
//   } catch (e) {
//     log('Error storing driver ID: $e');
//   }
// }

//   void _updateDriverMarker(double latitude, double longitude) {
//     LatLng newDriverLocation = LatLng(latitude, longitude);
//     setState(() {
//       _markers.removeWhere((marker) => marker.markerId.value == 'driver');
//       _markers.add(Marker(
//         markerId: const MarkerId('driver'),
//         position: newDriverLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       ));
//     });

//     _updateDriverToPickupPolyline(newDriverLocation);
//     _updateCameraPosition();
//   }

//   void _updateCameraPosition() {
//     List<LatLng> points = _markers.map((marker) => marker.position).toList();
//     LatLngBounds bounds = LocationUtils.calculateBounds(points);
//     mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   }

//   void _showTripCompletionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'ride_tracker.trip_completed'.tr(),
//           style: AppTextTheme.getLightTextTheme(context).headlineMedium,
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'ride_tracker.confirm_payment_message'.tr(),
//               style: AppTextTheme.getLightTextTheme(context).bodyLarge,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'ride_tracker.total_fare'.tr(args: [
//                 widget.initialTripDetails['driverEstimatedFare']
//                         ?.toStringAsFixed(2) ??
//                     '0.00'
//               ]),
//               style: AppTextTheme.getLightTextTheme(context).headlineLarge,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _confirmPayment();
//             },
//             child: Text('ride_tracker.confirm_payment'.tr()),
//           ),
//         ],
//       ),
//     );
//   }

//   void _confirmPayment() {
//     socket.emit('payment_confirmed', {
//       'tripId': widget.tripDetails['tripDetails']['_id'],
//       'amount': widget.initialTripDetails['driverEstimatedFare'],
//       'paymentMethod': 'CASH'
//     });
//   }

//   void _navigateToRating() {
//     if (!mounted) return;
//     Navigator.pushReplacementNamed(context, AppRoutes.paymentMethod);
//   }

//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message.tr()),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _setUpMarkersAndPolylines() async {
//     log('ShowRiderDetails - Setting up markers and polylines');
//     final pickup = _parseLatLng(widget.initialTripDetails['pickup']);
//     final destination = _parseLatLng(widget.initialTripDetails['destination']);
//     final driverLocation = LatLng(
//         widget.initialTripDetails['driverLocation']['latitude'],
//         widget.initialTripDetails['driverLocation']['longitude']);

//     log('Pickup location: $pickup');
//     log('Destination location: $destination');
//     log('Driver location: $driverLocation');

//     setState(() {
//       _markers.add(Marker(
//         markerId: const MarkerId('pickup'),
//         position: pickup,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       ));
//       _markers.add(Marker(
//         markerId: const MarkerId('destination'),
//         position: destination,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ));
//       _markers.add(Marker(
//         markerId: const MarkerId('driver'),
//         position: driverLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       ));
//     });
//     log('Markers added: $_markers');

//     // Get polyline between driver and pickup
//     List<LatLng> driverToPickupPoints =
//         await LocationUtils.getPolylinePoints(driverLocation, pickup);
//     _addPolyline(driverToPickupPoints, Colors.blue, 'driver_to_pickup');
//     log('Driver to pickup polyline added');

//     // Get polyline between pickup and destination
//     List<LatLng> pickupToDestinationPoints =
//         await LocationUtils.getPolylinePoints(pickup, destination);
//     _addPolyline(
//         pickupToDestinationPoints, Colors.red, 'pickup_to_destination');
//     log('Pickup to destination polyline added');

//     // Calculate and set bounds
//     List<LatLng> allPoints = [driverLocation, pickup, destination];
//     LatLngBounds bounds = LocationUtils.calculateBounds(allPoints);
//     mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//     log('Camera bounds set');
//   }

//   void _addPolyline(List<LatLng> points, Color color, String id) {
//     setState(() {
//       _polylines.add(Polyline(
//         polylineId: PolylineId(id),
//         color: color,
//         points: points,
//         width: 3,
//       ));
//     });
//     log('Polyline added: $id');
//   }

//   void _updateDriverToPickupPolyline(LatLng driverLocation) async {
//     LatLng pickup =
//         _markers.firstWhere((m) => m.markerId.value == 'pickup').position;
//     List<LatLng> driverToPickupPoints =
//         await LocationUtils.getPolylinePoints(driverLocation, pickup);

//     setState(() {
//       _polylines.removeWhere(
//           (polyline) => polyline.polylineId.value == 'driver_to_pickup');
//       _addPolyline(driverToPickupPoints, Colors.blue, 'driver_to_pickup');
//     });
//   }

//   LatLng _parseLatLng(String latLngString) {
//     List<String> parts = latLngString.split(',');
//     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
//   }

//   void _onSheetChanged() {
//     if (_sheetController.size <= 0.05) {
//       _sheetController.animateTo(
//         60 / MediaQuery.of(context).size.height,
//         duration: const Duration(milliseconds: 50),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _sheetController.removeListener(_onSheetChanged);
//     _sheetController.dispose();
//     socket.disconnect();
//     log('ShowRiderDetails - dispose');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     log('ShowRiderDetails - build method called');
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Extract passenger ID correctly from nested structure
//     final passengerId = widget.tripDetails['tripDetails']?['tripDetails']
//             ?['passenger']?['_id'] ??
//         'null';
//     final driverId =
//         widget.initialTripDetails['driver']?['userid']?['_id'] ?? 'null';
//     final driverPhone =
//         widget.initialTripDetails['driver']?['userid']?['phone'] ?? 'null';

//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _parseLatLng(widget.initialTripDetails['pickup']),
//               zoom: 14,
//             ),
//             onMapCreated: (GoogleMapController controller) {
//               log('GoogleMap created');
//               mapController = controller;
//               if (mapTheme.isNotEmpty) {
//                 controller.setMapStyle(mapTheme);
//               }
//               _setUpMarkersAndPolylines();
//             },
//             markers: _markers,
//             polylines: _polylines,
//           ),
//           DraggableScrollableSheet(
//             initialChildSize: 0.5,
//             minChildSize: 0,
//             maxChildSize: 0.95,
//             snapSizes: [60 / screenHeight, 0.6],
//             snap: true,
//             controller: _sheetController,
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 50,
//                         height: 5,
//                         margin: const EdgeInsets.symmetric(vertical: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[600],
//                           borderRadius: BorderRadius.circular(5),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Center(
//                               child: Text(
//                                 'Your ride is arriving',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             Center(
//                               child: Text(
//                                 widget.initialTripDetails[
//                                         'driverToPickupInfo'] ??
//                                     '',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             DriverContactCard(
//                               driverName: widget.initialTripDetails['driver']
//                                       ['username'] ??
//                                   "Unknown",
//                               driverRating:
//                                   "${widget.initialTripDetails['driver']['ratingAverage'] ?? 'N/A'} (${widget.initialTripDetails['driver']['tripsCount'] ?? 0} Trips)",
//                               driverImageUrl:
//                                   widget.initialTripDetails['driver']
//                                           ['profilePicture'] ??
//                                       "",
//                               driverBikename: "Unknown",
//                               userId: passengerId,
//                               driverId: driverId,
//                               phoneNumber: driverPhone,
//                             ),
//                             const SizedBox(height: 20),
//                             Text(
//                               "Payment",
//                               style: AppTextTheme.getDarkTextTheme(context)
//                                   .headlineMedium,
//                             ),
//                             const SizedBox(height: 10),
//                             Container(
//                               width: double.infinity,
//                               height: 90,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   Image.asset(
//                                     "assets/images/cash.png",
//                                     scale: 1.0,
//                                     width: 55,
//                                     height: 55,
//                                   ),
//                                   Text(
//                                     "Cash",
//                                     style:
//                                         AppTextTheme.getLightTextTheme(context)
//                                             .headlineMedium,
//                                   ),
//                                   const SizedBox(height: 15),
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         "${widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00'}",
//                                         style: AppTextTheme.getLightTextTheme(
//                                                 context)
//                                             .headlineLarge,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 40),
//                             Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             UserCancelTripScreen(
//                                           tripDetails: widget.tripDetails,
//                                           initialTripDetails:
//                                               widget.initialTripDetails,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     width: screenWidth * 0.4,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       color: AppColors.primary,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         "CANCEL RIDE",
//                                         style: AppTextTheme.getLightTextTheme(
//                                                 context)
//                                             .titleLarge,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.pushReplacementNamed(
//                                         context, AppRoutes.paymentMethod,
//                                         arguments: {
//                                           'estimatedFare': widget
//                                                   .initialTripDetails[
//                                                       'driverEstimatedFare']
//                                                   ?.toStringAsFixed(2) ??
//                                               '0.00'
//                                         });
//                                   },
//                                   child: Container(
//                                     width: screenWidth * 0.4,
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: AppColors.primary,
//                                         width: 2.0,
//                                       ),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Center(
//                                       child: Text(
//                                         "END RIDE",
//                                         style: TextStyle(
//                                           color: AppColors.primary,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }




// // import 'dart:developer';
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:rideapp/utils/constant/api_base_url.dart';
// // import 'package:rideapp/utils/routes/user_panel_routes.dart';
// // import 'package:rideapp/utils/theme/app_colors.dart';
// // import 'package:rideapp/utils/theme/app_text_theme.dart';
// // import 'package:rideapp/views/User_panel/RideBookScreens/widgets/cancel_trip_screen.dart';
// // import 'package:rideapp/views/User_panel/RideBookScreens/widgets/driver_contact_card.dart';
// // import 'package:rideapp/utils/location_utils.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // class ShowRiderDetails extends StatefulWidget {
// //   final Map<String, dynamic> tripDetails;
// //   final Map<String, dynamic> initialTripDetails;

// //   const ShowRiderDetails({
// //     Key? key, 
// //     required this.tripDetails, 
// //     required this.initialTripDetails
// //   }) : super(key: key);

// //   @override
// //   _ShowRiderDetailsState createState() => _ShowRiderDetailsState();
// // }

// // class _ShowRiderDetailsState extends State<ShowRiderDetails> {
// //   String mapTheme = "";
// //   late GoogleMapController mapController;
// //   final DraggableScrollableController _sheetController = DraggableScrollableController();
// //   Set<Marker> _markers = {};
// //   Set<Polyline> _polylines = {};
// //   late IO.Socket socket;
// //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //   String tripStatus = 'WAITING'; // WAITING, STARTED, ARRIVED, COMPLETED
// //   bool isPaymentPending = false;
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeNotifications();
// //     _initializeSocket();
// //     _setUpMarkersAndPolylines();
// //     _loadMapTheme();
// //     _sheetController.addListener(_onSheetChanged);
// //   }

// //   void _loadMapTheme() {
// //     DefaultAssetBundle.of(context)
// //         .loadString('assets/map_theme/night_theme.json')
// //         .then((value) {
// //       mapTheme = value;
// //       if (mounted) {
// //         mapController.setMapStyle(mapTheme);
// //       }
// //     });
// //   }

// //   Future<void> _initializeNotifications() async {
// //     const AndroidInitializationSettings initializationSettingsAndroid =
// //         AndroidInitializationSettings('@mipmap/ic_launcher');
        
// //     const DarwinInitializationSettings initializationSettingsIOS =
// //         DarwinInitializationSettings(
// //           requestSoundPermission: true,
// //           requestBadgePermission: true,
// //           requestAlertPermission: true,
// //         );

// //     const InitializationSettings initializationSettings = InitializationSettings(
// //       android: initializationSettingsAndroid,
// //       iOS: initializationSettingsIOS,
// //     );

// //     await flutterLocalNotificationsPlugin.initialize(
// //       initializationSettings,
// //       onDidReceiveNotificationResponse: _handleNotificationTap,
// //     );
// //   }

// //   void _handleNotificationTap(NotificationResponse response) {
// //     // Bring app to foreground if needed
// //     if (!mounted) return;
    
// //     Navigator.of(context).popUntil((route) => route.isFirst);
// //     Navigator.of(context).push(
// //       MaterialPageRoute(
// //         builder: (_) => ShowRiderDetails(
// //           tripDetails: widget.tripDetails,
// //           initialTripDetails: widget.initialTripDetails,
// //         ),
// //       ),
// //     );
// //   }

// //   // void _showNotification(String title, String body) async {
// //   //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
// //   //       AndroidNotificationDetails(
// //   //     'trip_updates',
// //   //     'Trip Updates',
// //   //     channelDescription: 'ride_tracker.trip_updates_description',
// //   //     importance: Importance.max,
// //   //     priority: Priority.high,
// //   //     enableVibration: true,
// //   //     playSound: true,
// //   //     color: AppColors.primary,
// //   //     icon: '@mipmap/ic_launcher',
// //   //   );

// //   //   // const IOSNotificationDetails iOSPlatformChannelSpecifics =
// //   //   //     IOSNotificationDetails(
// //   //   //       presentAlert: true,
// //   //   //       presentBadge: true,
// //   //   //       presentSound: true,
// //   //   //     );

// //   //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
// //   //     android: androidPlatformChannelSpecifics,
// //   //     iOS: iOSPlatformChannelSpecifics,
// //   //   );

// //   //   await flutterLocalNotificationsPlugin.show(
// //   //     0,
// //   //     title.tr(),
// //   //     body.tr(),
// //   //     platformChannelSpecifics,
// //   //   );
// //   // }

// //   void _initializeSocket() {
// //     socket = IO.io('${Constants.apiBaseUrl}', <String, dynamic>{
// //       'transports': ['websocket'],
// //       'autoConnect': false,
// //       'reconnection': true,
// //       'reconnectionAttempts': 5,
// //       'reconnectionDelay': 1000,
// //     });

// //     _setupSocketListeners();
// //     socket.connect();
// //   }

// //   void _setupSocketListeners() {
// //     socket.on('connect', (_) {
// //       log('ride_tracker.socket_connected'.tr());
// //       _joinTripRoom();
// //     });

// //     socket.on('reconnect', (_) {
// //       log('ride_tracker.socket_reconnected'.tr());
// //       _joinTripRoom();
// //     });

// //     socket.on('driver_location_updated', _handleDriverLocationUpdate);
// //     socket.on('driver_near_pickup', _handleDriverNearPickup);
// //     socket.on('driver_arrived_pickup', _handleDriverArrived);
// //     socket.on('trip_started', _handleTripStarted);
// //     socket.on('driver_near_destination', _handleDriverNearDestination);
// //     socket.on('driver_arrived_destination', _handleDriverArrivedDestination);
// //     socket.on('trip_completion_confirmed', _handleTripCompleted);
// //     socket.on('payment_confirmed', _handlePaymentConfirmed);
// //     socket.on('error', _handleSocketError);
// //     socket.on('disconnect', (_) => log('ride_tracker.socket_disconnected'.tr()));
// //   }

// //   void _joinTripRoom() {
// //     socket.emit('join_trip_room', {
// //       'tripId': widget.tripDetails['tripDetails']['_id']
// //     });
// //   }

// //   void _handleDriverLocationUpdate(dynamic data) {
// //     log('ride_tracker.driver_location_updated'.tr());
// //     _updateDriverMarker(data['latitude'], data['longitude']);
// //   }

// //   void _handleDriverNearPickup(dynamic data) {
// //     // _showNotification(
// //     //   'ride_tracker.driver_nearby_title'.tr(),
// //     //   'ride_tracker.driver_nearby_message'.tr(args: [data['distance'].toString()])
// //     // );
// //   }

// //   void _handleDriverArrived(_) {
// //     // _showNotification(
// //     //   'ride_tracker.driver_arrived_title'.tr(),
// //     //   'ride_tracker.driver_arrived_message'.tr()
// //     // );
// //   }

// //   void _handleTripStarted(_) {
// //     if (!mounted) return;
// //     setState(() {
// //       tripStatus = 'STARTED';
// //     });
// //     // _showNotification(
// //     //   'ride_tracker.trip_started_title'.tr(),
// //     //   'ride_tracker.trip_started_message'.tr()
// //     // );
// //     _updateUIForTripStart();
// //   }

// //   void _handleDriverNearDestination(_) {
// //     // _showNotification(
// //     //   'ride_tracker.almost_there_title'.tr(),
// //     //   'ride_tracker.almost_there_message'.tr()
// //     // );
// //   }

// //   void _handleDriverArrivedDestination(_) {
// //     if (!mounted) return;
// //     setState(() {
// //       tripStatus = 'ARRIVED';
// //       isPaymentPending = true;
// //     });
// //     // _showNotification(
// //     //   'ride_tracker.destination_arrived_title'.tr(),
// //     //   'ride_tracker.destination_arrived_message'.tr()
// //     // );
// //     _showTripCompletionDialog();
// //   }

// //   void _handleTripCompleted(_) {
// //     if (!mounted) return;
// //     setState(() {
// //       tripStatus = 'COMPLETED';
// //     });
// //   }

// //   void _handlePaymentConfirmed(_) {
// //     if (!mounted) return;
// //     setState(() {
// //       isPaymentPending = false;
// //     });
// //     _navigateToRating();
// //   }

// //   void _handleSocketError(dynamic error) {
// //     log('ride_tracker.socket_error'.tr());
// //     _showErrorSnackBar('ride_tracker.connection_error'.tr());
// //   }

// //   void _updateDriverMarker(double latitude, double longitude) {
// //     if (!mounted) return;
    
// //     LatLng newDriverLocation = LatLng(latitude, longitude);
    
// //     setState(() {
// //       _markers.removeWhere((marker) => marker.markerId.value == 'driver');
// //       _markers.add(Marker(
// //         markerId: const MarkerId('driver'),
// //         position: newDriverLocation,
// //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
// //         infoWindow: InfoWindow(
// //           title: 'ride_tracker.driver'.tr(),
// //           snippet: _getDriverMarkerSnippet(),
// //         ),
// //       ));
// //     });

// //     if (tripStatus != 'STARTED') {
// //       _updateDriverToPickupPolyline(newDriverLocation);
// //     }
    
// //     _updateCameraPosition();
// //   }

// //   String _getDriverMarkerSnippet() {
// //     switch (tripStatus) {
// //       case 'STARTED':
// //         return 'ride_tracker.trip_status.started'.tr();
// //       case 'ARRIVED':
// //         return 'ride_tracker.trip_status.arrived'.tr();
// //       case 'COMPLETED':
// //         return 'ride_tracker.trip_status.completed'.tr();
// //       default:
// //         return 'ride_tracker.trip_status.waiting'.tr();
// //     }
// //   }

// //   void _updateUIForTripStart() {
// //     setState(() {
// //       _polylines.removeWhere((polyline) => 
// //         polyline.polylineId.value == 'driver_to_pickup'
// //       );
// //       _markers.removeWhere((marker) => 
// //         marker.markerId.value == 'pickup'
// //       );
// //       _updateCameraPosition();
// //     });
// //   }

// //   void _showTripCompletionDialog() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => AlertDialog(
// //         title: Text(
// //           'ride_tracker.trip_completed'.tr(),
// //           style: AppTextTheme.getLightTextTheme(context).headlineMedium,
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               'ride_tracker.confirm_payment_message'.tr(),
// //               style: AppTextTheme.getLightTextTheme(context).bodyLarge,
// //             ),
// //             const SizedBox(height: 20),
// //             Text(
// //               'ride_tracker.total_fare'.tr(args: [
// //                 widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00'
// //               ]),
// //               style: AppTextTheme.getLightTextTheme(context).headlineLarge,
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               _confirmPayment();
// //             },
// //             child: Text('ride_tracker.confirm_payment'.tr()),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _confirmPayment() {
// //     socket.emit('payment_confirmed', {
// //       'tripId': widget.tripDetails['tripDetails']['_id'],
// //       'amount': widget.initialTripDetails['driverEstimatedFare'],
// //       'paymentMethod': 'CASH'
// //     });
// //   }

// //   void _navigateToRating() {
// //     if (!mounted) return;
// //     Navigator.pushReplacementNamed(context, AppRoutes.paymentmethod);
// //   }

// //   void _showErrorSnackBar(String message) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message.tr()),
// //         backgroundColor: Colors.red,
// //         duration: const Duration(seconds: 3),
// //       ),
// //     );
// //   }

// //   void _setUpMarkersAndPolylines() async {
// //     if (!mounted) return;
    
// //     try {
// //       final pickup = _parseLatLng(widget.initialTripDetails['pickup']);
// //       final destination = _parseLatLng(widget.initialTripDetails['destination']);
// //       final driverLocation = LatLng(
// //         widget.initialTripDetails['driverLocation']['latitude'],
// //         widget.initialTripDetails['driverLocation']['longitude']
// //       );

// //       setState(() {
// //         _markers.addAll({
// //           Marker(
// //             markerId: const MarkerId('pickup'),
// //             position: pickup,
// //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
// //             infoWindow: InfoWindow(
// //               title: 'ride_tracker.pickup_point'.tr(),
// //             ),
// //           ),
// //           Marker(
// //             markerId: const MarkerId('destination'),
// //             position: destination,
// //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
// //             infoWindow: InfoWindow(
// //               title: 'ride_tracker.destination_point'.tr(),
// //             ),
// //           ),
// //           Marker(
// //             markerId: const MarkerId('driver'),
// //             position: driverLocation,
// //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
// //             infoWindow: InfoWindow(
// //               title: 'ride_tracker.driver'.tr(),
// //             ),
// //           ),
// //         });
// //       });

// //       // Get route polylines
// //       List<LatLng> driverToPickupPoints = await LocationUtils.getPolylinePoints(
// //         driverLocation, 
// //         pickup
// //       );
// //       _addPolyline(driverToPickupPoints, Colors.blue, 'driver_to_pickup');

// //       List<LatLng> pickupToDestinationPoints = await LocationUtils.getPolylinePoints(
// //         pickup, 
// //         destination
// //       );
// //       _addPolyline(pickupToDestinationPoints, Colors.red, 'pickup_to_destination');

// //       // Set initial bounds
// //       List<LatLng> allPoints = [driverLocation, pickup, destination];
// //       LatLngBounds bounds = LocationUtils.calculateBounds(allPoints);
// //       mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
// //     } catch (e) {
// //       log('Error setting up markers and polylines: $e');
// //       _showErrorSnackBar('ride_tracker.error_generic'.tr());
// //     }
// //   }

// //   void _addPolyline(List<LatLng> points, Color color, String id) {
// //     setState(() {
// //       _polylines.add(Polyline(
// //         polylineId: PolylineId(id),
// //         color: color,
// //         points: points,
// //         width: 3,
// //       ));
// //     });
// //   }

// //  // Continuing from previous implementation...

// //   void _updateDriverToPickupPolyline(LatLng driverLocation) async {
// //     if (!mounted) return;
    
// //     try {
// //       LatLng pickup = _markers
// //           .firstWhere((m) => m.markerId.value == 'pickup')
// //           .position;
          
// //       List<LatLng> driverToPickupPoints = await LocationUtils.getPolylinePoints(
// //         driverLocation,
// //         pickup
// //       );
      
// //       setState(() {
// //         _polylines.removeWhere((polyline) => 
// //           polyline.polylineId.value == 'driver_to_pickup'
// //         );
// //         _addPolyline(driverToPickupPoints, Colors.blue, 'driver_to_pickup');
// //       });
// //     } catch (e) {
// //       log('Error updating driver polyline: $e');
// //     }
// //   }

// //   void _updateCameraPosition() {
// //     if (!mounted) return;
// //     try {
// //       List<LatLng> points = _markers.map((marker) => marker.position).toList();
// //       LatLngBounds bounds = LocationUtils.calculateBounds(points);
// //       mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
// //     } catch (e) {
// //       log('Error updating camera position: $e');
// //     }
// //   }

// //   LatLng _parseLatLng(String latLngString) {
// //     List<String> parts = latLngString.split(',');
// //     return LatLng(double.parse(parts[0]), double.parse(parts[1]));
// //   }

// //   void _onSheetChanged() {
// //     if (!mounted) return;
// //     if (_sheetController.size <= 0.05) {
// //       _sheetController.animateTo(
// //         60 / MediaQuery.of(context).size.height,
// //         duration: const Duration(milliseconds: 50),
// //         curve: Curves.easeInOut,
// //       );
// //     }
// //   }

// //   Widget _buildActionButtons() {
// //     final screenWidth = MediaQuery.of(context).size.width;

// //     if (tripStatus == 'COMPLETED' || tripStatus == 'ARRIVED') {
// //       return GestureDetector(
// //         onTap: () => _showTripCompletionDialog(),
// //         child: Container(
// //           width: screenWidth * 0.9,
// //           height: 50,
// //           decoration: BoxDecoration(
// //             color: AppColors.primary,
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Center(
// //             child: Text(
// //               isPaymentPending 
// //                   ? 'ride_tracker.confirm_payment_button'.tr()
// //                   : 'ride_tracker.rate_driver'.tr(),
// //               style: AppTextTheme.getLightTextTheme(context).titleLarge,
// //             ),
// //           ),
// //         ),
// //       );
// //     }

// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //       children: [
// //         GestureDetector(
// //           onTap: () {
// //             Navigator.push(
// //               context, 
// //               MaterialPageRoute(
// //                 builder: (context) => UserCancelTripScreen(
// //                   tripDetails: widget.tripDetails,
// //                   initialTripDetails: widget.initialTripDetails,
// //                 ),
// //               ),
// //             );
// //           },
// //           child: Container(
// //             width: screenWidth * 0.4,
// //             height: 50,
// //             decoration: BoxDecoration(
// //               color: AppColors.primary,
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 'ride_tracker.cancel_ride'.tr(),
// //                 style: AppTextTheme.getLightTextTheme(context).titleLarge,
// //               ),
// //             ),
// //           ),
// //         ),
// //         GestureDetector(
// //           onTap: () {
// //             if (tripStatus == 'STARTED') {
// //               _showTripCompletionDialog();
// //             }
// //           },
// //           child: Container(
// //             width: screenWidth * 0.4,
// //             height: 50,
// //             decoration: BoxDecoration(
// //               border: Border.all(
// //                 color: AppColors.primary,
// //                 width: 2.0,
// //               ),
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 'ride_tracker.end_ride'.tr(),
// //                 style: TextStyle(
// //                   color: AppColors.primary,
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPaymentInfo() {
// //     return Container(
// //       width: double.infinity,
// //       height: 90,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           Image.asset(
// //             "assets/images/cash.png",
// //             scale: 1.0,
// //             width: 55,
// //             height: 55,
// //           ),
// //           Text(
// //             'ride_tracker.cash'.tr(),
// //             style: AppTextTheme.getLightTextTheme(context).headlineMedium,
// //           ),
// //           Text(
// //             'ride_tracker.amount'.tr(args: [
// //               widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00'
// //             ]),
// //             style: AppTextTheme.getLightTextTheme(context).headlineLarge,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _sheetController.removeListener(_onSheetChanged);
// //     _sheetController.dispose();
// //     socket.disconnect();
// //     socket.dispose();
// //     mapController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: CameraPosition(
// //               target: _parseLatLng(widget.initialTripDetails['pickup']),
// //               zoom: 14,
// //             ),
// //             onMapCreated: (GoogleMapController controller) {
// //               mapController = controller;
// //               if (mapTheme.isNotEmpty) {
// //                 controller.setMapStyle(mapTheme);
// //               }
// //               _setUpMarkersAndPolylines(); 
// //             },
// //             markers: _markers,
// //             polylines: _polylines,
// //             myLocationEnabled: true,
// //             myLocationButtonEnabled: false,
// //             zoomControlsEnabled: false,
// //             mapToolbarEnabled: false,
// //             compassEnabled: true,
// //             trafficEnabled: false,
// //             tiltGesturesEnabled: false,
// //           ),

// //           // Status Bar
// //           Positioned(
// //             top: MediaQuery.of(context).padding.top + 10,
// //             left: 20,
// //             right: 20,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// //               decoration: BoxDecoration(
// //                 color: Colors.black.withOpacity(0.7),
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Text(
// //                 _getTripStatusText(),
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ),
// //           ),

// //           // Bottom Sheet
// //           DraggableScrollableSheet(
// //             initialChildSize: 0.5,
// //             minChildSize: 0.07,
// //             maxChildSize: 0.95,
// //             snapSizes: [0.07, 0.5, 0.95],
// //             snap: true,
// //             controller: _sheetController,
// //             builder: (BuildContext context, ScrollController scrollController) {
// //               return Container(
// //                 decoration: const BoxDecoration(
// //                   color: Colors.black,
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(20),
// //                     topRight: Radius.circular(20),
// //                   ),
// //                 ),
// //                 child: SingleChildScrollView(
// //                   controller: scrollController,
// //                   child: Column(
// //                     children: [
// //                       Container(
// //                         width: 50,
// //                         height: 5,
// //                         margin: const EdgeInsets.symmetric(vertical: 10),
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey[600],
// //                           borderRadius: BorderRadius.circular(5),
// //                         ),
// //                       ),
// //                       Padding(
// //                         padding: const EdgeInsets.all(16.0),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Center(
// //                               child: Text(
// //                                 tripStatus == 'STARTED' 
// //                                     ? 'ride_tracker.on_way_to_destination'.tr()
// //                                     : 'ride_tracker.ride_arriving'.tr(),
// //                                 style: const TextStyle(
// //                                   color: Colors.white,
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                             ),
// //                             if (widget.initialTripDetails['driverToPickupInfo'] != null)
// //                               Center(
// //                                 child: Text(
// //                                   widget.initialTripDetails['driverToPickupInfo'],
// //                                   style: const TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 14,
// //                                   ),
// //                                 ),
// //                               ),

// //                             const SizedBox(height: 20),

// //                             DriverContactCard(
// //                               driverName: widget.initialTripDetails['driver']['username'] ?? 'ride_tracker.unknown'.tr(),
// //                               driverRating: "${widget.initialTripDetails['driver']['ratingAverage'] ?? 'N/A'} (${widget.initialTripDetails['driver']['tripsCount'] ?? 0} ${'ride_tracker.trips'.tr()})",
// //                               driverImageUrl: widget.initialTripDetails['driver']['profilePicture'] ?? "",
// //                               driverBikename: widget.initialTripDetails['driver']['vehicleDetails']?['model'] ?? 'ride_tracker.unknown'.tr(),
// //                               userId: widget.tripDetails['tripDetails']['passenger']['_id'],
// //                               driverId: widget.initialTripDetails['driver']['userid']['_id'],
// //                               phoneNumber: widget.initialTripDetails['driver']['userid']['phone'] ?? "",
// //                             ),

// //                             const SizedBox(height: 20),

// //                             Text(
// //                               'ride_tracker.payment'.tr(),
// //                               style: AppTextTheme.getDarkTextTheme(context).headlineMedium,
// //                             ),
// //                             const SizedBox(height: 10),
// //                             _buildPaymentInfo(),

// //                             const SizedBox(height: 40),
// //                             _buildActionButtons(),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   String _getTripStatusText() {
// //     switch (tripStatus) {
// //       case 'WAITING':
// //         return 'ride_tracker.trip_status.waiting'.tr();
// //       case 'STARTED':
// //         return 'ride_tracker.trip_status.started'.tr();
// //       case 'ARRIVED':
// //         return 'ride_tracker.trip_status.arrived'.tr();
// //       case 'COMPLETED':
// //         return 'ride_tracker.trip_status.completed'.tr();
// //       default:
// //         return 'ride_tracker.trip_status.preparing'.tr();
// //     }
// //   }
// // }




import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/services/notification_service.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/map_provider.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/widgets/cancel_trip_screen.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/widgets/driver_contact_card.dart';
import 'package:rideapp/utils/location_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ShowRiderDetails extends StatefulWidget {
  final Map<String, dynamic> tripDetails;
  final Map<String, dynamic> initialTripDetails;

  const ShowRiderDetails(
      {super.key, required this.tripDetails, required this.initialTripDetails});

  @override
  State<ShowRiderDetails> createState() => _ShowRiderDetailsState();
}

class _ShowRiderDetailsState extends State<ShowRiderDetails> {
  late GoogleMapController mapController;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  IO.Socket? socket;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    initializeSocket();
    _loadMapTheme();
    // Store driver ID in SharedPreferences
    _storeDriverId();
    log('ShowRiderDetails ===>>>>> - initState');
    log('Received tripDetails: ${widget.tripDetails}');
    log('Received initialTripDetails: ${widget.initialTripDetails}');
    _setUpMarkersAndPolylines();
    _sheetController.addListener(_onSheetChanged);
  }


void initializeSocket() {
  socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  socket?.on('connect', (_) {
    log('Socket Connected');
  });

  socket?.on('driver_cancelled', (data) async {
    log('Driver Cancellation Event: $data');

    try {
      final notificationService = NotificationService();
      // The message from backend is already localized
      final message = data['message'] ?? tr('ride_tracker.trip_cancelled_default');
      
      await notificationService.showNotification(
        title: tr('ride_tracker.trip_cancelled'),
        body: message, // Using server-provided localized message
        payload: data.toString(),
      );
      log('Notification shown successfully');
    } catch (e) {
      log('Error showing notification: $e');
    }

    if (mounted) {
      final canPop = Navigator.of(context).canPop();
      if (canPop) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  });

  // Listen for general notifications (trip start/complete)
  socket?.on(widget.tripDetails['tripDetails']['passenger']['_id'], (notification) async {
    log('Received notification: $notification');
    
    final message = notification['message'] as String;
    
    // Determine notification title based on message content while respecting server localization
    String title;
    if (message.contains('Started') || message.contains('iniciado')) {
      title = tr('ride_tracker.trip_started');
    } else if (message.contains('Completed') || message.contains('completado')) {
      title = tr('ride_tracker.trip_completed');
    } else {
      title = tr('ride_tracker.notification');
    }
    
    // Show notification
    final notificationService = NotificationService();
    await notificationService.showNotification(
      title: title,
      body: message,  
    );

    // If trip completed, navigate to payment
    if (message.contains('Completed') || message.contains('completado')) {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          AppRoutes.paymentMethod,
          arguments: {
            'estimatedFare': widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00'
          }
        );
      }
    }
  });

  // Listen for location updates
  socket?.on('driver_location_updated', (data) {
    log('Driver location update: $data');
    if (data['tripId'] == widget.tripDetails['tripDetails']['_id']) {
      _updateDriverMarker(
        double.parse(data['latitude']), 
        double.parse(data['longitude'])
      );
    }
  });
}


//   void initializeSocket() {
//     socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//      socket?.on('connect', (_) {
//       log('Socket Connected');
//     });

   
//     socket?.on('driver_cancelled', (data) async {
//   log('Driver Cancellation Event: $data');

//   try {
//     final notificationService = NotificationService();
//     log('Attempting to show notification');
//     await notificationService.showNotification(
//       title: 'Trip Cancelled',
//       body: data['message'] ?? 'Your trip has been cancelled',
//       payload: data.toString(),
//     );
//     log('Notification shown successfully');
//   } catch (e) {
//     log('Error showing notification: $e');
//   }

//   // Navigate conditionally based on route stack
//   if (mounted) {
//     final canPop = Navigator.of(context).canPop();
//     if (canPop) {
//       // If there is a previous screen, just pop back
//       Navigator.of(context).pop();
//     } else {
//       // If no screen to pop, go back to the home screen
//       Navigator.of(context).popUntil((route) => route.isFirst);
//     }
//   }
// });

//     // Listen for general notifications (trip start/complete)
//     socket?.on(widget.tripDetails['tripDetails']['passenger']['_id'], (notification) async {
//       log('Received notification: $notification');
      
//       final message = notification['message'] as String;
      
//       // Show notification
//       final notificationService = NotificationService();
//       await notificationService.showNotification(
//         title: message.contains('Started') ? 'Trip Started' : 'Trip Completed',
//         body: message,
//       );

//       // If trip completed, navigate to payment
//       if (message.contains('Completed') && mounted) {
//         Navigator.pushReplacementNamed(
//           context, 
//           AppRoutes.paymentMethod,
//           arguments: {
//             'estimatedFare': widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00'
//           }
//         );
//       }
//     });

//     // Listen for location updates
//     socket?.on('driver_location_updated', (data) {
//       log('Driver location update: $data');
//       if (data['tripId'] == widget.tripDetails['tripDetails']['_id']) {
//         _updateDriverMarker(
//           double.parse(data['latitude']), 
//           double.parse(data['longitude'])
//         );
//       }
//     });
// }

  void _updateDriverMarker(double latitude, double longitude) {
    LatLng newDriverLocation = LatLng(latitude, longitude);
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'driver');
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: newDriverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });

    _updateDriverToPickupPolyline(newDriverLocation);
    _updateCameraPosition();
  }

  void _updateCameraPosition() {
    List<LatLng> points = _markers.map((marker) => marker.position).toList();
    LatLngBounds bounds = LocationUtils.calculateBounds(points);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  // THEME LOAD
  Future<void> _loadMapTheme() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final mapTheme = await DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/standard_theme.json');
    mapProvider.setMapTheme(mapTheme);
  }

  Future<void> _storeDriverId() async {
    try {
      log('Storing IDs in SharedPreferences...');
      final tripId = widget.tripDetails['tripDetails']?['_id'];
      final driverId = widget.initialTripDetails['driver']?['_id'];
      final userId = widget.tripDetails['passenger']?['_id'];

      log('Trip ID to store: $tripId');
      log('Driver ID to store:=================?>>>>>> $driverId');
      log('User ID to store: $userId');

      final prefs = await SharedPreferences.getInstance();
      if (tripId != null) {
        await prefs.setString('tripId', tripId);
        log('Successfully stored trip ID: $tripId');
      }
      if (driverId != null) {
        await prefs.setString('driverId', driverId);
        log('Successfully stored driver ID: $driverId');
      }
    } catch (e) {
      log('Error storing IDs: $e');
    }
  }

  void _showTripCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'ride_tracker.trip_completed'.tr(),
          style: AppTextTheme.getLightTextTheme(context).headlineMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ride_tracker.confirm_payment_message'.tr(),
              style: AppTextTheme.getLightTextTheme(context).bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'ride_tracker.total_fare'.tr(args: [
                widget.initialTripDetails['driverEstimatedFare']
                        ?.toStringAsFixed(2) ??
                    '0.00'
              ]),
              style: AppTextTheme.getLightTextTheme(context).headlineLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmPayment();
            },
            child: Text('ride_tracker.confirm_payment'.tr()),
          ),
        ],
      ),
    );
  }

  void _confirmPayment() {
    socket?.emit('payment_confirmed', {
      'tripId': widget.tripDetails['tripDetails']['_id'],
      'amount': widget.initialTripDetails['driverEstimatedFare'],
      'paymentMethod': 'CASH'
    });
  }

  void _setUpMarkersAndPolylines() async {
    log('ShowRiderDetails - Setting up markers and polylines');
    final pickup = _parseLatLng(widget.initialTripDetails['pickup']);
    final destination = _parseLatLng(widget.initialTripDetails['destination']);
    final driverLocation = LatLng(
        widget.initialTripDetails['driverLocation']['latitude'],
        widget.initialTripDetails['driverLocation']['longitude']);

    log('Pickup location: $pickup');
    log('Destination location: $destination');
    log('Driver location: $driverLocation');

    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
    log('Markers added: $_markers');

    // Get polyline between driver and pickup
    List<LatLng> driverToPickupPoints =
        await LocationUtils.getPolylinePoints(driverLocation, pickup);
    _addPolyline(driverToPickupPoints, Colors.blue, 'driver_to_pickup');
    log('Driver to pickup polyline added');

    // Get polyline between pickup and destination
    List<LatLng> pickupToDestinationPoints =
        await LocationUtils.getPolylinePoints(pickup, destination);
    _addPolyline(
        pickupToDestinationPoints, Colors.red, 'pickup_to_destination');
    log('Pickup to destination polyline added');

    // Calculate and set bounds
    List<LatLng> allPoints = [driverLocation, pickup, destination];
    LatLngBounds bounds = LocationUtils.calculateBounds(allPoints);
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    log('Camera bounds set');
  }

  void _addPolyline(List<LatLng> points, Color color, String id) {
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId(id),
        color: color,
        points: points,
        width: 3,
      ));
    });
    log('Polyline added: $id');
  }

  void _updateDriverToPickupPolyline(LatLng driverLocation) async {
    LatLng pickup =
        _markers.firstWhere((m) => m.markerId.value == 'pickup').position;
    List<LatLng> driverToPickupPoints =
        await LocationUtils.getPolylinePoints(driverLocation, pickup);

    setState(() {
      _polylines.removeWhere(
          (polyline) => polyline.polylineId.value == 'driver_to_pickup');
      _addPolyline(driverToPickupPoints, Colors.blue, 'driver_to_pickup');
    });
  }

  LatLng _parseLatLng(String latLngString) {
    List<String> parts = latLngString.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  void _onSheetChanged() {
    if (_sheetController.size <= 0.05) {
      _sheetController.animateTo(
        60 / MediaQuery.of(context).size.height,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    log('ShowRiderDetails - build method called');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Extract passenger ID correctly from nested structure
    // Correct way to extract passenger ID
    final passengerId =
        widget.tripDetails['tripDetails']?['passenger']?['_id'] ?? 'null';
    final driverId =
        widget.initialTripDetails['driver']?['userid']?['_id'] ?? 'null';
    final driverPhone =
        widget.initialTripDetails['driver']?['userid']?['phone'] ?? 'null';

    // Log the extracted data
    log('Passenger ID: $passengerId');
    log('Driver ID: $driverId');
    log('Driver Phone: $driverPhone');

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _parseLatLng(widget.initialTripDetails['pickup']),
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              log('GoogleMap created');
              mapController = controller;
              // if (mapTheme.isNotEmpty) {
              //   controller.setMapStyle(mapTheme);
              // }
              _setUpMarkersAndPolylines();
            },
            markers: _markers,
            polylines: _polylines,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0,
            maxChildSize: 0.95,
            snapSizes: [60 / screenHeight, 0.6],
            snap: true,
            controller: _sheetController,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'ride_tracker.ride_arriving'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                widget.initialTripDetails[
                                        'driverToPickupInfo'] ??
                                    '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DriverContactCard(
                              driverName: widget.initialTripDetails['driver']
                                      ['username'] ??
                                  "Unknown",
                              driverRating:
                                  "${(widget.initialTripDetails['driver']['ratingAverage'] ?? 0.0).toStringAsFixed(1)} (${widget.initialTripDetails['driver']['tripsCount'] ?? 0} Trips)",

                              driverImageUrl:
                                  widget.initialTripDetails['driver']
                                          ['profilePicture'] ??
                                      "",
                              // driverBikename: "Unknown",
                              userId: passengerId,
                              driverId: driverId,
                              phoneNumber: driverPhone,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'ride_tracker.payment'.tr(),
                              style: AppTextTheme.getDarkTextTheme(context)
                                  .headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    "assets/images/cash.png",
                                    scale: 1.0,
                                    width: 55,
                                    height: 55,
                                  ),
                                  Text(
                                    'ride_tracker.cash'.tr(),
                                    style:
                                        AppTextTheme.getLightTextTheme(context)
                                            .headlineMedium,
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00'}",
                                        style: AppTextTheme.getLightTextTheme(
                                                context)
                                            .headlineLarge,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserCancelTripScreen(
                                          tripDetails: widget.tripDetails,
                                          initialTripDetails:
                                              widget.initialTripDetails,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: screenWidth * 0.4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'ride_tracker.cancel_ride'.tr(),
                                        style: AppTextTheme.getLightTextTheme(
                                                context)
                                            .titleLarge,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                        context, AppRoutes.paymentMethod,
                                        arguments: {
                                          'estimatedFare': widget
                                                  .initialTripDetails[
                                                      'driverEstimatedFare']
                                                  ?.toStringAsFixed(2) ??
                                              '0.00'
                                        });
                                  },
                                  child: Container(
                                    width: screenWidth * 0.4,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'ride_tracker.end_ride'.tr(),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
