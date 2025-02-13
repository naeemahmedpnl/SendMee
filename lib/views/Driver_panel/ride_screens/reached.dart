import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/viewmodel/provider/map_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
import '../widgets/custom_drawer.dart';

class ReachedScreen extends StatefulWidget {
  const ReachedScreen({super.key});

  @override
  State<ReachedScreen> createState() => _ReachedScreenState();
}

class _ReachedScreenState extends State<ReachedScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.8649492, 67.0568085),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/night_theme.json')
        .then((value) {
      mapProvider.setMapTheme(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              controller.setMapStyle(mapProvider.mapTheme);
            },
            onTap: (LatLng location) {
              mapProvider.setPickupLocation(location);
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: CustomButton(
                  text: "Reached",
                  onPressed: () {
                    Navigator.pushNamed(context, AppDriverRoutes.paymentdetails);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
