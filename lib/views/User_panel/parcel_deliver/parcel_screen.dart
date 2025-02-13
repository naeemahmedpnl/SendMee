// import 'dart:convert';
// import 'dart:developer';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:sendme/models/user_model.dart';
// import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:sendme/utils/theme/app_colors.dart';
// import 'package:sendme/utils/theme/app_text_theme.dart';
// import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
// import 'package:sendme/views/User_panel/drawer/drawer.dart';
// import 'package:sendme/widgets/custom_button.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ParcelScreen extends StatefulWidget {
//   const ParcelScreen({Key? key}) : super(key: key);

//   @override
//   State<ParcelScreen> createState() => _ParcelScreenState();
// }

// class _ParcelScreenState extends State<ParcelScreen> {
//   User? userData;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



//   @override
//   void initState() {
//     super.initState();
//         fetchData();
//   }

//     Future<void> fetchData() async {
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
//         Map<String, dynamic> userMap = userData!.toJson(); 
//         await prefs.setString('userData', jsonEncode(userMap));
        
//         // Get and save token properly
//         String? token = await authService.getToken();
//         if (token != null) {
//           await prefs.setString('token', token); 
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


// @override
// Widget build(BuildContext context) {

//   return Scaffold(
//     key: _scaffoldKey,
//     drawer: const CustomDrawer(),
//     body: SafeArea(
//       child: Container(
//         color: AppColors.primary,
//         child: Column(
//           children: [
//             // App Bar Section
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(
//                       Icons.menu,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                     onPressed: () {
//                       _scaffoldKey.currentState?.openDrawer();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Image Section - Using Expanded with flex
//             Expanded(
//               flex: 3,
//               child: Image.asset(
//                 'assets/images/Ridebooking.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             // Bottom Container Section - Using Expanded with flex
//             Expanded(
//               flex: 4,
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: AppColors.backgroundLight,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'parcel.title'.tr(),
//                         style: AppTextTheme.getLightTextTheme(context).headlineMedium
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'parcel.subtitle'.tr(),
//                         style: AppTextTheme.getLightTextTheme(context).bodyLarge
//                       ),
//                       const Spacer(), // Add flexible space
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pushNamed(context, AppRoutes.parcelSendingScreen);
//                         },
//                         child: Container(
//                           height: 54,
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: AppColors.primary,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'parcel.receive_button'.tr(),
//                               style: AppTextTheme.getPrimaryTextTheme(context).titleLarge,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       CustomButton(
//                         text: 'parcel.send_button'.tr(),
//                         onPressed: () {
//                           Navigator.pushNamed(context, AppRoutes.parcelReceivingScreen);
//                         },
//                       ),
//                       const SizedBox(height: 40), // Bottom padding
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }


// }


import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/views/User_panel/drawer/drawer.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ParcelScreen extends StatefulWidget {
  const ParcelScreen({super.key});

  @override
  State<ParcelScreen> createState() => _ParcelScreenState();
}

class _ParcelScreenState extends State<ParcelScreen> {
  User? userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> saveParcelType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parcelType', type);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      log('Starting to fetch user data...');
      final prefs = await SharedPreferences.getInstance();
      final existingToken = prefs.getString('token');
      log('Existing token from SharedPreferences: $existingToken');

      AuthProvider authService = AuthProvider();
      await authService.fetchUserData();
      var data = await authService.getUserData();
      
      if (data != null) {
        setState(() {
          userData = data;
        });

        if (userData != null) {
          Map<String, dynamic> userMap = userData!.toJson(); 
          await prefs.setString('userData', jsonEncode(userMap));
          
          String? token = await authService.getToken();
          if (token != null) {
            await prefs.setString('token', token); 
          }
          
          log('=========== Verification ===========');
          log('Saved User Data: ${prefs.getString('userData')}');
          log('Saved Token: ${prefs.getString('token')}');
          log('===================================');
        }
      }
    } catch (e) {
      log('Error in fetchData: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              ),
            ),
            
            // Image Section
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Image.asset(
                'assets/images/Ridebooking.png',
                fit: BoxFit.cover,
              ),
            ),
            
            const SizedBox(height: 5),
            
            // Bottom Container Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'parcel.title'.tr(),
                        style: AppTextTheme.getLightTextTheme(context).headlineMedium
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'parcel.subtitle'.tr(),
                        style: AppTextTheme.getLightTextTheme(context).bodyLarge
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () async {
                          await saveParcelType('receive');
                          if (mounted) {
                            Navigator.pushNamed(context, AppRoutes.parcelSendingScreen);
                          }
                        },
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'parcel.receive_button'.tr(),
                              style: AppTextTheme.getPrimaryTextTheme(context).titleLarge,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'parcel.send_button'.tr(),
                        onPressed: () async {
                          await saveParcelType('send');
                          if (mounted) {
                            Navigator.pushNamed(context, AppRoutes.parcelReceivingScreen);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
