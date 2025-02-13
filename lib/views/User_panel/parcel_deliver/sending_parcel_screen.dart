
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:rideapp/utils/routes/user_panel_routes.dart';
// import 'package:rideapp/utils/theme/app_colors.dart';
// import 'package:rideapp/viewmodel/provider/map_provider.dart';
// import 'package:rideapp/widgets/custom_button.dart';

// class ParcelSendingScreen extends StatefulWidget {
//   const ParcelSendingScreen({super.key});

//   @override
//   State<ParcelSendingScreen> createState() => _ParcelSendingScreenState();
// }

// class _ParcelSendingScreenState extends State<ParcelSendingScreen> {
//   late GoogleMapController mapController;
//   final TextEditingController _phoneController = TextEditingController();
//   String? _phoneError;

//   final LatLng _center = const LatLng(-25.7479, 28.2293);

//   @override
//   void initState() {
//     super.initState();
//     _loadMapTheme();
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   // THEME LOAD
//   Future<void> _loadMapTheme() async {
//     final mapProvider = Provider.of<MapProvider>(context, listen: false);
//     final mapTheme = await DefaultAssetBundle.of(context)
//         .loadString('assets/map_theme/night_theme.json');
//     mapProvider.setMapTheme(mapTheme);
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     final mapProvider = Provider.of<MapProvider>(context, listen: false);
//     controller.setMapStyle(mapProvider.mapTheme);
//   }

//   void _validatePhone(String value) {
//     setState(() {
//       if (value.isEmpty) {
//         _phoneError = 'Phone number is required';
//       } else if (value.length != 10) {
//         _phoneError = 'Phone number must be 10 digits';
//       } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//         _phoneError = 'Only numbers are allowed';
//       } else {
//         _phoneError = null;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(
//        leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       resizeToAvoidBottomInset: false,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             GoogleMap(
//               onMapCreated: _onMapCreated,
//               initialCameraPosition: CameraPosition(
//                 target: _center,
//                 zoom: 12.0,
//               ),
//             ),
//             Positioned(
//                 bottom: 20,
//                 left: 16,
//                 right: 16,
//                 child: CustomButton(
//                     text: 'receivingparcel.send_button'.tr(),
//                     onPressed: () {
//                       if (_phoneError == null && _phoneController.text.length == 10) {
//                         Navigator.pushNamed(context, AppRoutes.rideBook);
//                       }
//                     })),
//             Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 width: screenWidth,
//                 height: screenHeight * 0.40,
//                 decoration: const BoxDecoration(
//                   color: AppColors.backgroundLight,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(20),
//                     bottomRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     top: 20,
//                     left: 20,
//                     right: 20,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'receivingparcel.sender_title'.tr(),
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'receivingparcel.sender_subtitle'.tr(),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       TextField(
//                         style: const TextStyle(color: Colors.black),
//                         decoration: InputDecoration(
//                           hintText: 'receivingparcel.sender_name_hint'.tr(),
//                           hintStyle: const TextStyle(color: Colors.black54),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: _phoneController,
//                         style: const TextStyle(color: Colors.black),
//                         keyboardType: TextInputType.phone,
//                         maxLength: 10,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         onChanged: _validatePhone,
//                         decoration: InputDecoration(
//                           hintText: 'receivingparcel.phone_hint'.tr(),
//                           hintStyle: const TextStyle(color: Colors.black54),
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           errorText: _phoneError,
//                           counterText: '', // Hides the built-in counter
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/viewmodel/provider/map_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParcelSendingScreen extends StatefulWidget {
  const ParcelSendingScreen({super.key});

  @override
  State<ParcelSendingScreen> createState() => _ParcelSendingScreenState();
}

class _ParcelSendingScreenState extends State<ParcelSendingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> saveSenderDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('senderName', _nameController.text);
    await prefs.setString('senderPhone', _phoneController.text);
  }

  late GoogleMapController mapController;

  String? _phoneError;

  // final LatLng _center = const LatLng(-25.7479, 28.2293);
  final LatLng _center = const LatLng(-25.7479, 28.2293);

  @override
  void initState() {
    super.initState();
    _loadMapTheme();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // THEME LOAD
  Future<void> _loadMapTheme() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final mapTheme = await DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/standard_theme.json');
    mapProvider.setMapTheme(mapTheme);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    controller.setMapStyle(mapProvider.mapTheme);
  }

  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (value.length != 10) {
        _phoneError = 'Phone number must be 10 digits';
      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _phoneError = 'Only numbers are allowed';
      } else {
        _phoneError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: CustomButton(
                  text: 'receivingparcel.receive_button'.tr(),
                  onPressed: () async {
                    if (_phoneError == null &&
                        _phoneController.text.length == 10) {
                      await saveSenderDetails();
                      if (mounted) {
                        Navigator.pushNamed(context, AppRoutes.rideBook);
                      }
                    }
                  }),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.40,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'receivingparcel.sender_title'.tr(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   'receivingparcel.sender_subtitle'.tr(),
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.white60,
                      //   ),
                      // ),
                      // const SizedBox(height: 12),
                      Text(
                        'receivingparcel.dimmensions'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'receivingparcel.sender_name_hint'.tr(),
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _validatePhone,
                        decoration: InputDecoration(
                          hintText: 'receivingparcel.phone_hint'.tr(),
                          hintStyle: const TextStyle(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: _phoneError,
                          counterText: '', // Hides the built-in counter
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
