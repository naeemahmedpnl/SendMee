import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:rideapp/models/user_model.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/utils/theme/map_theme_popup.dart';
import 'package:rideapp/viewmodel/provider/map_provider.dart';
import 'package:rideapp/viewmodel/provider/ridebook_provider.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/choose_driver.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/widgets/address_search.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/widgets/map_picker_screen.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ParcelBookScreen extends StatefulWidget {
  const ParcelBookScreen({super.key});

  @override
  State<ParcelBookScreen> createState() => ParcelBookScreenState();
}

class ParcelBookScreenState extends State<ParcelBookScreen>
    with TickerProviderStateMixin {
  User? userData;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  final double _bottomSheetHeight = 430.0;
  final TextEditingController _priceController = TextEditingController();

  // ADD NEW VARIABLES FOR DISTANCE AND TIME
  double _distanceInKm = 0.0;
  String _estimatedTime = '';

  late AnimationController _markerAnimationController;
  Animation<double>? _markerAnimation;
  bool _isDraggingMarker = false;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final rideProvider = Provider.of<RideProvider>(context, listen: false);
  //     rideProvider.clearAllData(); 

  //     setState(() {
  //       _markers.clear();
  //       _polylines.clear();
  //       _distanceInKm = 0.0;
  //       _estimatedTime = '';
  //       _priceController.clear();
  //     });

  //     _getCurrentLocation();
  //   });

  //   _markerAnimationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 500),
  //   );

  //   _initializeMarkerAnimation();
  //   _checkAndRequestLocationPermission();
  //   _loadMapTheme();
  //   _getCurrentLocation();
  // }


@override
void initState() {
  super.initState();
  _checkSharedPreferencesData(); // Add this line

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.clearAllData(); 

    setState(() {
      _markers.clear();
      _polylines.clear();
      _distanceInKm = 0.0;
      _estimatedTime = '';
      _priceController.clear();
    });

    _getCurrentLocation();
  });

  _markerAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  _initializeMarkerAnimation();
  _checkAndRequestLocationPermission();
  _loadMapTheme();
  _getCurrentLocation();
}

// Add this method to check SharedPreferences data
Future<void> _checkSharedPreferencesData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Log all relevant data
    log('Checking SharedPreferences data:');
    log('Token: ${prefs.getString('token')}');
    log('UserData: ${prefs.getString('userData')}');
    log('ServiceType: ${prefs.getString('serviceType')}');
    log('ParcelType: ${prefs.getString('parcelType')}');
    log('SenderName: ${prefs.getString('senderName')}');
    log('SenderPhone: ${prefs.getString('senderPhone')}');
    log('ReceiverName: ${prefs.getString('receiverName')}');
    log('ReceiverPhone: ${prefs.getString('receiverPhone')}');
    
    // Log all keys in SharedPreferences
    log('All SharedPreferences keys:');
    log('${prefs.getKeys().toString()}');
    
  } catch (e) {
    log('Error checking SharedPreferences: $e');
  }
}







  void _initializeMarkerAnimation() {
    _markerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.8),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _markerAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isDraggingMarker) {
        _markerAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed && _isDraggingMarker) {
        _markerAnimationController.forward();
      }
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Directly open location settings
        await Geolocator.openLocationSettings();
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // If user denies after request, open app settings
          await Geolocator.openAppSettings();
          return;
        }
      }

      // If permanently denied, directly open app settings
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      // If we have permission, get the current location
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _getCurrentLocation();
      }
    } catch (e) {
      log("Error checking location permission: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error accessing location services'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // THEME LOAD
  Future<void> _loadMapTheme() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final mapTheme = await DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/standard_theme.json');
    mapProvider.setMapTheme(mapTheme);
  }


  

  // GETS THE CURRENT LOCATION AND SETS IT AS THE PICKUP LOCATION
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackbar('ride_home.location_services_disabled'.tr());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackbar('ride_home.location_permissions_denied'.tr());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackbar(
            'ride_home.location_permissions_permanently_denied'.tr());
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng location = LatLng(position.latitude, position.longitude);
      String address = await _getAddressFromLatLng(location);

      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      rideProvider.setPickupLocation(address, location);

      _updateMapView();
    } catch (e) {
      log("Error getting current location: $e");
      _showErrorSnackbar('ride_home.unable_to_get_location'.tr());
    }
  }

  // FUNCTION TO FETCH PASSENGER _ID FROM SHARED PREFERENCES
  Future<String?> fetchPassengerId() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('user_Data')) {
      String? userDataJson = prefs.getString('user_Data');
      if (userDataJson != null) {
        Map<String, dynamic> userData = jsonDecode(userDataJson);
        return userData['passengerDetails']['_id'];
      }
    }
    return null;
  }

  // CREATE TRIP REQUEST

  Future<void> _createTripRequest(BuildContext context) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    try {
      final result = await rideProvider.createTripRequest();
      log("Trip creation result: $result");

      // Check if result contains the trip data
      if (result['result'] != null && result['result']['_id'] != null) {
        String tripId = result['result']['_id'];

        // Save trip ID to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentTripId', tripId);

        log("Saved trip ID to SharedPreferences: $tripId");

        // Navigate to choose driver screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChooseDriverScreen(tripId: tripId),
            ),
          );
        }
      } else {
        log("No trip ID found in response: $result");
        // Handle error case
      }
    } catch (e) {
      log("Error creating trip request: $e");
    }
  }

  // Future<void> _createTripRequest(BuildContext context) async {
  //   final rideProvider = Provider.of<RideProvider>(context, listen: false);

  //   try {
  //     final result = await rideProvider.createTripRequest();
  //     if (result['success'] == true && result['tripId'] != null) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ChooseDriverScreen(tripId: result['tripId']!),
  //         ),
  //       );
  //     } else {}
  //   } catch (e) {
  //     log("Error creating trip request: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<RideProvider, MapProvider>(
        builder: (context, rideProvider, mapProvider, child) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: rideProvider.pickupLatLng ??
                      const LatLng(19.4326, -99.1332),
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  controller.setMapStyle(mapProvider.mapTheme);
                  _updateMapView();
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onTap: (LatLng latLng) => _onMapTapped(latLng, rideProvider),
              ),
              Positioned(
                top: 45,
                right: 10,
                child: MapThemePopup(controller: _controller),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _bottomSheetHeight,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0.55,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLocationField(
                            context,
                            'ride_home.pickup_location'.tr(),
                            rideProvider.pickupAddress,
                            (address, latLng) {
                              rideProvider.setPickupLocation(address, latLng);
                              _updateMapView();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Dropoff Field
                          _buildLocationField(
                            context,
                            'ride_home.dropoff_location'.tr(),
                            rideProvider.dropoffAddress,
                            (address, latLng) {
                              rideProvider.setDropoffLocation(address, latLng);
                              _updateMapView();
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                              text: "Add Location Manually",
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapPickerScreen(
                                      title: 'ride_home.dropoff_location'.tr(),
                                      key: const ValueKey('dropoff'),
                                    ),
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    // Only set dropoff location
                                    rideProvider.setDropoffLocation(
                                        result['address'], result['latLng']);
                                    _updateMapView();
                                  });
                                }
                              })

                          // Choose on map button
                          // InkWell(
                          //   onTap: () async {
                          //     final result = await Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => MapPickerScreen(
                          //           title: 'ride_home.dropoff_location'.tr(),
                          //           key: const ValueKey('dropoff'),
                          //         ),
                          //       ),
                          //     );

                          //     if (result != null) {
                          //       setState(() {
                          //         // Only set dropoff location
                          //         rideProvider.setDropoffLocation(
                          //             result['address'], result['latLng']);
                          //         _updateMapView();
                          //       });
                          //     }
                          //   },
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       const Icon(
                          //         Icons.map_outlined,
                          //         size: 20,
                          //         color: AppColors.buttonColor,
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Text(
                          //         'ride_home.add_location_manually'.tr(),
                          //         style: AppTextTheme.getLightTextTheme(context)
                          //             .titleLarge
                          //             ?.copyWith(
                          //               color: AppColors.backgroundLight,
                          //             ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          ,
                          Text('ride_home.price'.tr(),
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'ride_home.estimated_fare'.tr(),
                              hintText: 'Calculating...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelStyle: AppTextTheme.getLightTextTheme(context)
                                  .bodySmall,
                              prefixIcon: const Icon(Icons.attach_money,
                                  color: AppColors.buttonColor),
                            ),
                            style: AppTextTheme.getLightTextTheme(context)
                                .bodyMedium,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          // ADD DISTANCE AND TIME INFORMATION
                          Text(
                            '${'ride_home.distance'.tr()} ${_distanceInKm.toStringAsFixed(2)} km',
                            style: AppTextTheme.getLightTextTheme(context)
                                .bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ride_home.estimated_time'
                                .tr(args: [_estimatedTime]),
                            style: AppTextTheme.getLightTextTheme(context)
                                .bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                              text: "ride_home.book_ride".tr(),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.chooseDriver);
                                _createTripRequest(context);
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationField(
    BuildContext context,
    String label,
    String address,
    Function(String, LatLng) onAddressSelected,
  ) {
    return Column(
      children: [
        TextField(
          style: AppTextTheme.getLightTextTheme(context).titleMedium,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextTheme.getLightTextTheme(context).bodySmall,
            prefixIcon: const Icon(
              Icons.location_on,
              color: AppColors.buttonColor,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          readOnly: true,
          controller: TextEditingController(text: address),
          onTap: () async {
            // Existing search functionality
            final result = await showSearch<Map<String, dynamic>>(
              context: context,
              delegate: AddressSearch(),
            );
            if (result != null &&
                result['address'] != null &&
                result['latLng'] != null) {
              onAddressSelected(result['address'], result['latLng']);
            }
          },
        ),
      ],
    );
  }

  // HANDLES MAP TAP EVENTS
  void _onMapTapped(LatLng latLng, RideProvider rideProvider) async {
    if (rideProvider.dropoffLatLng == null) {
      String address = await _getAddressFromLatLng(latLng);
      rideProvider.setDropoffLocation(address, latLng);
      _updateMapView();
    }
  }

  // CONVERTS LATLNG TO A HUMAN-READABLE ADDRESS
  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      log("Error during reverse geocoding: $e");
    }
    return 'ride_home.default_address'
        .tr(args: [latLng.latitude.toString(), latLng.longitude.toString()]);
  }

  // UPDATES THE MAP VIEW WITH MARKERS AND POLYLINES
  void _updateMapView() {
    if (!mounted) return;

    setState(() {
      _markers.clear();
      _polylines.clear();

      final rideProvider = Provider.of<RideProvider>(context, listen: false);

      // Add pickup marker if exists
      if (rideProvider.pickupLatLng != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: rideProvider.pickupLatLng!,
            draggable: true,
            onDragStart: (LatLng position) {
              setState(() {
                _isDraggingMarker = true;
                _markerAnimationController.forward();
              });
            },
            onDrag: (LatLng position) {
              // Optional: Update any UI elements while dragging
            },
            onDragEnd: (LatLng newPosition) async {
              setState(() {
                _isDraggingMarker = false;
                _markerAnimationController.reset();
              });

              // Get new address for the updated position
              String address = await _getAddressFromLatLng(newPosition);
              rideProvider.setPickupLocation(address, newPosition);

              // If dropoff exists, update route
              if (rideProvider.dropoffLatLng != null) {
                _getPolyline(newPosition, rideProvider.dropoffLatLng!);
                _calculateDistanceAndTime(
                    newPosition, rideProvider.dropoffLatLng!);
              }
            },
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: 'ride_home.pickup_marker'.tr()),
          ),
        );
      }

      // Add dropoff marker if exists
      if (rideProvider.dropoffLatLng != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('dropoff'),
            position: rideProvider.dropoffLatLng!,
            draggable: true,
            onDragStart: (LatLng position) {
              setState(() {
                _isDraggingMarker = true;
                _markerAnimationController.forward();
              });
            },
            onDrag: (LatLng position) {
              // Optional: Update any UI elements while dragging
            },
            onDragEnd: (LatLng newPosition) async {
              setState(() {
                _isDraggingMarker = false;
                _markerAnimationController.reset();
              });

              // Get new address for the updated position
              String address = await _getAddressFromLatLng(newPosition);
              rideProvider.setDropoffLocation(address, newPosition);

              // Update route with new dropoff location
              if (rideProvider.pickupLatLng != null) {
                _getPolyline(rideProvider.pickupLatLng!, newPosition);
                _calculateDistanceAndTime(
                    rideProvider.pickupLatLng!, newPosition);
              }
            },
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'ride_home.dropoff_marker'.tr()),
          ),
        );
      }

      // Draw route if both points exist (complete route)
      if (rideProvider.isRouteComplete) {
        _getPolyline(rideProvider.pickupLatLng!, rideProvider.dropoffLatLng!);
        _fitBounds(rideProvider.pickupLatLng!, rideProvider.dropoffLatLng!);
        _calculateDistanceAndTime(
            rideProvider.pickupLatLng!, rideProvider.dropoffLatLng!);
      } else if (rideProvider.pickupLatLng != null) {
        // If only pickup exists, center map on pickup
        _controller.future.then((controller) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(rideProvider.pickupLatLng!, 15),
          );
        });
      }

      // Create custom animated marker overlay if dragging
      if (_isDraggingMarker) {
        OverlayEntry overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            left: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _markerAnimation!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _markerAnimation!.value,
                  child: Image.asset(
                    'assets/images/map.png',
                    width: 50,
                    height: 50,
                  ),
                );
              },
            ),
          ),
        );

        // Remove overlay when drag ends
        Future.delayed(const Duration(milliseconds: 500), () {
          overlayEntry.remove();
        });
      }
    });

    // Corrected error handling for map controller
    _controller.future.catchError((error) {
      log('Error updating map view: $error');
      _showErrorSnackbar('ride_home.map_update_error'.tr());
      throw error; 
    }).then((controller) {

      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      if (rideProvider.pickupLatLng != null && !rideProvider.isRouteComplete) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(rideProvider.pickupLatLng!, 15),
        );
      }
    });
  }

  // FETCHES AND DRAWS THE POLYLINE BETWEEN PICKUP AND DROPOFF LOCATION
  Future<void> _getPolyline(LatLng pickup, LatLng dropoff) async {
    PolylinePoints polylinePoints = PolylinePoints();

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
          request: PolylineRequest(
              origin: PointLatLng(pickup.latitude, pickup.longitude),
              destination: PointLatLng(dropoff.latitude, dropoff.longitude),
              mode: TravelMode.driving));

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ));
        });

        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.newLatLngBounds(
            _getBounds(polylineCoordinates),
            100.0,
          ));
        });
      } else {
        _showErrorSnackbar('ride_home.route_not_found'.tr());
      }

      if (result.status == 'ZERO_RESULTS') {
        _showErrorSnackbar('ride_home.no_route_between_locations'.tr());
      } else if (result.status != 'OK') {
        _showErrorSnackbar('ride_home.route_fetch_error'
            .tr(args: [result.errorMessage ?? 'Unknown error']));
      }
    } catch (e) {
      _showErrorSnackbar('ride_home.error'.tr(args: [e.toString()]));
    }
  }

  // FITS THE MAP BOUNDS TO SHOW BOTH PICKUP AND DROPOFF LOCATIONS
  void _fitBounds(LatLng pickup, LatLng dropoff) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < dropoff.latitude ? pickup.latitude : dropoff.latitude,
        pickup.longitude < dropoff.longitude
            ? pickup.longitude
            : dropoff.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > dropoff.latitude ? pickup.latitude : dropoff.latitude,
        pickup.longitude > dropoff.longitude
            ? pickup.longitude
            : dropoff.longitude,
      ),
    );

    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
  }

  // SHOWS AN ERROR SNACKBAR
  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    _controller.future.then((controller) => controller.dispose());
    super.dispose();
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (LatLng point in points) {
      if (minLat == null || point.latitude < minLat) minLat = point.latitude;
      if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
      if (minLng == null || point.longitude < minLng) minLng = point.longitude;
      if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void _calculateDistanceAndTime(LatLng pickup, LatLng dropoff) async {
    try {
      // First try Google Distance Matrix API
      final distance = await _calculateGoogleMapsDistance(
          "${pickup.latitude},${pickup.longitude}",
          "${dropoff.latitude},${dropoff.longitude}");

      // If Google API fails, fallback to Geolocator
      if (distance == null) {
        _calculateDirectDistance(pickup, dropoff);
        return;
      }

      _distanceInKm = distance;

      // Calculate estimated fare
      _calculateEstimatedFare(_distanceInKm);
      // Calculate time based on average speed (40 km/h)
      double averageSpeedKmPerHour = 40;
      double timeInHours = _distanceInKm / averageSpeedKmPerHour;

      int hours = timeInHours.floor();
      int minutes = ((timeInHours - hours) * 60).round();

      setState(() {
        if (hours > 0) {
          _estimatedTime = '${hours}h ${minutes}m';
        } else {
          _estimatedTime = '${minutes}m';
        }
      });
    } catch (e) {
      log("Error calculating distance: $e");
      // Fallback to direct distance calculation
      _calculateDirectDistance(pickup, dropoff);
    }
  }

  Future<double?> _calculateGoogleMapsDistance(
      String pickup, String destination) async {
    var apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    final url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$pickup&destinations=$destination&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' &&
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          // Distance comes in meters, convert to kilometers
          return data['rows'][0]['elements'][0]['distance']['value'] / 1000.0;
        }
      }
      return null;
    } catch (e) {
      log("Error fetching distance from Google Maps API: $e");
      return null;
    }
  }

  void _calculateDirectDistance(LatLng pickup, LatLng dropoff) {
    double distanceInMeters = Geolocator.distanceBetween(
      pickup.latitude,
      pickup.longitude,
      dropoff.latitude,
      dropoff.longitude,
    );

    _distanceInKm = distanceInMeters / 1000;

    // Calculate estimated fare
    _calculateEstimatedFare(_distanceInKm);

    // Estimate time based on average speed (40 km/h)
    double averageSpeedKmPerHour = 40;
    double timeInHours = _distanceInKm / averageSpeedKmPerHour;

    int hours = timeInHours.floor();
    int minutes = ((timeInHours - hours) * 60).round();

    setState(() {
      if (hours > 0) {
        _estimatedTime = '${hours}h ${minutes}m';
      } else {
        _estimatedTime = '${minutes}m';
      }
    });
  }

  Future<void> checkWalletAndProceed(
      BuildContext context, double estimatedFare) async {
    // Retrieve wallet balance
    final walletBalance = await showbalance();

    if (walletBalance >= estimatedFare) {
      // Enough balance, proceed with ride booking
      Navigator.pop(context);
      // _createTripRequest(context);
    } else {
      // Insufficient balance, navigate to wallet screen
      Navigator.pop(context);
      Navigator.pushNamed(context, AppRoutes.walletScreen);
    }
  }

  void _showPaymentOptionsDialog(
      BuildContext context, double estimatedFare) async {
    // Get wallet balance before showing the dialog
    final walletBalance = await showbalance();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payment,
              size: 60,
              color: AppColors.buttonColor,
            ),
            const SizedBox(height: 20),
            Text(
              'ride_home.payment_dialog.low_fare_title'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'ride_home.payment_dialog.low_fare_message'.tr(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'ride_home.payment_dialog.current_balance'
                  .tr()
                  .replaceAll('{0}', walletBalance.toStringAsFixed(2)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'ride_home.payment_dialog.payment_methods.cash'.tr(),
                    onPressed: () {
                      Navigator.pop(context);
                      _createTripRequest(context);
                    },
                    borderRadius: 44,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text:
                        'ride_home.payment_dialog.payment_methods.wallet'.tr(),
                    onPressed: () =>
                        checkWalletAndProceed(context, estimatedFare),
                    borderRadius: 44,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<double> _calculateEstimatedFare(double distanceInKm) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    // Base calculation parameters
    final baseFare = rideProvider.rates?.baseFare ?? 5.0;
    final vehicleRate = rideProvider.rates?.vehicleRate ?? 5.0;
    final adjustmentFare = rideProvider.rates?.adjustmentFare ?? 0.0009;

    // Fare calculation formula
    final estimatedFare =
        baseFare + (distanceInKm * vehicleRate * (1 + adjustmentFare));

    // Update price controller and provider
    _priceController.text = estimatedFare.toStringAsFixed(2);
    rideProvider.setEstimatedFare(_priceController.text);

    // Show payment options dialog for low-cost rides
    if (estimatedFare < 10) {
      _showPaymentOptionsDialog(context, estimatedFare);
    }

    return estimatedFare;
  }

  Future<double> showbalance() async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the saved user data
    String? userDataJson = prefs.getString('userData');

    if (userDataJson != null) {
      try {
        // Parse the JSON string back to a Map
        Map<String, dynamic> userData = jsonDecode(userDataJson);

        // Extract wallet balance
        // In this case, wallet balance is directly in the root of the user data
        return (userData['walletBalance'] as num).toDouble();
      } catch (e) {
        ('Error retrieving wallet balance: $e');
        return 0.0; // Return 0 if there's an error
      }
    }

    return 0.0; // Return 0 if no user data is found
  }
}
