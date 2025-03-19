// import 'dart:convert';
// import 'dart:developer';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sendme/models/user_model.dart';
// import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:sendme/utils/theme/app_text_theme.dart';
// import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
// import 'package:sendme/widgets/custom_button.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   User? userData;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//    fetchData();
    
//   }


  
// Future<void> fetchData() async {
//   try {
//     log('Starting to fetch user data...');
//     final prefs = await SharedPreferences.getInstance();
//     final existingToken = prefs.getString('token');
//     log('Existing token from SharedPreferences: $existingToken');

//     AuthProvider authService = AuthProvider();
    
//     try {
//       await authService.fetchUserData().timeout(
//         const Duration(seconds: 10),
//       );
      
//       var data = await authService.getUserData();
      

//          if (data != null) {
//       setState(() {
//         userData = data;
//       });

//       if (userData != null) {
//         Map<String, dynamic> userMap = userData!.toJson(); 
//         await prefs.setString('userData', jsonEncode(userMap));
        
//         String? token = await authService.getToken();
//         if (token != null) {
//           await prefs.setString('token', token); 
//         }
        
//         log('=========== Verification ===========');
//         log('Saved User Data: ${prefs.getString('userData')}');
//         log('Saved Token: ${prefs.getString('token')}');
//         log('===================================');
//       }
//     }
      
//     } catch (e) {
//       log('Error fetching user data: $e');
      
//       if (e.toString().contains('158.220.90.248')) { 
//         _showErrorDialog('Server is currently unavailable. Please try again later.');
//       } else if (e.toString().contains('SocketException')) {
//         _showErrorDialog('Please check your internet connection.');
//       } else {
//         _showErrorDialog('Unable to connect to server. Please try again later.');
//       }
//     }

//   } catch (e) {
//     log('Error in fetchData: $e');
//     _showErrorDialog('An unexpected error occurred. Please try again.');
//   }
// }


//   // First add this helper function in your class to show error dialog
// void _showErrorDialog(String message) {
//   if (mounted) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           title: Row(
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red),
//               const SizedBox(width: 10),
//               Text('Error', style: AppTextTheme.getLightTextTheme(context).titleMedium),
//             ],
//           ),
//           content: Text(
//             message,
//             style: AppTextTheme.getLightTextTheme(context).bodyMedium,
//           ),
//           actions: [
//             CustomButton(text: "Ok", onPressed: (){
//               Navigator.of(context).pop();
//             },
//             borderRadius: 40,
//             )
//             // TextButton(
//             //   child: const Text('OK'),
//             //   onPressed: () {
//             //     Navigator.of(context).pop();
//             //   },
//             // ),
//           ],
//         );
//       },
//     );
//   }
// }


//   Future<void> _onRefresh()async {
//     await fetchData();
//   }


//   // Future<void> _loadUserData() async {
//   //   try {
//   //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//   //     await authProvider.fetchUserData();
//   //     final user = await authProvider.getUserData();

//   //     setState(() {
//   //       userData = user;
//   //       isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     log('Error loading user data: $e');
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   Widget _buildRatingStars() {
//     double averageRating = userData?.passengerDetails?.ratingAverage ?? 0.0;
//     int fullStars = averageRating.floor();
//     bool hasHalfStar = (averageRating - fullStars) >= 0.5;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         ...List.generate(fullStars,
//             (index) => const Icon(Icons.star, color: Colors.yellow, size: 20)),
//         if (hasHalfStar)
//           const Icon(Icons.star_half, color: Colors.yellow, size: 20),
//         ...List.generate(
//             5 - fullStars - (hasHalfStar ? 1 : 0),
//             (index) =>
//                 const Icon(Icons.star_border, color: Colors.yellow, size: 20)),
//         const SizedBox(width: 4.0),
//         Text(averageRating.toStringAsFixed(1),
//             style: const TextStyle(color: Colors.white)),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       // backgroundColor: Colors.black,
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.arrow_back_ios_new_outlined,
//                           color: Colors.black54, size: 25),
//                     ),
//                     Text("profile.title".tr(),
//                         style: AppTextTheme.getLightTextTheme(context)
//                             .headlineMedium),
//                     IconButton(
//                       onPressed: () => Navigator.pushNamed(
//                           context, AppRoutes.editProfileScreen),
//                       icon: const Icon(Icons.edit, color: Colors.black, size: 25),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 const CircleAvatar(
//                   radius: 50,
//                   backgroundImage: AssetImage('assets/images/profile.png'),
//                 ),
//                 const SizedBox(height: 8.0),
//                 Text(
//                   userData?.username ?? 'N/A',
//                   style: const TextStyle(color: Colors.black, fontSize: 24.0),
//                 ),
//                 const SizedBox(height: 4.0),
//                 _buildRatingStars(),
//                 const SizedBox(height: 16.0),
//                 ProfileHistoryCard(userData: userData),
//                 const SizedBox(height: 16.0),
//                 Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text("profile.wallet".tr(),
//                         style:
//                             AppTextTheme.getLightTextTheme(context).titleLarge)),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(context, AppRoutes.walletScreen);
//                   },
//                   child: Container(
//                     width: screenWidth,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.black54),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20.0, vertical: 10),
//                       child: Row(
//                         children: [
//                           Image.asset(
//                               width: 28, height: 28, "assets/images/wallet.png"),
//                           const SizedBox(width: 15),
//                           Text(
//                             'Wallet',
//                             style: AppTextTheme.getLightTextTheme(context)
//                                 .titleLarge,
//                           ),
//                           const Spacer(),
//                           Text(
//                             '${userData?.walletBalance ?? 0}',
//                             style: AppTextTheme.getLightTextTheme(context)
//                                 .titleLarge,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProfileHistoryCard extends StatelessWidget {
//   final User? userData; // Changed type from Map<String, dynamic>? to User?

//   const ProfileHistoryCard({super.key, this.userData});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildInfoRow(
//                 context, 'profile.phone_label'.tr(), userData?.phone ?? 'N/A'),
//             const Divider(
//               color: Colors.black,
//             ),
//             _buildInfoRow(
//                 context, 'profile.email_label'.tr(), userData?.email ?? 'N/A'),
//             const Divider(
//               color: Colors.black,
//             ),
//             // If address is not in your User model, add it there
//             _buildInfoRow(context, 'profile.address_label'.tr(),
//                 userData?.email ?? 'N/A'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: AppTextTheme.getLightTextTheme(context).bodyLarge),
//           Flexible(
//             child: Text(
//               value,
//               style: AppTextTheme.getLightTextTheme(context).bodySmall,
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/profile_provider.dart';
import 'package:shimmer/shimmer.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
    });
  }

  String get baseUrl => Constants.apiBaseUrl;

  Widget _buildRatingStars(User? userData) {
    double averageRating = userData?.passengerDetails?.ratingAverage ?? 0.0;
    int fullStars = averageRating.floor();
    bool hasHalfStar = (averageRating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(fullStars,
            (index) => const Icon(Icons.star, color: Colors.yellow, size: 20)),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.yellow, size: 20),
        ...List.generate(
            5 - fullStars - (hasHalfStar ? 1 : 0),
            (index) =>
                const Icon(Icons.star_border, color: Colors.yellow, size: 20)),
        const SizedBox(width: 4.0),
        Text(averageRating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.black)),
      ],
    );
  }

// Also update the _buildShimmerEffect method
  Widget _buildShimmerEffect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 40, height: 40, circular: true),
              ShimmerBox(width: 120, height: 24),
              ShimmerBox(width: 40, height: 40, circular: true),
            ],
          ),
          const SizedBox(height: 20),

          // Profile Image
          const ShimmerBox(width: 80, height: 80, circular: true),
          const SizedBox(height: 16),

          // Username and Rating
          const ShimmerBox(width: 150, height: 24),
          const SizedBox(height: 8),
          const ShimmerBox(width: 120, height: 20),
          const SizedBox(height: 24),

          // Profile History Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: List.generate(
                3,
                (index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 80, height: 16),
                      ShimmerBox(width: 120, height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Wallet Section
          const Align(
            alignment: Alignment.centerLeft,
            child: ShimmerBox(width: 100, height: 20),
          ),
          const SizedBox(height: 10),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Row(
              children: [
                ShimmerBox(width: 28, height: 28),
                SizedBox(width: 15),
                ShimmerBox(width: 80, height: 20),
                Spacer(),
                ShimmerBox(width: 60, height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
     
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.isLoading) {
              return _buildShimmerEffect();
            }

            final userData = profileProvider.profileData;
            if (userData == null) {
              return const Center(child: Text('No profile data available'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      // IconButton(
                      //   onPressed: () => Navigator.pop(context),
                      //   icon: const Icon(Icons.arrow_back_ios_new_outlined,
                      //       color: Colors.white, size: 25),
                      // ),
                      Text("profile.title".tr(),
                          style: AppTextTheme.getLightTextTheme(context)
                              .headlineMedium),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.editProfileScreen),
                        icon: const Icon(Icons.edit,
                            color: Colors.black, size: 25),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Colors.grey[300], 
                    backgroundImage: userData.profilePicture?.isNotEmpty == true
                        ? NetworkImage('$baseUrl${userData.profilePicture}')
                        : const AssetImage("assets/images/profile.png")
                            as ImageProvider,
                    child: userData.profilePicture?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person,
                            size: 40, color: Colors.grey),
                    onBackgroundImageError: (error, stackTrace) {
                      log(
                          "Image URL that failed: $baseUrl${userData.profilePicture}");
                   
                    },
                  ),
                  // CircleAvatar(
                  //   radius: 40,
                  //   backgroundImage: userData.profilePicture != null
                  //       ? NetworkImage('$baseUrl${userData.profilePicture}')
                  //       : const AssetImage("assets/images/profile.png") as ImageProvider,
                  //   onBackgroundImageError: (_, __) {},
                  // ),
                  const SizedBox(height: 8.0),
                  Text(
                    userData.username ?? 'N/A',
                    style: const TextStyle(color: Colors.black, fontSize: 24.0),
                  ),
                  const SizedBox(height: 4.0),
                  _buildRatingStars(userData),
                  const SizedBox(height: 16.0),
                  ProfileHistoryCard(userData: userData),
                  const SizedBox(height: 16.0),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text("profile.wallet".tr(),
                          style: AppTextTheme.getLightTextTheme(context)
                              .titleLarge)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.walletScreen);
                    },
                    child: Container(
                      width: screenWidth,
                      height: 60,
                      decoration: BoxDecoration(
                       color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Row(
                          children: [
                            Image.asset(
                                width: 28,
                                height: 28,
                                "assets/images/wallet.png"),
                            const SizedBox(width: 15),
                            Text(
                              "profile.wallet".tr(),
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge,
                            ),
                            const Spacer(),
                            Text(
                              '\$${userData.walletBalance}',
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileHistoryCard extends StatelessWidget {
  final User? userData;

  const ProfileHistoryCard({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                context, 'profile.phone_label'.tr(), userData?.phone ?? 'N/A'),
            _buildInfoRow(
                context, 'profile.email_label'.tr(), userData?.email ?? 'N/A'),
            _buildRideInfo(context, userData?.totalRides),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextTheme.getLightTextTheme(context).bodyLarge),
          Flexible(
            child: Text(
              value,
              style: AppTextTheme.getLightTextTheme(context).bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideInfo(BuildContext context, TotalRides? totalRides) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('profile.total_rides'.tr(),
              style: AppTextTheme.getLightTextTheme(context).bodyLarge),
          Flexible(
            child: Text(
              '${totalRides?.total ?? 0}',
              style: AppTextTheme.getLightTextTheme(context).bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final bool circular;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: circular
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(8),
        ),
      ),
    );
  }
}