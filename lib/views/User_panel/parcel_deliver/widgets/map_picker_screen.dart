import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/map_provider.dart';
import 'package:sendme/widgets/custom_button.dart';

class MapPickerScreen extends StatefulWidget {
  final String title;

  const MapPickerScreen({
    super.key,
    required this.title,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? mapController;
  String selectedAddress = "Move map to select dropoff location";
  LatLng currentCenter = const LatLng(-25.7479, 28.2293); 
  bool _isMoving = false;

  // Pin Animation variables
  late AnimationController _pinController;
  Animation<double>? _pinAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller first
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Then initialize the animation
    _initializeAnimation();
    _loadMapTheme();
    _getCurrentLocation();
  }

  // THEME LOAD
  Future<void> _loadMapTheme() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final mapTheme = await DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/night_theme.json');
    mapProvider.setMapTheme(mapTheme);
  }

  void _initializeAnimation() {
    _pinAnimation = TweenSequence<double>([
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
        parent: _pinController,
        curve: Curves.easeInOut,
      ),
    );

    // Add status listener for continuous animation
    _pinController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isMoving) {
        _pinController.reverse();
      } else if (status == AnimationStatus.dismissed && _isMoving) {
        _pinController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      LatLng location = LatLng(position.latitude, position.longitude);

      setState(() {
        currentCenter = location;
      });

      // Animate camera to current location
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );

      // Get address for current location
      _getAddressFromLatLng(location);
      
      log('Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      log("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, 
          style: AppTextTheme.getDarkTextTheme(context).titleLarge),
        backgroundColor: AppColors.backgroundDark,
      ),
      body: Stack(
        children: [
          // Static Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentCenter,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              _loadMapTheme();
            },
            onCameraMove: (position) {
              currentCenter = position.target;
              if (!_isMoving) {
                _isMoving = true;
                _pinController.forward();
              }
            },
            onCameraIdle: () {
              _isMoving = false;
              _pinController.reset();
              _getAddressFromLatLng(currentCenter);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false, // Disable default map toolbar
          ),

          // Help Text and Animated Pin
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    'ride_home.move_map'.tr(),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                if (_pinAnimation != null)
                  AnimatedBuilder(
                    animation: _pinAnimation!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pinAnimation!.value,
                        child: Image.asset(
                          'assets/images/map.png',
                          width: 50,
                          height: 50,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Custom Zoom Controls
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in_button',
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out_button',
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black),
                  onPressed: () {
                    mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
              ],
            ),
          ),

          // Location Box
          Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selected Location',
                    style: AppTextTheme.getLightTextTheme(context).titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(selectedAddress,
                      style: AppTextTheme.getLightTextTheme(context).titleLarge),
                ],
              ),
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: CustomButton(
              text: "Confirm Location",
              onPressed: () {
                Navigator.pop(context, {
                  'address': selectedAddress,
                  'latLng': currentCenter,
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          selectedAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}"
                  .replaceAll(RegExp(r'null,?\s*'), '') // Remove null values
                  .replaceAll(RegExp(r',\s*,'), ',') // Clean up multiple commas
                  .trim()
                  .replaceAll(RegExp(r',$'), ''); // Remove trailing comma
        });
      }
    } catch (e) {
      log("Error getting address: $e");
      setState(() {
        selectedAddress =
            "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });
    }
  }
}