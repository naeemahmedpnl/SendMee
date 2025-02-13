

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rideapp/utils/constant/api_base_url.dart';
import 'package:rideapp/utils/location_utils.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/viewmodel/provider/map_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
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

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
 
    final provider = Provider.of<MapProvider>(context, listen: false);
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/standard_theme.json')
        .then((value) => provider.setMapTheme(value));

    _initializeSocket();
    _initializeMap();
    _getDriverIdFromSharedPreferences();
    _fareController.text =
        widget.displayData['estimatedFare']?.toString() ?? '0';
  }

void _initializeSocket() {
  log('RideDetailsScreen - Initializing Socket.IO');
  try {
    socket = IO.io(Constants.apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,  // Changed to true
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket.connect();

    socket.on('connect', (_) {
      log('RideDetailsScreen - Socket connected');
    });

    socket.on('user_accepted', (data) {
      log('RideDetailsScreen - User accepted the ride: $data');
      if (!_isDisposed && mounted) {
        Navigator.pushReplacementNamed(
          context, 
          AppDriverRoutes.showridesdetails
        );
      }
    });

    socket.on('disconnect', (_) {
      log('RideDetailsScreen - Socket disconnected');
      if (!_isDisposed) {
        socket.connect();  // Try to reconnect if not disposed
      }
    });

    socket.on('error', (error) {
      log('RideDetailsScreen - Socket error: $error');
    });
  } catch (e) {
    log('RideDetailsScreen - Error initializing Socket.IO: $e');
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
    _isDisposed = true; // Set flag before disposal
    _cleanupSocket();
    _fareController.dispose();
    super.dispose();
  }

  Future<void> _acceptTrip(BuildContext context) async {
  if (_driverCurrentLocation == null || _driverId == null) {
    if (!_isDisposed && mounted) {
      _showErrorDialog(
        context,
        'Error',
        'Could not get driver location. Please try again.',
      );
    }
    return;
  }

  try {
    // Show loading dialog first
    _showLoadingDialog(context);

    final tripId = widget.fullData['result']['_id'];
    log('Trip ID: $tripId');
    final url = '${Constants.apiBaseUrl}/trip/accept/$tripId';

    // Make sure socket is connected before making API call
    if (!socket.connected) {
      socket.connect();
      // Wait briefly for socket to connect
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': _driverCurrentLocation!.latitude,
        'longitude': _driverCurrentLocation!.longitude,
        'driverId': _driverId,
        'driverEstimatedFare': double.tryParse(_fareController.text) ?? 
            widget.displayData['estimatedFare'],
      }),
    );

    // Remove loading dialog
    if (!_isDisposed && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (_isDisposed) return;

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      log('Trip accepted successfully: $responseData');

      // Emit the event before navigation
      socket.emit('trip_accepted', responseData['tripDetails']);

      // Add a small delay before navigation to ensure socket event is sent
      await Future.delayed(const Duration(milliseconds: 300));

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

        // Don't disconnect socket before navigation
        Navigator.pushReplacementNamed(
          context,
          AppDriverRoutes.getdirection,
          arguments: dataToPass,
        );
      }
    } else {
      // Handle error responses...
      if (response.statusCode == 404) {
        await _showTripNotFoundDialog(context);
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        await _showTripCancelledDialog(
          context, 
          errorData['message'] ?? 'Trip is no longer available'
        );
        Navigator.pop(context);
      } else {
        _showErrorDialog(
          context,
          'Error',
          'Failed to accept trip. Please try again.',
        );
      }
    }
  } catch (e) {
    log('Error accepting trip: $e');
    if (!_isDisposed && mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorDialog(
        context,
        'Error',
        'An error occurred. Please try again.',
      );
    }
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
                        style:
                            const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${'ride_details.location.time_pickup'.tr()}$_timeToPickup",
                        style:
                            const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ride_details.location.pickup_point'.tr(),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.displayData['pickupAddress'] ??
                        'ride_details.location.not_specified'.tr(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ride_details.location.dropoff_point'.tr(),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
