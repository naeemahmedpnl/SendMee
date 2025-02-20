

import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/map_provider.dart';
import 'package:sendme/views/User_panel/RideBookScreens/widgets/cancel_trip_screen.dart';
import 'package:sendme/views/User_panel/RideBookScreens/widgets/driver_contact_card.dart';
import 'package:sendme/utils/location_utils.dart';
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
        .loadString('assets/map_theme/night_theme.json');
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
                                      color: AppColors.buttonColor,
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
                                        color: AppColors.buttonColor,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'ride_tracker.end_ride'.tr(),
                                        style: const TextStyle(
                                          color: AppColors.buttonColor,
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
