import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/constant/image_url.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/map_provider.dart';
import 'package:sendme/views/User_panel/parcel_deliver/payment_method_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/widgets/cancel_trip_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/widgets/driver_contact_card.dart';
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
        final message =
            data['message'] ?? tr('ride_tracker.trip_cancelled_default');

        await notificationService.showNotification(
          title: tr('ride_tracker.trip_cancelled'),
          body: message,
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

    // Keep track of processed notification IDs
    Set<String> processedNotifications = {};

    socket?.on(widget.tripDetails['tripDetails']['passenger']['_id'],
        (notification) async {
      log('Received notification: $notification');

      // Check if this notification has an ID and if we've already processed it
      String notificationId = notification['id'] ??
          notification['_id'] ??
          DateTime.now().toIso8601String();
      if (processedNotifications.contains(notificationId)) {
        log('Notification already processed: $notificationId');
        return;
      }

      // Mark as processed immediately to prevent duplicate processing
      processedNotifications.add(notificationId);

      // Make sure message is a string, otherwise convert it
      final message = notification['message'] is String
          ? notification['message'] as String
          : notification['message'].toString();

      // Check for delivery proof image
      String? imageUrl;
      if (notification['deliveryProofImage'] != null) {
        imageUrl = notification['deliveryProofImage'].toString();
        log('Delivery proof image found: $imageUrl');

        // Save the image URL to SharedPreferences
        try {
          final fullImageUrl = ImageUrlUtils.getFullImageUrl(imageUrl);
          await _saveImageUrlToPrefs(fullImageUrl);
          log('Saved delivery proof image to prefs: $fullImageUrl');
        } catch (e) {
          log('Error saving delivery proof image: $e');
        }
      }

      // Determine notification title based on message content
      String title;

      // Check for keywords in English and Spanish
      List<String> startKeywords = [
        tr('ride_tracker.keywords.started').toLowerCase(),
        tr('ride_tracker.keywords.iniciado').toLowerCase(),
      ];

      List<String> completedKeywords = [
        tr('ride_tracker.keywords.completed').toLowerCase(),
        tr('ride_tracker.keywords.completado').toLowerCase(),
        tr('ride_tracker.keywords.entrega').toLowerCase(),
        tr('ride_tracker.keywords.package').toLowerCase(),
        tr('ride_tracker.keywords.paquete').toLowerCase(),
      ];

      String messageLower = message.toLowerCase();

      if (startKeywords.any((keyword) => messageLower.contains(keyword))) {
        title = tr('ride_tracker.trip_started');
      } else if (completedKeywords
          .any((keyword) => messageLower.contains(keyword))) {
        title = tr('ride_tracker.trip_completed');
      } else {
        title = tr('ride_tracker.notification');
      }

      // Show notification
      try {
        final notificationService = NotificationService();
        await notificationService.showNotification(
          title: title,
          body: message,
        );
        log('Notification shown successfully: $title');
      } catch (e) {
        log('Error showing notification: $e');
      }

      // Get service type safely
      String? serviceType;
      bool isParcelDelivery = true;
      try {
        // Try to extract service type from different possible locations
        serviceType = widget.tripDetails['tripDetails']?['serviceType'] ??
            widget.tripDetails['serviceType'];

        // Check message content as fallback using localized keywords
        List<String> parcelKeywords = [
          tr('ride_tracker.keywords.parcel').toLowerCase(),
          tr('ride_tracker.keywords.paquete').toLowerCase(),
          tr('ride_tracker.keywords.package').toLowerCase(),
          tr('ride_tracker.keywords.delivery').toLowerCase(),
          tr('ride_tracker.keywords.entrega').toLowerCase(),
        ];

        if (serviceType == null &&
            parcelKeywords.any((keyword) => messageLower.contains(keyword))) {
          serviceType = 'parcel';
        }

        isParcelDelivery = serviceType == 'parcel';
        log('Service type detected: $serviceType, isParcel: $isParcelDelivery');
      } catch (e) {
        log('Error detecting service type: $e');
      }

      // Check if this is a completion/delivery message using localized keywords
      List<String> completionKeywords = [
        tr('ride_tracker.keywords.completed').toLowerCase(),
        tr('ride_tracker.keywords.completada').toLowerCase(),
        tr('ride_tracker.keywords.completado').toLowerCase(),
        tr('ride_tracker.keywords.entrega').toLowerCase(),
        tr('ride_tracker.keywords.paquete').toLowerCase(),
        tr('ride_tracker.keywords.parcel').toLowerCase(),
        tr('ride_tracker.keywords.delivery').toLowerCase(),
      ];

      bool isCompletionMessage =
          completionKeywords.any((keyword) => messageLower.contains(keyword));

      if (isCompletionMessage) {
        log('Completion/delivery message detected. Message: $message');

        // Process delivery proof image
        if (imageUrl != null) {
          log('Processed delivery proof image from notification: $imageUrl');
        }

        // Navigate if widget is mounted
        if (mounted) {
          log('Widget is mounted, attempting navigation to PaymentMethodScreen');
          try {
            final fare = widget.initialTripDetails['driverEstimatedFare']
                    ?.toStringAsFixed(2) ??
                '0.00';

            log('Navigating with: Fare=$fare, IsParcel=$isParcelDelivery, Image=$imageUrl');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentMethodScreen(
                  estimatedFare: fare,
                  deliveryProofImage: imageUrl,
                  isParcelDelivery: isParcelDelivery,
                ),
              ),
            );
            log('Navigation request sent');
          } catch (e) {
            log('Navigation error: $e');

            // Basic fallback
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodScreen(
                    estimatedFare: '0.00',
                  ),
                ),
              );
              log('Fallback navigation executed');
            } catch (secondError) {
              log('Fallback navigation failed: $secondError');
            }
          }
        } else {
          log('Widget not mounted, cannot navigate');
        }
      }
    });

    // Listen for location updates
    socket?.on('driver_location_updated', (data) {
      log('Driver location update: $data');
      if (data['tripId'] == widget.tripDetails['tripDetails']['_id']) {
        _updateDriverMarker(
            double.parse(data['latitude']), double.parse(data['longitude']));
      }
    });
  }

  // Helper method to save image URL for later
  Future<void> _saveImageUrlToPrefs(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('latest_delivery_proof', imageUrl);
      await prefs.setBool('show_delivery_proof_dialog', true);
      log('Saved delivery proof image URL to prefs: $imageUrl');
    } catch (e) {
      log('Error saving image URL to prefs: $e');
    }
  }

  // void initializeSocket() {
  //   socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': true,
  //   });

  //   socket?.on('connect', (_) {
  //     log('Socket Connected');
  //   });

  //   socket?.on('driver_cancelled', (data) async {
  //     log('Driver Cancellation Event: $data');
  //     try {
  //       final notificationService = NotificationService();
  //       final message = data['message'] ?? 'Your trip has been cancelled';

  //       await notificationService.showNotification(
  //         title: 'Trip Cancelled',
  //         body: message,
  //         payload: data.toString(),
  //       );
  //       log('Notification shown successfully');
  //     } catch (e) {
  //       log('Error showing notification: $e');
  //     }
  //     if (mounted) {
  //       final canPop = Navigator.of(context).canPop();
  //       if (canPop) {
  //         Navigator.of(context).pop();
  //       } else {
  //         Navigator.of(context).popUntil((route) => route.isFirst);
  //       }
  //     }
  //   });

  //   // Get passenger ID safely with null checking
  //   final passengerId = widget.tripDetails['tripDetails']?['passenger']
  //           ?['_id'] ??
  //       widget.tripDetails['passenger']?['_id'] ??
  //       '';

  //   log('Listening for notifications on passenger ID: $passengerId');

  //   // Listen for general notifications (trip start/complete)
  //   if (passengerId.isNotEmpty) {
  //     //   socket?.on(passengerId, (notification) async {
  //     //     log('Received notification: $notification');

  //     //     // Check if notification is Map or String and extract data
  //     //     String message = '';
  //     //     Map<String, dynamic> notificationData = {};
  //     //     String? imageUrl;

  //     //     if (notification is Map) {
  //     //       // Extract message and data from map
  //     //       message = notification['message'] as String? ?? '';
  //     //       notificationData = Map<String, dynamic>.from(notification);

  //     //       // Check for image URL in different possible locations
  //     //       imageUrl = notificationData['imageUrl'] ??
  //     //                  notificationData['deliveryProofImage'] ??
  //     //                  null;

  //     //       log('Extracted image URL from notification: $imageUrl');
  //     //     } else {
  //     //       message = notification.toString();
  //     //     }

  //     //     log('Notification message: $message');

  //     //     // Determine if this is a parcel delivery notification
  //     //     bool isParcelDelivery =
  //     //         message.contains('parcel delivery') ||
  //     //         message.contains('Parcel Delivered') ||
  //     //         message.contains('Your parcel delivery has been completed');

  //     //     bool isRideCompleted =
  //     //         message.contains('Completed') ||
  //     //         message.contains('completado');

  //     //     // Determine title based on notification content
  //     //     String title;
  //     //     if (message.contains('Started') || message.contains('iniciado')) {
  //     //       title = 'Trip Started';
  //     //     } else if (isParcelDelivery || isRideCompleted) {
  //     //       title = 'Trip Completed';
  //     //     } else {
  //     //       title = 'Notification';
  //     //     }

  //     //     // Show notification with image if available
  //     //     final notificationService = NotificationService();
  //     //     await notificationService.showNotification(
  //     //       title: title,
  //     //       body: message,
  //     //     );

  //     //     // If parcel delivery or trip completion, save image and navigate
  //     //     if (isParcelDelivery || isRideCompleted) {
  //     //       log('Trip/Parcel delivery completed - navigating to payment screen');

  //     //       // Save image URL to SharedPreferences if available
  //     //       if (imageUrl != null && imageUrl.isNotEmpty) {
  //     //         final prefs = await SharedPreferences.getInstance();
  //     //         await prefs.setString('latest_delivery_proof', imageUrl);
  //     //         log('Saved delivery proof image: $imageUrl');
  //     //       }

  //     //       if (mounted) {
  //     //         Navigator.pushReplacementNamed(
  //     //           context,
  //     //           AppRoutes.paymentMethod,
  //     //           arguments: {
  //     //             'estimatedFare': widget.initialTripDetails['driverEstimatedFare']?.toStringAsFixed(2) ?? '0.00',
  //     //             'deliveryProofImage': imageUrl,
  //     //             'isParcelDelivery': isParcelDelivery,
  //     //           }
  //     //         );
  //     //       }
  //     //     }
  //     //   });
  //     // } else {
  //     //   log('ERROR: Cannot listen for notifications - passenger ID is missing');
  //     // }

  //     socket?.on(passengerId, (notification) async {
  //       log('Received notification: $notification');

  //       // Check if notification is Map or String and extract data
  //       String message = '';
  //       Map<String, dynamic> notificationData = {};
  //       String? imageUrl;

  //       if (notification is Map) {
  //         // Extract message and data from map
  //         message = notification['message'] as String? ?? '';
  //         notificationData = Map<String, dynamic>.from(notification);

  //         // Check for image URL in different possible locations
  //         imageUrl = notificationData['imageUrl'] ??
  //             notificationData['deliveryProofImage'] ??
  //             null;

  //         log('Extracted image URL from notification: $imageUrl');
  //       } else {
  //         message = notification.toString();
  //       }

  //       log('Notification message: $message');

  //       // Determine if this is a parcel delivery notification
  //       bool isParcelDelivery = message.contains('parcel delivery') ||
  //           message.contains('Parcel Delivered') ||
  //           message.contains('Your parcel delivery has been completed');

  //       bool isRideCompleted =
  //           message.contains('Completed') || message.contains('completado');

  //       // Show notification
  //       final notificationService = NotificationService();
  //       await notificationService.showNotification(
  //         title: isParcelDelivery || isRideCompleted
  //             ? 'Trip Completed'
  //             : 'Notification',
  //         body: message,
  //       );

  //       // IMPORTANT: Add this code to navigate immediately when parcel is delivered
  //       if (isParcelDelivery || isRideCompleted) {
  //         log('Trip/Parcel delivery completed - navigating to payment screen');

  //         // Save image URL to SharedPreferences if available
  //         if (imageUrl != null && imageUrl.isNotEmpty) {
  //           final prefs = await SharedPreferences.getInstance();
  //           await prefs.setString('latest_delivery_proof', imageUrl);
  //           log('Saved delivery proof image: $imageUrl');
  //         }

  //         // Make sure we're on the main thread and check if the widget is still mounted
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           if (mounted) {
  //             Navigator.pushReplacementNamed(context, AppRoutes.paymentMethod,
  //                 arguments: {
  //                   'estimatedFare': widget
  //                           .initialTripDetails['driverEstimatedFare']
  //                           ?.toStringAsFixed(2) ??
  //                       '0.00',
  //                   'deliveryProofImage': imageUrl,
  //                   'isParcelDelivery': isParcelDelivery,
  //                 });
  //             log('Navigation to payment screen initiated');
  //           } else {
  //             log('Widget not mounted, cannot navigate');
  //           }
  //         });
  //       }
  //     });
  //   }
  //   // Listen for location updates with null checking
  //   final tripId = widget.tripDetails['tripDetails']?['_id'] ??
  //       widget.tripDetails['_id'] ??
  //       '';

  //   if (tripId.isNotEmpty) {
  //     socket?.on('driver_location_updated', (data) {
  //       log('Driver location update: $data');
  //       if (data['tripId'] == tripId) {
  //         _updateDriverMarker(
  //             double.parse(data['latitude']), double.parse(data['longitude']));
  //       }
  //     });
  //   } else {
  //     log('ERROR: Cannot listen for location updates - trip ID is missing');
  //   }
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
                  color: Colors.white,
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
                                  color: Colors.black,
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
                                  color: Colors.black,
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
                              style: AppTextTheme.getLightTextTheme(context)
                                  .headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PaymentMethodScreen(
                                          estimatedFare: widget
                                                  .initialTripDetails[
                                                      'driverEstimatedFare']
                                                  ?.toStringAsFixed(2) ??
                                              '0.00',
                                        ),
                                      ),
                                    );
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
