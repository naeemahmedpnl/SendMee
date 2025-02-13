
import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';

import 'package:rideapp/views/Driver_panel/ride_screens/location.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/location_provider.dart';
import 'package:rideapp/views/Driver_panel/widgets/driver_contact_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  const _GetDirectionContent({Key? key, required this.tripData}) : super(key: key);

  @override
  _GetDirectionContentState createState() => _GetDirectionContentState();
}

class _GetDirectionContentState extends State<_GetDirectionContent> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  Timer? _locationUpdateTimer;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  bool _isLoading = false;
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeTrip();
    storePassengerId(); 
  }


Future<void> storePassengerId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // tripData se passenger details ID nikalna
  final String passengerId = widget.tripData['fullData']['user']['passengerDetails'];
  log('Passenger ID: $passengerId');
  // SharedPreferences mein store karna
  await prefs.setString('passenger_details_id', passengerId);
}


  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
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

  // Trip Action Methods
  Future<void> _startTrip() async {
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      
      // Call start trip API
      await tripProvider.startTrip(
        widget.tripData['fullData']['result']['_id'],
        widget.tripData['pickupLocation'],
        widget.tripData['dropoffLocation']
      );
      
      // Start location updates
      _startLocationUpdates();
      
    } catch (e) {
      _showErrorSnackBar('Failed to start trip: $e');
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        try {
          // Get current location
          final position = await LocationService.getCurrentPosition();
          final latLng = LatLng(position.latitude, position.longitude);
          
          // Update in provider
          final tripProvider = Provider.of<TripProvider>(context, listen: false);
          await tripProvider.updateDriverLocationAPI(
            tripProvider.currentTripId!,
            latLng
          );
          
          // Update camera
          _updateCameraPosition(latLng);
          
          // Check if near destination
          if (!tripProvider.isMovingToPickup) {
            bool isNear = LocationService.isNearPoint(
              latLng,
              widget.tripData['dropoffLocation'],
              threshold: 500
            );
            tripProvider.setIsNear500m(isNear);
            
            if (isNear) {
              _locationUpdateTimer?.cancel();
              await _completeTrip();
            }
          }
          
        } catch (e) {
          log('Location update error: $e');
        }
      },
    );
  }

  Future<void> _completeTrip() async {
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.endTripAPI();
      _endRide();
    } catch (e) {
      _showErrorSnackBar('Failed to complete trip: $e');
    }
  }

  void _endRide() {
    _locationUpdateTimer?.cancel();
    Navigator.pushReplacementNamed(context, AppDriverRoutes.paymentmethod, arguments: {
      'estimatedFare': widget.tripData['displayData']['estimatedFare']?.toString() ?? '0.00'
    });
  }

  // UI Helper Methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        'get_direction.errors.init_error'.tr(args: [message])
      ))
    );
  }

  String _getButtonText(TripProvider tripProvider) {
    if (!tripProvider.hasPickedUpPassenger) {
      return 'get_direction.buttons.navigate_pickup'.tr();
    } else if (tripProvider.isNear500m) {
      return 'get_direction.buttons.arrive'.tr();
    }
    return 'get_direction.buttons.navigate_destination'.tr();
  }



  void _handleButtonPress(TripProvider tripProvider) {
    if (!tripProvider.hasPickedUpPassenger) {
      _startTrip();
    } else if (tripProvider.isNear500m) {
      _completeTrip();
    }
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


  void _updateCameraPosition(LatLng position) {
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 16,
            tilt: 45,
            bearing: LocationService.calculateBearing(
                position,
                Provider.of<TripProvider>(context, listen: false).routePoints[
                    Provider.of<TripProvider>(context, listen: false)
                            .currentRouteIndex +
                        1]),
          ),
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
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
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
                                    ? 'get_direction.trip_status.ride_arriving'.tr(args: [widget.tripData['timeToPickup']])
                                    : 'get_direction.trip_status.heading_destination'.tr(),
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
                                      ['profilePicture'] ??  "",
                              tripDistance:
                                  'Distance: ${widget.tripData['distanceToPickup']}',
                              userId: widget.tripData['fullData']
                                  ['result']['passenger'],
                              driverId: widget.tripData['driverUserId'],
                              phoneNumber: widget.tripData['fullData']['user']['phone'],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'get_direction.trip_status.estimated_fare'.tr(),
                                  style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                                ),
                                Text(
                                  "\$${widget.tripData['displayData']['estimatedFare']}",
                                  style: AppTextTheme.getLightTextTheme(context).headlineMedium,
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
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: () {
                                String? tripId = widget.tripData['result']?['_id'];
                                if (tripId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('get_direction.errors.cancel_error'.tr())),
                                  );
                                  Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
                                } else {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppDriverRoutes.drivercancelride,
                                    arguments: {
                                      'tripId': tripId,
                                      'fullData': widget.tripData,
                                    },
                                  );
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
                                    'get_direction.buttons.cancel_ride'.tr(),
                                    style: AppTextTheme.getLightTextTheme(context).titleLarge,
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