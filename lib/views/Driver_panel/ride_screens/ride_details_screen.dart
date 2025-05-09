
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/location_utils.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/viewmodel/provider/map_provider.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> displayData;
  final Map<String, dynamic> fullData;

  const RideDetailsScreen({
    super.key,
    required this.displayData,
    required this.fullData,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final TextEditingController _fareController = TextEditingController();
  late IO.Socket socket;
  String _distanceToPickup = 'N/A';
  String _timeToPickup = 'N/A';
  LatLng? _driverCurrentLocation;
  String? _driverId;
  String? _driverUserId;
  
  // Add a periodic timer for checking trip status
  Timer? _statusCheckTimer;
  bool _isNavigatingToNextScreen = false;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<MapProvider>(context, listen: false);
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/night_theme.json')
        .then((value) => provider.setMapTheme(value));

    _initializeSocket();
    _initializeMap();
    _getDriverIdFromSharedPreferences();
    _fareController.text =
        widget.displayData['estimatedFare']?.toString() ?? '0';
  }


void _initializeSocket() {
  try {
    socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket.connect();

    socket.on('connect', (_) {
      log('Socket connected successfully');
      final tripId = widget.fullData['result']['_id'];
      socket.emit('join-driver-room', {'tripId': tripId});
    });

    // Enhanced error handling
    socket.on('connect_error', (error) {
      log('Socket connection error: $error');
      // Optionally show a user-friendly error
    });

    socket.on('trip_confirmed', (data) {
      log('Trip confirmed event received: $data');
      
      if (data['status'] == 'user_accepted' && 
          data['tripId'] == widget.fullData['result']['_id']) {
        
        if (!_isDisposed && mounted && !_isNavigatingToNextScreen) {
          _isNavigatingToNextScreen = true;
          
          // Uncomment and adjust navigation as needed
          Navigator.pushReplacementNamed(
            context, 
            AppDriverRoutes.getdirection,  // Confirm this is correct route
            arguments: {
              'displayData': widget.displayData,
              'fullData': widget.fullData,
              'tripDetails': data['details'],
            }
          );
        }
      }
    });
  } catch (e) {
    log('Error initializing Socket.IO: $e');
    // Consider showing a user-friendly error dialog
  }
}



  void _cleanupSocket() {
    try {
      socket.disconnect();
      socket.dispose();
      log('Socket cleaned up successfully');
    } catch (e) {
      log('Error cleaning up socket: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cleanupSocket();
    _fareController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  // Add a new method to periodically check the trip status
  void _startTripStatusCheck(String tripId) {
    // Cancel any existing timer
    _statusCheckTimer?.cancel();
    
    // Create a new timer that fires every 2 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isDisposed || _isNavigatingToNextScreen) {
        timer.cancel();
        return;
      }
      
      try {
        // Call the check-user-status API
        await _checkUserAcceptedStatus(tripId);
      } catch (e) {
        log('Error checking trip status: $e');
      }
    });
    
    log('Started periodic trip status check every 2 seconds');
  }
  
  // Add method to check if user has accepted the trip
  Future<void> _checkUserAcceptedStatus(String tripId) async {
    if (_isNavigatingToNextScreen) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/trip/check-user-status/$tripId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      log('Check user status response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // If user has accepted, navigate to next screen
        if (data['userAccepted'] == true && !_isNavigatingToNextScreen) {
          log('User has accepted the trip, navigating to next screen');
          
          _isNavigatingToNextScreen = true;
          _statusCheckTimer?.cancel();
          
          if (!_isDisposed && mounted) {
            final dataToPass = {
              'displayData': widget.displayData,
              'fullData': widget.fullData,
              'driverCurrentLocation': {
                'latitude': _driverCurrentLocation!.latitude,
                'longitude': _driverCurrentLocation!.longitude,
              },
              'pickupLocation': _parseLatLng(widget.fullData['result']['pickup']),
              'dropoffLocation':
                  _parseLatLng(widget.fullData['result']['destination']),
              'distanceToPickup': _distanceToPickup,
              'timeToPickup': _timeToPickup,
              'driverId': _driverId,
              'fareAmount': _fareController.text,
              'driverUserId': _driverUserId,
              'tripId': tripId,
              'tripStatus': 'accepted',
            };

            Navigator.pushReplacementNamed(
              context,
              AppDriverRoutes.showridesdetails,
              arguments: dataToPass,
            );
          }
        }
      }
    } catch (e) {
      log('Error checking user accepted status: $e');
    }
  }

Future<void> _acceptTrip(BuildContext context) async {
  if (_driverCurrentLocation == null || _driverId == null) {
    log('Driver location or ID is null');
    _showErrorDialog(
      context,
      'Error',
      'Could not get driver location. Please try again.',
    );
    return;
  }

  try {
    _showLoadingDialog(context);

    final tripId = widget.fullData['result']['_id'];
    final url = '${Constants.apiBaseUrl}/trip/accept/$tripId';

    // Ensure socket is connected
    if (!socket.connected) {
      socket.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final requestPayload = {
      'latitude': _driverCurrentLocation!.latitude,
      'longitude': _driverCurrentLocation!.longitude,
      'driverId': _driverId,
      'driverEstimatedFare': double.tryParse(_fareController.text) ??
          widget.displayData['estimatedFare'],
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    // Remove loading dialog
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      // Set up a completer to wait for user acceptance
      final userAcceptanceCompleter = Completer<bool>();

      // Listen for user acceptance
      socket.on('trip_confirmed', (data) {
        if (data['status'] == 'user_accepted' && 
            data['tripId'] == tripId) {
          userAcceptanceCompleter.complete(true);
        }
      });

      // Show waiting dialog
      _showWaitingForUserDialog(context);

      // Wait for user acceptance with timeout
      try {
        final userAccepted = await userAcceptanceCompleter.future
            .timeout(const Duration(minutes: 2), onTimeout: () {
          throw TimeoutException('User did not accept within 2 minutes');
        });

        // Dismiss waiting dialog
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Prepare data for navigation
        final dataToPass = {
          'displayData': widget.displayData,
          'fullData': widget.fullData,
          'driverCurrentLocation': {
            'latitude': _driverCurrentLocation!.latitude,
            'longitude': _driverCurrentLocation!.longitude,
          },
          'pickupLocation': _parseLatLng(widget.fullData['result']['pickup']),
          'dropoffLocation': _parseLatLng(widget.fullData['result']['destination']),
          'distanceToPickup': _distanceToPickup,
          'timeToPickup': _timeToPickup,
          'driverId': _driverId,
          'fareAmount': _fareController.text,
          'driverUserId': _driverUserId,
          'tripId': tripId,
          'tripStatus': 'accepted',
        };

        // Navigate to GetDirection screen
        Navigator.pushReplacementNamed(
          context,
          AppDriverRoutes.getdirection,
          arguments: dataToPass,
        );

      } on TimeoutException {
        // Handle timeout - user did not accept
        _showErrorDialog(
          context,
          'Timeout',
          'User did not accept the trip. Please try again.',
        );
      }
    } else {
      // Handle various error scenarios
      _handleErrorResponse(context, response);
    }
  } catch (e) {
    log('Error accepting trip: $e');
    _showErrorDialog(
      context,
      'Error',
      'An unexpected error occurred: ${e.toString()}',
    );
  }
}


// Helper method to show waiting dialog
void _showWaitingForUserDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            SizedBox(height: 16),
            Text('Waiting for user to accept the trip...'),
          ],
        ),
      );
    },
  );
}



// Helper method to handle error responses
void _handleErrorResponse(BuildContext context, http.Response response) {
  if (response.statusCode == 404) {
    _showErrorDialog(
      context,
      'Trip Not Found',
      'The requested trip could not be found.',
    );
  } else if (response.statusCode == 400) {
    final errorData = jsonDecode(response.body);
    _showErrorDialog(
      context,
      'Trip Unavailable',
      errorData['message'] ?? 'Trip is no longer available',
    );
  } else {
    _showErrorDialog(
      context,
      'Error',
      'Failed to accept trip. Status: ${response.statusCode}',
    );
  }
}



  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                const SizedBox(height: 15),
                Text(
                  'ride_details.dialog.processing'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTripCancelledDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'ride_details.dialog.trip_unavailable'.tr(),
            style: const TextStyle(color: Colors.amber),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                'ride_details.buttons.ok'.tr(),
                style: const TextStyle(color: Colors.amber),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTripNotFoundDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            'ride_details.dialog.trip_not_found'.tr(),
            style: const TextStyle(color: Colors.amber),
          ),
          content: Text(
            'ride_details.dialog.trip_no_longer_available'.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                'ride_details.buttons.ok'.tr(),
                style: const TextStyle(color: Colors.amber),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            title,
            style: const TextStyle(color: Colors.amber),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                'ride_details.buttons.ok'.tr(),
                style: const TextStyle(color: Colors.amber),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getDriverIdFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        _driverId = userData['driverDetails']['_id'];
        _driverUserId = userData['driverDetails']['user'];
      });
    }
  }

  Future<void> _initializeMap() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final controller = await _controller.future;
    controller.setMapStyle(mapProvider.mapTheme);

    final pickupLatLng =
        _parseLatLng(widget.fullData['result']['pickup'] ?? '0,0');
    final dropoffLatLng =
        _parseLatLng(widget.fullData['result']['destination'] ?? '0,0');

    _driverCurrentLocation = await _getDriverLocation();

    final distanceAndTime =
        await LocationUtils.calculateDriverToPickupDistanceAndTimeV2(
            _driverCurrentLocation!, pickupLatLng);

    setState(() {
      _distanceToPickup = distanceAndTime['distance'] ?? 'N/A';
      _timeToPickup = distanceAndTime['duration'] ?? 'N/A';
      _markers.addAll([
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupLatLng,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Pickup'),
        ),
        Marker(
          markerId: const MarkerId('dropoff'),
          position: dropoffLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Dropoff'),
        ),
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverCurrentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver'),
        ),
      ]);
    });

    final pointsDriverToPickup = await LocationUtils.getPolylinePoints(
        _driverCurrentLocation!, pickupLatLng);
    final pointsPickupToDropoff =
        await LocationUtils.getPolylinePoints(pickupLatLng, dropoffLatLng);

    setState(() {
      _polylines.addAll([
        Polyline(
          polylineId: const PolylineId('driver_to_pickup'),
          color: Colors.blue,
          points: pointsDriverToPickup,
          width: 5,
        ),
        Polyline(
          polylineId: const PolylineId('pickup_to_dropoff'),
          color: Colors.red,
          points: pointsPickupToDropoff,
          width: 5,
        ),
      ]);
    });

    final bounds = LocationUtils.calculateBounds(
        [_driverCurrentLocation!, pickupLatLng, dropoffLatLng]);
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Future<LatLng> _getDriverLocation() async {
    try {
      final position = await LocationUtils.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      log('Error getting driver location: $e');
      final pickupLatLng =
          _parseLatLng(widget.fullData['result']['pickup'] ?? '0,0');
      return pickupLatLng;
    }
  }

  LatLng _parseLatLng(String latLngString) {
    final parts = latLngString.split(',');
    if (parts.length != 2) {
      log('Invalid LatLng string: $latLngString');
      return const LatLng(0, 0);
    }
    try {
      return LatLng(double.parse(parts[0]), double.parse(parts[1]));
    } catch (e) {
      log('Error parsing LatLng: $e');
      return const LatLng(0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _parseLatLng(widget.fullData['result']['pickup'] ?? '0,0'),
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _initializeMap();
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.displayData['username'] ??
                                  'ride_details.user_info.unknown_user'.tr(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            Text(
                              widget.displayData['email'] ??
                                  'ride_details.user_info.no_email'.tr(),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _fareController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            prefixText: '\$',
                            border: UnderlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${'ride_details.location.distance_pickup'.tr()}$_distanceToPickup",
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${'ride_details.location.time_pickup'.tr()}$_timeToPickup",
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ride_details.location.pickup_point'.tr(),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.displayData['pickupAddress'] ??
                        'ride_details.location.not_specified'.tr(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ride_details.location.dropoff_point'.tr(),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.displayData['destinationAddress'] ??
                        'ride_details.location.not_specified'.tr(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'ride_details.buttons.accept'.tr(),
                          onPressed: () => _acceptTrip(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.amber, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}