
// import 'dart:convert';
// import 'dart:developer';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:rideapp/models/user_model.dart';
// import 'package:rideapp/utils/routes/user_panel_routes.dart';
// import 'package:rideapp/utils/theme/app_colors.dart';
// import 'package:rideapp/viewmodel/provider/auth_provider/auth_provider.dart';
// import 'package:rideapp/viewmodel/provider/ridebook_provider.dart';
// import 'package:rideapp/views/User_panel/drawer/drawer.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class parcelScreenView extends StatefulWidget {
//   const parcelScreenView({super.key});

//   @override
//   State<parcelScreenView> createState() => _parcelScreenViewState();
// }

// class _parcelScreenViewState extends State<parcelScreenView> {
//   User? userData;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//     SystemChannels.textInput.invokeMethod('TextInput.hide');
//   }

//   @override
//   void dispose() {

//     SystemChannels.textInput.invokeMethod('TextInput.show');
//     super.dispose();
//   }

//   Future<void> changeLanguage(BuildContext context, String languageCode) async {
//     final locale = Locale(languageCode);
//     await context.setLocale(locale);

//     // Save selected language
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('language', languageCode);
//   }
//   Future<void> fetchData() async {
//   try {
//     log('Starting to fetch user data...');
    
//     // Get token from SharedPreferences first
//     final prefs = await SharedPreferences.getInstance();
//     final existingToken = prefs.getString('token');
//     log('Existing token from SharedPreferences: $existingToken');

//     // Create AuthProvider instance
//     AuthProvider authService = AuthProvider();
    
//     // Fetch user data
//     await authService.fetchUserData();
//     var data = await authService.getUserData();
    
//     if (data != null) {
//       setState(() {
//         userData = data;
//       });

//       // Save user data properly
//       if (userData != null) {
//         // Convert User object to Map first
//         Map<String, dynamic> userMap = userData!.toJson(); // Make sure your User model has toJson method
//         await prefs.setString('userData', jsonEncode(userMap));
        
//         // Get and save token properly
//         String? token = await authService.getToken();
//         if (token != null) {
//           await prefs.setString('token', token); // Save token directly, not as JSON
//         }
        
//         // Verify saved data
//         log('=========== Verification ===========');
//         log('Saved User Data: ${prefs.getString('userData')}');
//         log('Saved Token: ${prefs.getString('token')}');
//         log('===================================');
//       }
//     }
//   } catch (e) {
//     log('Error in fetchData: $e');
//     // Handle error appropriately
//     rethrow;
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final rideProvider = Provider.of<RideProvider>(context, listen: false);

//     return 
//     GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//         SystemChannels.textInput.invokeMethod('TextInput.hide');
//       },
//       child: 
//       Scaffold(
//         key: _scaffoldKey,
//         drawer: CustomDrawer(),
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           children: [
//             Expanded(
//               flex: 5,
//               child: Container(
//                 width: double.infinity,
//                 height: 330,
//                 decoration: const BoxDecoration(
//                   color: Colors.white12,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 35, left: 15),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Builder(
//                             builder: (context) => IconButton(
//                               onPressed: () {
//                                 Scaffold.of(context).openDrawer();
//                               },
//                               icon: const Icon(
//                                 Icons.list,
//                                 size: 45,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 20),
//                             child: Container(
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(50),
//                                 border: Border.all(color: Colors.amber, width: 1),
//                               ),
//                               child: IconButton(
//                                 onPressed: () async {
//                                   try {
//                                     if (context.locale == const Locale('en')) {
//                                       await changeLanguage(context, 'es');
//                                     } else {
//                                       await changeLanguage(context, 'en');
//                                     }

//                                     if (context.mounted) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                               context.locale.languageCode == 'en'
//                                                   ? 'Language changed to English'
//                                                   : 'Idioma cambiado a Español'),
//                                           duration: const Duration(seconds: 1),
//                                         ),
//                                       );
//                                     }
//                                   } catch (e) {
//                                     if (context.mounted) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(
//                                           content: Text('Error changing language'),
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 },
//                                 icon: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     const Icon(
//                                       Icons.language,
//                                       size: 20,
//                                       color: Colors.amber,
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Text(
//                                       context.locale.languageCode.toUpperCase(),
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'home_screen.tagline'.tr(),
//                         style: Theme.of(context).textTheme.headlineMedium,
//                       ),
//                       const SizedBox(height: 30),
//                       Container(
//                         width: 150,
//                         height: 37,
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'home_screen.get_started'.tr(),
//                             style: const TextStyle(color: Colors.black),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               flex: 8,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         rideProvider.setTripType(TripType.ride);
//                         Navigator.pushNamed(context, AppRoutes.rideBook);
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         height: 145,
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 20),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 flex: 5,
//                                 child: Image.asset(
//                                   "assets/images/bike.png",
//                                   height: 260,
//                                 ),
//                               ),
//                               Expanded(
//                                 flex: 6,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(top: 20, right: 20),
//                                   child: Align(
//                                     alignment: Alignment.topRight,
//                                     child: Text(
//                                       'home_screen.ride_type.bike'.tr(),
//                                       style: Theme.of(context).textTheme.headlineMedium,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: () {
//                         rideProvider.setTripType(TripType.parcel);
//                         Navigator.pushNamed(context, AppRoutes.parcelScreen);
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         height: 145,
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 6,
//                               child: Image.asset(
//                                 "assets/images/deliverybox.png",
//                                 height: 260,
//                               ),
//                             ),
//                             Expanded(
//                               flex: 4,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 20, right: 20),
//                                 child: Align(
//                                   alignment: Alignment.topRight,
//                                   child: Text(
//                                     'home_screen.ride_type.delivery'.tr(),
//                                     style: Theme.of(context).textTheme.headlineMedium,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }