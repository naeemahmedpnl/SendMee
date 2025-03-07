import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sendme/services/notification_service.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/location_utils.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/views/Driver_panel/ride_screens/ride_booking_view.dart';
import 'package:sendme/views/Driver_panel/widgets/driver_contact_card.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sendme/views/Driver_panel/ride_screens/location.dart';
import 'package:sendme/views/Driver_panel/ride_screens/location_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GetDirection extends StatelessWidget {
  final Map<String, dynamic> tripData;
  const GetDirection({Key? key, required this.tripData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripProvider(),
      child: _GetDirectionContent(tripData: tripData),
    );
  }
}

class _GetDirectionContent extends StatefulWidget {
  final Map<String, dynamic> tripData;
  const _GetDirectionContent({Key? key, required this.tripData})
      : super(key: key);

  @override
  _GetDirectionContentState createState() => _GetDirectionContentState();
}

class _GetDirectionContentState extends State<_GetDirectionContent> {
  final NotificationService _notificationService = NotificationService();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Timer? _locationUpdateTimer;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isLoading = false;
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeTrip();
    storePassengerId();
    initializeSocket();
    _notificationService.requestNotificationPermissions();

    // Initial map view with route to pickup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getRouteBounds([
              LatLng(
                widget.tripData['driverCurrentLocation']['latitude'],
                widget.tripData['driverCurrentLocation']['longitude'],
              ),
              widget.tripData['pickupLocation'],
            ]),
            100, // padding
          ),
        );
      });
    });
  }

// Add this method for calculating bounds
  LatLngBounds _getRouteBounds(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );
  }

  // Base URL
  String get baseUrl => Constants.apiBaseUrl;

  IO.Socket? socket;

  void initializeSocket() {
    try {
      log(' Initializing Socket for Trip Tracking',
          name: 'SOCKET_INITIALIZATION');

      socket = IO.io('$baseUrl', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      // Extensive logging for socket events
      socket?.on('user_deleted_trip', (data) {
        log(' User Deleted Trip Event Received', name: 'SOCKET_EVENT');
        log(' Event Data: $data', name: 'SOCKET_EVENT');

        // Detailed logging of trip identification
        log(' Current Trip ID: ${widget.tripData['fullData']['result']['_id']}',
            name: 'SOCKET_EVENT');
        log(' Incoming Trip ID: ${data['tripId']}', name: 'SOCKET_EVENT');

        // Use Future.delayed for safer navigation
        Future.delayed(Duration.zero, () {
          try {
            // Comprehensive mounted and context checks
            log(' Checking Screen Mounted Status', name: 'NAVIGATION_CHECK');
            if (!mounted) {
              log(' Screen not mounted. Aborting navigation.',
                  name: 'NAVIGATION_ERROR');
              return;
            }

            // Verify trip match
            if (data['tripId'] ==
                widget.tripData['fullData']['result']['_id']) {
              log(' Trip ID Matched. Proceeding with Cancellation',
                  name: 'NAVIGATION_CHECK');

              // Cancel location updates
              _locationUpdateTimer?.cancel();
              log(' Location Update Timer Cancelled',
                  name: 'TIMER_MANAGEMENT');

              // Disconnect socket
              socket?.disconnect();
              log(' Socket Disconnected', name: 'SOCKET_MANAGEMENT');

              // System Notification
              NotificationService().showNotification(
                title: tr('ride_tracker.trip_cancelled'),
                body: data['message'] ?? tr('ride_tracker.user_cancelled_trip'),
              );
              log(' System Notification Triggered',
                  name: 'NOTIFICATION_MANAGEMENT');

              // Navigation with extensive logging
              try {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const RideBookingView()),
                    (route) => false);
                log(' Navigation to RideBooking Successful',
                    name: 'NAVIGATION_SUCCESS');
              } catch (navError) {
                log(' Navigation Error: $navError',
                    name: 'NAVIGATION_ERROR', error: navError);
              }

              // In-app Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message'] ??
                      tr('ride_tracker.user_cancelled_trip')),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.red,
                ),
              );
              log(' Snackbar Displayed', name: 'UI_MANAGEMENT');
            } else {
              log(' Trip ID Mismatch. No Action Taken.',
                  name: 'NAVIGATION_ERROR');
            }
          } catch (e) {
            log(' Unexpected Error in Trip Cancellation Handler: $e',
                name: 'SOCKET_ERROR', error: e);
          }
        });
      });

      // Socket Connection Logging
      socket?.onConnect((_) {
        log(' Socket Connected Successfully', name: 'SOCKET_STATUS');
      });

      socket?.onConnectError((error) {
        log(' Socket Connection Error: $error',
            name: 'SOCKET_CONNECTION_ERROR', error: error);
      });

      socket?.onDisconnect((_) {
        log(' Socket Disconnected', name: 'SOCKET_STATUS');
      });
    } catch (e) {
      log(' Complete Socket Initialization Failure: $e',
          name: 'SOCKET_CRITICAL_ERROR', error: e);
    }
  }



  // Add a method to check if the trip is a parcel delivery
  bool isParcelTrip() {
    // Check if the trip data contains a marker indicating parcel delivery
    return widget.tripData['fullData']['result']['serviceType'] == 'parcel';
  }
  
  // Updated method to handle button press
  void _handleButtonPress(TripProvider tripProvider) async {
    if (!tripProvider.hasPickedUpPassenger) {
      _startTrip();
    } else {
      // Get current location when button is pressed
      final position = await LocationService.getCurrentPosition();
      final currentLocation = LatLng(position.latitude, position.longitude);
      final dropoffLocation = widget.tripData['dropoffLocation'];

      // Check distance when button is clicked
      bool isNearDestination = await _isWithin500MetersOfDestination(
          currentLocation, dropoffLocation);

      if (isNearDestination) {
        if (isParcelTrip()) {
          // Show camera for parcel deliveries
          _showDeliveryProofDialog(tripProvider);
        } else {
          // Directly complete the trip for regular rides
          await _completeTrip();
        }
      } else {
        // Show "not close enough" message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isParcelTrip() 
                    ? 'You need to be closer to the delivery location'
                    : 'You need to be closer to the destination to complete the ride'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  

// Dialog to capture delivery proof image with dark theme and offline support
void _showDeliveryProofDialog(TripProvider tripProvider) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.buttonColor, width: 1),
            ),
            title: const Text(
              'Delivery Proof Photo',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tripProvider.isOffline 
                      ? 'You appear to be offline. The photo will be uploaded when connection is restored.'
                      : 'Please take a photo as proof of delivery',
                    style: TextStyle(
                      color: tripProvider.isOffline ? Colors.yellow[300] : Colors.black, 
                      fontSize: 16
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Network status indicator if offline
                  if (tripProvider.isOffline)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.yellow[700]!, width: 1)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.yellow[700], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Offline Mode',
                            style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Image preview or placeholder
                  if (tripProvider.deliveryProofImage != null)
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.buttonColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          tripProvider.deliveryProofImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.buttonColor,),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.buttonColor,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: AppColors.backgroundLight,
                          size: 50,
                        ),
                      ),
                    ),
                    
                  // Error message if any
                  if (tripProvider.lastError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.5))
                        ),
                        child: Text(
                          tripProvider.lastError!,
                          style: TextStyle(color: Colors.red[300], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 24),
                  
                  // Loading indicator or buttons
                  tripProvider.isUploadingImage
                      ? const Column(
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.buttonColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Uploading image...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(
                                tripProvider.deliveryProofImage == null
                                    ? Icons.camera_alt
                                    : Icons.refresh,
                                color: Colors.white,
                              ),
                              label: Text(
                                tripProvider.deliveryProofImage == null
                                    ? 'Take Photo'
                                    : 'Retake Photo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final captured = await tripProvider
                                    .captureDeliveryProofImage();
                                if (captured) {
                                  setState(() {}); // Refresh dialog UI
                                }
                              },
                            ),
                            if (tripProvider.deliveryProofImage != null) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: Icon(
                                  tripProvider.isOffline 
                                    ? Icons.save_alt 
                                    : Icons.check_circle, 
                                  color: Colors.white
                                ),
                                label: Text(
                                  tripProvider.isOffline
                                    ? 'Save & Complete Later'
                                    : 'Submit Delivery Proof',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tripProvider.isOffline 
                                    ? Colors.orange
                                    : Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _completeTrip(isParcel: true);
                                },
                              ),
                            ],
                          ],
                        ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  tripProvider.clearDeliveryProofImage();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}



// Updated complete trip method with better offline and error handling
Future<void> _completeTrip({bool isParcel = false}) async {
  try {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    
    if (isParcel) {
      // For parcel trips, check if we have a photo
      if (tripProvider.deliveryProofImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please take a delivery proof photo'),
            backgroundColor: Colors.red,
          ),
        );
        _showDeliveryProofDialog(tripProvider);
        return;
      }
      
      // Call the API with serviceType specified
      try {
        await tripProvider.endTripAPI(serviceType: 'parcel');
      } catch (e) {
        // Check if it's a network error but we're continuing in offline mode
        if (tripProvider.hasNetworkError && tripProvider.hasArrivedAtDestination) {
          // Allow continuing to payment screen with a warning
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Trip marked as complete in offline mode. Delivery proof will be uploaded when connection is restored.'
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else if (!tripProvider.hasArrivedAtDestination) {
          // If not marked as complete, show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Failed to complete trip: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    } else {
      // Regular trip completion
      try {
        await tripProvider.endTripAPI();
      } catch (e) {
        // Check if it's a network error but we're continuing in offline mode
        if (tripProvider.hasNetworkError && tripProvider.hasArrivedAtDestination) {
          // Allow continuing with a warning
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Trip marked as complete in offline mode. Will be synced when connection is restored.'
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else if (!tripProvider.hasArrivedAtDestination) {
          // If not marked as complete, show error and return
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to complete trip: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // If we reach here, either the API call succeeded or we're continuing in offline mode
    if (mounted) {
      Navigator.pushReplacementNamed(
          context, AppDriverRoutes.paymentsuccesful,
          arguments: {
            'estimatedFare':
                widget.tripData['displayData']['estimatedFare']?.toString() ??
                    '0.00',
            'offlineMode': tripProvider.isOffline,
            'deliveryProofImagePath': tripProvider.deliveryProofImage?.path
          });
    }
  } catch (e) {
    log('Error completing trip: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  
  // Modify the button text to indicate photo requirement for parcel trips
  String _getButtonText(TripProvider tripProvider) {
    if (!tripProvider.hasPickedUpPassenger) {
      return 'Navigate to Pickup';
    } else {
      return isParcelTrip() 
          ? 'Take Delivery Photo & Complete' 
          : 'Complete Trip';
    }
  }


// Update the _startLocationUpdates method to handle mounted state properly
  void _startLocationUpdates() {
    _locationUpdateTimer?.cancel(); // Cancel any existing timer first

    if (!mounted) return; // Early return if widget is not mounted

    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        // Check mounted state before each update
        if (!mounted) {
          _locationUpdateTimer?.cancel();
          return;
        }

        try {
          final position = await LocationService.getCurrentPosition();

          // Check mounted again after async operation
          if (!mounted) {
            _locationUpdateTimer?.cancel();
            return;
          }

          final latLng = LatLng(position.latitude, position.longitude);
          final tripProvider =
              Provider.of<TripProvider>(context, listen: false);

          if (!mounted) return;

          await tripProvider.updateDriverLocationAPI(
              tripProvider.currentTripId!, latLng);

          // Final mounted check before UI updates
          if (!mounted) return;

          // Wrap UI updates in mounted checks
          if (tripProvider.routePoints.isNotEmpty &&
              tripProvider.currentRouteIndex <
                  tripProvider.routePoints.length - 1) {
            _updateCameraPosition(latLng);
            _updateDriverMarker(latLng, tripProvider);
          }
        } catch (e) {
          if (mounted) {
            log('Location update error: $e');
          }
        }
      },
    );
  }

// Update the dispose method to ensure proper cleanup
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _controller.future.then((controller) => controller.dispose());
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

// Improve camera updates with null safety and mounted checks
  void _updateCameraPosition(LatLng position) {
    if (!mounted) return;

    _controller.future.then((controller) {
      if (!mounted) return;

      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      if (tripProvider.routePoints.isEmpty ||
          tripProvider.currentRouteIndex >=
              tripProvider.routePoints.length - 1) {
        return;
      }

      final nextPoint =
          tripProvider.routePoints[tripProvider.currentRouteIndex + 1];
      final bearing = LocationService.calculateBearing(position, nextPoint);

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 19,
            tilt: 60,
            bearing: bearing,
          ),
        ),
      );
    }).catchError((error) {
      if (mounted) {
        log('Camera update error: $error');
      }
    });
  }

// Improve marker updates with null safety and mounted checks
  void _updateDriverMarker(LatLng position, TripProvider tripProvider) {
    if (!mounted) return;

    if (tripProvider.routePoints.isEmpty ||
        tripProvider.currentRouteIndex >= tripProvider.routePoints.length - 1) {
      return;
    }

    Set<Marker> updatedMarkers = Set.from(tripProvider.markers);
    updatedMarkers.removeWhere((m) => m.markerId.value == 'driver');

    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: LocationService.calculateBearing(position,
            tripProvider.routePoints[tripProvider.currentRouteIndex + 1]),
        flat: true,
      ),
    );

    tripProvider.setMarkers(updatedMarkers);
  }



// Add these handle errors with localized messages
  void _showErrorSnackBar(String errorKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('ride_tracker.errors.$errorKey')),
        backgroundColor: Colors.red,
      ),
    );
  }

  void emitEvent(String event, dynamic data) {
    socket?.emit(event, data);
  }

  void disconnect() {
    socket?.disconnect();
  }

  Future<void> storePassengerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // tripData se passenger details ID Fetch
    final String passengerId =
        widget.tripData['fullData']['user']['passengerDetails'];
    log('Passenger ID: $passengerId');
    // SharedPreferences mein store karna
    await prefs.setString('passenger_details_id', passengerId);
  }

  // Initialize trip
  Future<void> _initializeTrip() async {
    setState(() => _isLoading = true);

    try {
      // Set initial camera position
      _setInitialCameraPosition();

      // Get provider
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // Create route and markers
      await _createRoute(tripProvider);
      _createMarkers(tripProvider);

      // Set trip ID
      tripProvider.currentTripId = widget.tripData['fullData']['result']['_id'];
    } catch (e) {
      log('Error initializing trip: $e');
      _showErrorSnackBar('Error initializing trip: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startTrip() async {
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // Call start trip API
      await tripProvider.startTrip(
          widget.tripData['fullData']['result']['_id'],
          widget.tripData['pickupLocation'],
          widget.tripData['dropoffLocation']);

      // Start location updates with increased frequency
      _startLocationUpdates();

      // Update camera to follow driver with navigation mode
      _enableNavigationMode();
    } catch (e) {
      _showErrorSnackBar('Failed to start trip: $e');
    }
  }

  void _enableNavigationMode() {
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.tripData['driverCurrentLocation']['latitude'],
              widget.tripData['driverCurrentLocation']['longitude'],
            ),
            zoom: 18,
            tilt: 45,
            bearing: 0,
          ),
        ),
      );
    });
  }



  Future<bool> _isWithin500MetersOfDestination(
      LatLng currentLocation, LatLng destination) async {
    double distanceInMeters = await LocationUtils.calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    log('Distance to destination: $distanceInMeters meters');
    return distanceInMeters <= 500;
  }



  void _setInitialCameraPosition() {
    _initialCameraPosition = CameraPosition(
      target: LatLng(
        widget.tripData['driverCurrentLocation']['latitude'],
        widget.tripData['driverCurrentLocation']['longitude'],
      ),
      zoom: 13,
    );
  }

  Future<void> _createRoute(TripProvider tripProvider) async {
    List<LatLng> routePoints = await LocationService.getPolylinePoints(
      LatLng(
        widget.tripData['driverCurrentLocation']['latitude'],
        widget.tripData['driverCurrentLocation']['longitude'],
      ),
      widget.tripData['pickupLocation'],
    );
    routePoints.addAll(await LocationService.getPolylinePoints(
      widget.tripData['pickupLocation'],
      widget.tripData['dropoffLocation'],
    ));
    tripProvider.setRoutePoints(routePoints);

    Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        points: routePoints,
        width: 3,
      ),
    };
    tripProvider.setPolylines(polylines);
  }

  void _createMarkers(TripProvider tripProvider) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(
          widget.tripData['driverCurrentLocation']['latitude'],
          widget.tripData['driverCurrentLocation']['longitude'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'get_direction.markers.driver'.tr()),
      ),
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.tripData['pickupLocation'],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'get_direction.markers.pickup'.tr()),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: widget.tripData['dropoffLocation'],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'get_direction.markers.dropoff'.tr()),
      ),
    };
    tripProvider.setMarkers(markers);
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      log('Initiating Trip Cancellation Process', name: 'TRIP_CANCELLATION');
      log('Trip ID to Cancel: $tripId', name: 'TRIP_CANCELLATION');

      // Retrieve authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        log('Authentication Token Missing', name: 'TRIP_CANCELLATION_ERROR');
        throw Exception('No authentication token found');
      }

      log('Authentication Token Retrieved', name: 'TRIP_CANCELLATION');

      // Prepare API call
      final response = await http.put(
        Uri.parse('$baseUrl/driver-cancel/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Detailed logging of API response
      log(' API Response Details:', name: 'TRIP_CANCELLATION');
      log('Status Code: ${response.statusCode}', name: 'TRIP_CANCELLATION');
      log('Response Body: ${response.body}', name: 'TRIP_CANCELLATION');

      // Handle different response scenarios
      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          log('Trip Cancellation Successful', name: 'TRIP_CANCELLATION');
          log('Server Message: ${data['message']}', name: 'TRIP_CANCELLATION');

          // Emit socket event for cancellation
          _emitCancellationEvent(tripId);

          // notifyListeners();
          break;

        case 404:
          log('Trip Not Found', name: 'TRIP_CANCELLATION_ERROR');
          throw Exception('Trip not found');

        case 403:
          log('Unauthorized Cancellation Attempt',
              name: 'TRIP_CANCELLATION_ERROR');
          throw Exception('Not authorized to cancel this trip');

        default:
          log('Unexpected Error during Cancellation',
              name: 'TRIP_CANCELLATION_ERROR');
          throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // Comprehensive error logging
      log('Trip Cancellation Failed', name: 'TRIP_CANCELLATION_ERROR');
      log('Error: $e', name: 'TRIP_CANCELLATION_ERROR');
      log('Stack Trace: $stackTrace', name: 'TRIP_CANCELLATION_ERROR');

      // Optional: Show user-friendly error
      _showCancellationErrorDialog(e.toString());

      rethrow;
    }
  }

  void _emitCancellationEvent(String tripId) {
    try {
      log('Emitting Cancellation Socket Event', name: 'SOCKET_EVENT');
      socket?.emit('driver_cancel', {
        'tripId': tripId,
        'cancelledAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      log('Socket Event Emission Failed', name: 'SOCKET_EVENT_ERROR');
      log('Error: $e', name: 'SOCKET_EVENT_ERROR');
    }
  }

  void _showCancellationErrorDialog(String errorMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancellation Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(
                child: GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: tripProvider.markers,
                  polylines: tripProvider.polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              // Positioned(
              //   top: 40,
              //   left: 20,
              //   child: IconButton(
              //     icon: const Icon(Icons.menu),
              //     onPressed: () {
              //       Scaffold.of(context).openDrawer();
              //     },
              //   ),
              // ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.07,
                maxChildSize: 0.9,
                snap: true,
                snapSizes: const [0.07, 0.5, 0.9],
                controller: _sheetController,
                builder:
                    (BuildContext context, ScrollController scrollController) {
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                !tripProvider.hasPickedUpPassenger
                                    ? 'get_direction.trip_status.ride_arriving'
                                        .tr(args: [
                                        widget.tripData['timeToPickup']
                                      ])
                                    : 'get_direction.trip_status.heading_destination'
                                        .tr(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            UserContactCard(
                              userName: widget.tripData['displayData']
                                  ['username'],
                              userRating: widget.tripData['displayData']
                                  ['email'],
                              userImageUrl: widget.tripData['displayData']
                                      ['profilePicture'] ??
                                  "",
                              tripDistance:
                                  'Distance: ${widget.tripData['distanceToPickup']}',
                              userId: widget.tripData['fullData']['result']
                                  ['passenger'],
                              driverId: widget.tripData['driverUserId'],
                              phoneNumber: widget.tripData['fullData']['user']
                                  ['phone'],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'get_direction.trip_status.estimated_fare'
                                      .tr(),
                                  style: AppTextTheme.getLightTextTheme(context)
                                      .headlineMedium,
                                ),
                                Text(
                                  "\$${widget.tripData['displayData']['estimatedFare']}",
                                  style: AppTextTheme.getLightTextTheme(context)
                                      .headlineMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            GestureDetector(
                              onTap: () {
                                _handleButtonPress(tripProvider);
                              },
                              child: Container(
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
                                    _getButtonText(tripProvider),
                                    style: const TextStyle(
                                      color: AppColors.buttonColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                // Extract trip details
                                String? tripId = widget.tripData['fullData']
                                    ['result']?['_id'];

                                // Validate trip and driver IDs
                                if (tripId == null) {
                                  _showErrorSnackBar('Invalid trip details');
                                  return;
                                }

                                try {
                                  // Get authentication token
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final token = prefs.getString('token');

                                  if (token == null) {
                                    _showErrorSnackBar(
                                        'Authentication required');
                                    return;
                                  }

                                  // Perform API call
                                  final response = await http.put(
                                    Uri.parse(
                                        '$baseUrl/trip/driver-cancel/$tripId'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token',
                                    },
                                    // body: json.encode({
                                    //   'trip': driverId,
                                    // }),
                                  );

                                  // Handle response
                                  if (response.statusCode == 200) {
                                    final responseData =
                                        json.decode(response.body);

                                    // Navigate back to ride booking
                                    Navigator.pushReplacementNamed(
                                        context, AppDriverRoutes.rideBooking);

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(responseData['message'] ??
                                            'Trip cancelled successfully'),
                                        backgroundColor: AppColors.buttonColor,
                                      ),
                                    );
                                  } else {
                                    // Parse and show error message
                                    final errorMessage =
                                        json.decode(response.body)['message'] ??
                                            'Failed to cancel trip';
                                    _showErrorSnackBar(errorMessage);
                                    log('Trip Cancellation Error: $errorMessage');
                                  }
                                } catch (e) {
                                  _showErrorSnackBar(
                                      'Error cancelling trip: $e');
                                  log('Trip Cancellation Error: $e');
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'choose_driver.cancel_ride'.tr(),
                                    style:
                                        AppTextTheme.getLightTextTheme(context)
                                            .titleLarge,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
