// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sendme/viewmodel/provider/ridebook_provider.dart';
// import 'package:sendme/viewmodel/provider/map_provider.dart';
// import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:sendme/views/User_panel/RideBookScreens/widgets/pickup_location.dart';
// import 'package:sendme/utils/theme/map_theme_popup.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class RideBookingScreen extends StatefulWidget {
//   @override
//   _RideBookingScreenState createState() => _RideBookingScreenState();
// }

// class _RideBookingScreenState extends State<RideBookingScreen> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   PolylinePoints polylinePoints = PolylinePoints();
//   double _bottomSheetHeight = 400.0;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//     _loadMapTheme();
//   }

//   @override
//   void dispose() {
//     _controller.future.then((controller) => controller.dispose());
//     super.dispose();
//   }

//   Future<void> _loadMapTheme() async {
//     final mapProvider = Provider.of<MapProvider>(context, listen: false);
//     final mapTheme = await DefaultAssetBundle.of(context)
//         .loadString('assets/map_theme/night_theme.json');
//     mapProvider.setMapTheme(mapTheme);
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         _showErrorSnackbar(
//             'Location services are disabled. Please enable the services');
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           _showErrorSnackbar('Location permissions are denied');
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         _showErrorSnackbar(
//             'Location permissions are permanently denied, we cannot request permissions.');
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       LatLng location = LatLng(position.latitude, position.longitude);
//       String address = await _getAddressFromLatLng(location);

//       final rideProvider = Provider.of<RideProvider>(context, listen: false);
//       rideProvider.setPickupLocation(address, location);

//       _updateMapView();
//     } catch (e) {
//       print("Error getting current location: $e");
//       _showErrorSnackbar('Unable to get current location. Please try again.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Consumer2<RideProvider, MapProvider>(
//         builder: (context, rideProvider, mapProvider, child) {
//           return Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: rideProvider.pickupLatLng ??
//                       const LatLng(24.8607, 67.0011),
//                   zoom: 15,
//                 ),
//                 onMapCreated: (GoogleMapController controller) {
//                   _controller.complete(controller);
//                   controller.setMapStyle(mapProvider.mapTheme);
//                   _updateMapView();
//                 },
//                 markers: _markers,
//                 polylines: _polylines,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 onTap: (LatLng latLng) => _onMapTapped(latLng, rideProvider),
//               ),
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: MapThemePopup(controller: _controller),
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   height: _bottomSheetHeight,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(20)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.5),
//                         spreadRadius: 5,
//                         blurRadius: 7,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           _buildLocationField(
//                             context,
//                             'Pickup Location',
//                             rideProvider.pickupAddress,
//                             (address, latLng) {
//                               rideProvider.setPickupLocation(address, latLng);
//                               _updateMapView();
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           _buildLocationField(
//                             context,
//                             'Dropoff Location',
//                             rideProvider.dropoffAddress,
//                             (address, latLng) {
//                               rideProvider.setDropoffLocation(address, latLng);
//                               _updateMapView();
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           Text('200'),
//                           const SizedBox(height: 8),
//                           TextField(
//                             // controller: _priceController,
//                             keyboardType: const TextInputType.numberWithOptions(
//                                 decimal: true),
//                             decoration: const InputDecoration(
//                               labelText: 'Enter Price',
//                               border: OutlineInputBorder(),
//                             ),
//                             onTap: () {
//                               setState(() {
//                                 _bottomSheetHeight = 400.0;
//                               });
//                             },
//                             onEditingComplete: () {
//                               setState(() {
//                                 _bottomSheetHeight = 300.0;
//                               });
//                               FocusScope.of(context).unfocus();
//                             },
//                           ),
//                           const SizedBox(height: 24),
//                           ElevatedButton(
//                             child: const Text('Ride Book'),
//                             onPressed: rideProvider.isRouteComplete
//                                 ? () {
//                                     Navigator.pushNamed(
//                                         context, AppRoutes.rideBook);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text(
//                                               'Ride booked successfully!')),
//                                     );
//                                   }
//                                 : null,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLocationField(
//     BuildContext context,
//     String label,
//     String address,
//     Function(String, LatLng) onAddressSelected,
//   ) {
//     return TextField(
//       style: const TextStyle(fontSize: 16, color: Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         suffixIcon: const Icon(Icons.search),
//         border: const OutlineInputBorder(),
//       ),
//       readOnly: true,
//       controller: TextEditingController(text: address),
//       onTap: () async {
//         final result = await showSearch<Map<String, dynamic>>(
//           context: context,
//           delegate: AddressSearch(),
//         );
//         if (result != null &&
//             result['address'] != null &&
//             result['latLng'] != null) {
//           onAddressSelected(result['address'], result['latLng']);
//         }
//       },
//     );
//   }

//   void _onMapTapped(LatLng latLng, RideProvider rideProvider) async {
//     if (rideProvider.dropoffLatLng == null) {
//       String address = await _getAddressFromLatLng(latLng);
//       rideProvider.setDropoffLocation(address, latLng);
//       _updateMapView();
//     }
//   }

//   Future<String> _getAddressFromLatLng(LatLng latLng) async {
//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
//       }
//     } catch (e) {
//       print("Error during reverse geocoding: $e");
//     }
//     return "Address at ${latLng.latitude}, ${latLng.longitude}";
//   }

//   void _updateMapView() {
//     if (!mounted) return;

//     setState(() {
//       _markers.clear();
//       _polylines.clear();

//       final rideProvider = Provider.of<RideProvider>(context, listen: false);

//       if (rideProvider.pickupLatLng != null) {
//         _markers.add(Marker(
//           markerId: const MarkerId('pickup'),
//           position: rideProvider.pickupLatLng!,
//           infoWindow: const InfoWindow(title: 'Pickup'),
//           icon:
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ));
//       }

//       if (rideProvider.dropoffLatLng != null) {
//         _markers.add(Marker(
//           markerId: const MarkerId('dropoff'),
//           position: rideProvider.dropoffLatLng!,
//           infoWindow: const InfoWindow(title: 'Dropoff'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ));
//       }

//       if (rideProvider.isRouteComplete) {
//         _getPolyline(rideProvider.pickupLatLng!, rideProvider.dropoffLatLng!);
//         _fitBounds(rideProvider.pickupLatLng!, rideProvider.dropoffLatLng!);
//       } else if (rideProvider.pickupLatLng != null) {
//         _controller.future.then((controller) {
//           controller.animateCamera(
//               CameraUpdate.newLatLngZoom(rideProvider.pickupLatLng!, 15));
//         });
//       }
//     });
//   }

//   Future<void> _getPolyline(LatLng pickup, LatLng dropoff) async {
//     PolylinePoints polylinePoints = PolylinePoints();

//     try {
//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//           googleApiKey: 'AIzaSyBdbZLVOJf6x4kUv2xPEWZOYOVBifSBzwc',
//           request: PolylineRequest(
//               origin: PointLatLng(pickup.latitude, pickup.longitude),
//               destination: PointLatLng(dropoff.latitude, dropoff.longitude),
//               mode: TravelMode.driving));

//       if (result.points.isNotEmpty) {
//         List<LatLng> polylineCoordinates = result.points
//             .map((point) => LatLng(point.latitude, point.longitude))
//             .toList();

//         setState(() {
//           _polylines.add(Polyline(
//             polylineId: const PolylineId('route'),
//             color: Colors.blue,
//             points: polylineCoordinates,
//             width: 5,
//           ));
//         });

//         _controller.future.then((controller) {
//           controller.animateCamera(CameraUpdate.newLatLngBounds(
//             _getBounds(polylineCoordinates),
//             100.0, // padding
//           ));
//         });
//       } else {
//         _showErrorSnackbar(
//             'Unable to find a route between the selected locations.');
//       }

//       if (result.status == 'ZERO_RESULTS') {
//         _showErrorSnackbar('No route found between the selected locations.');
//       } else if (result.status != 'OK') {
//         _showErrorSnackbar('Error fetching route: ${result.errorMessage}');
//       }
//     } catch (e) {
//       _showErrorSnackbar('Error: ${e.toString()}');
//     }
//   }

//   void _fitBounds(LatLng pickup, LatLng dropoff) {
//     LatLngBounds bounds = LatLngBounds(
//       southwest: LatLng(
//         pickup.latitude < dropoff.latitude ? pickup.latitude : dropoff.latitude,
//         pickup.longitude < dropoff.longitude
//             ? pickup.longitude
//             : dropoff.longitude,
//       ),
//       northeast: LatLng(
//         pickup.latitude > dropoff.latitude ? pickup.latitude : dropoff.latitude,
//         pickup.longitude > dropoff.longitude
//             ? pickup.longitude
//             : dropoff.longitude,
//       ),
//     );

//     _controller.future.then((controller) {
//       controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//     });
//   }

//   void _showErrorSnackbar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   LatLngBounds _getBounds(List<LatLng> points) {
//     double? minLat, maxLat, minLng, maxLng;

//     for (LatLng point in points) {
//       if (minLat == null || point.latitude < minLat) minLat = point.latitude;
//       if (maxLat == null || point.latitude > maxLat) maxLat = point.latitude;
//       if (minLng == null || point.longitude < minLng) minLng = point.longitude;
//       if (maxLng == null || point.longitude > maxLng) maxLng = point.longitude;
//     }

//     return LatLngBounds(
//       southwest: LatLng(minLat!, minLng!),
//       northeast: LatLng(maxLat!, maxLng!),
//     );
//   }
// }
