import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sendme/models/user_model.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/utils/theme/map_theme_popup.dart';
import 'package:sendme/viewmodel/provider/auth_provider/auth_provider.dart';
import 'package:sendme/viewmodel/provider/driver_provider.dart';
import 'package:sendme/views/Driver_panel/ride_screens/ride_details_screen.dart';
import 'package:sendme/views/Driver_panel/widgets/custom_drawer.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideBookingView extends StatefulWidget {
  const RideBookingView({super.key});

  @override
  State<RideBookingView> createState() => _RideBookingViewState();
}

class _RideBookingViewState extends State<RideBookingView> {
  User? userData;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late RideBookingProvider _provider;
  String get baseUrl => Constants.apiBaseUrl;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 14.4746,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<RideBookingProvider>(context, listen: false);
    _initializeScreen();

    _logImageUrls;
    if (_provider.isOnline) {
      _provider.resumeFetching();
    }
  }

  Future<void> _initializeScreen() async {
    try {
      String mapTheme = await DefaultAssetBundle.of(context)
          .loadString('assets/map_theme/night_theme.json');
      _provider.setMapTheme(mapTheme);
      _provider.setRelevantScreenActive(true);
      _provider.initializeData();
      await fetchData();
    } catch (e) {
      log('Error initializing screen: $e');
    }
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


//   Future<void> fetchData() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     AuthProvider authService = AuthProvider();
    
//     // First try to get cached data
//     final cachedUserData = prefs.getString('userData');
//     if (cachedUserData != null) {
//       final data = User.fromJson(jsonDecode(cachedUserData));
//       setState(() {
//         userData = data;
//       });
//     }

//     // Then try to fetch fresh data
//     await authService.fetchUserData();
//     var data = await authService.getUserData();

//     if (data != null) {
//       if (data.fcmToken == null) {
//         log('FCM Token is null, navigating to login screen');
//         await prefs.clear();
//         if (mounted) {
//           Navigator.pushReplacementNamed(context, AppRoutes.userLogin);
//         }
//         return;
//       }

//       setState(() {
//         userData = data;
//       });

//       Map<String, dynamic> userMap = userData!.toJson();
//       await prefs.setString('userData', jsonEncode(userMap));
      
//       String? token = await authService.getToken();
//       if (token != null) {
//         await prefs.setString('token', token);
//       }
//     }
//   } catch (e) {
//     log('Error in fetchData: $e');
//     // Don't rethrow - use cached data if available
//     if (userData == null) {
//       // Only show error if we have no cached data
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error fetching latest user data: $e'))
//         );
//       }
//     }
//   }
// }

  // Future<void> fetchData() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     AuthProvider authService = AuthProvider();
  //     await authService.fetchUserData();
  //     var data = await authService.getUserData();

  //     if (data != null) {
  //       // Check if FCM token is null
  //       if (data.fcmToken == null) {
  //         log('FCM Token is null, navigating to login screen');
  //         // Clear saved data
  //         await prefs.clear();

  //         // Navigate to login screen and remove all previous routes
  //         if (mounted) {
  //           Navigator.pushReplacementNamed(context, AppRoutes.userLogin);
  //         }
  //         return; // Exit the method early
  //       }

  //       setState(() {
  //         userData = data;
  //       });

  //       if (userData != null) {
  //         Map<String, dynamic> userMap = userData!.toJson();
  //         await prefs.setString('userData', jsonEncode(userMap));
  //         log('Saved user data: $userMap');

  //         String? token = await authService.getToken();
  //         if (token != null) {
  //           await prefs.setString('token', token);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     log('Error in fetchData: $e');
  //     rethrow;
  //   }
  // }

  @override
  void dispose() {
    _provider.setRelevantScreenActive(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Consumer<RideBookingProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  controller.setMapStyle(provider.mapTheme);
                },
                onTap: provider.setPickupLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
              _buildTopBar(context),
              if (provider.isOnline) _buildRideList(provider),
              _buildBottomBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideCard(
      Map<String, dynamic> ride, RideBookingProvider provider) {
    final displayData = ride['displayData'] as Map<String, dynamic>;
    final serviceType = displayData['serviceType'] ?? 'ride';
    final parcelType = displayData['parcelType'];
    // final isParcel = serviceType == 'parcel';

    return Card(
      // Change card color based on service type
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Type and Parcel Type Indicator
            _buildServiceTypeIndicator(serviceType, parcelType),
            const SizedBox(height: 10),
            _buildRideCardHeader(displayData),
            const SizedBox(height: 15),
            _buildLocationInfo(
                Icons.circle,
                'ride_booking.location.pickup'.tr(),
                displayData['pickupAddress'] ?? 'N/A'),
            const SizedBox(height: 10),
            _buildLocationInfo(
                Icons.location_on,
                'ride_booking.location.dropoff'.tr(),
                displayData['destinationAddress'] ?? 'N/A'),
            const SizedBox(height: 20),
            _buildRideActions(ride, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeIndicator(String serviceType, String? parcelType) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                serviceType == 'parcel'
                    ? Icons.local_shipping
                    : Icons.directions_bike,
                color: Colors.black,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                serviceType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (serviceType == 'parcel' && parcelType != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              parcelType.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 30,
      right: 12,
      left: 12,
      child: Builder(
        builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Image.asset("assets/icons/user_account_icon.png"),
            ),
            MapThemePopup(controller: _controller),
          ],
        ),
      ),
    );
  }

  Widget _buildRideList(RideBookingProvider provider) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      bottom: 150,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: provider.rideRequests
              .map((ride) => _buildRideCard(ride, provider))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(RideBookingProvider provider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: CustomButton(
            text: provider.isOnline
                ? 'ride_booking.go_offline'.tr()
                : 'ride_booking.go_online'.tr(),
            onPressed:
                provider.isOnline ? provider.goOffline : provider.goOnline,
          ),
        ),
      ),
    );
  }


  void _logImageUrls(String? imageUrl) {
    log('Profile Image Debug:');
    log('Original URL: $imageUrl');
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : "${Constants.apiBaseUrl}/$imageUrl";
      log('Full URL: $fullUrl');
    }
  }

  Widget _buildRideCardHeader(Map<String, dynamic> displayData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: displayData['profilePicture'] != null &&
                          displayData['profilePicture'].toString().isNotEmpty
                      ? Image.network(
                          _getProfileImageUrl(displayData['profilePicture']),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultProfileImage();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.buttonColor,
                              ),
                            );
                          },
                        )
                      : _buildDefaultProfileImage(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayData['username'] ??
                          'ride_booking.unknown_user'.tr(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      displayData['email'] ?? 'ride_booking.no_email'.tr(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '\$${displayData['estimatedFare'] ?? 'N/A'}',
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getProfileImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    // Log the URL for debugging
    log('Original image URL: $imageUrl');

    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : "${Constants.apiBaseUrl}$imageUrl";

    // Log the processed URL
    log('Processed image URL: $fullUrl');

    return fullUrl;
  }

  Widget _buildDefaultProfileImage() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 35,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildLocationInfo(IconData icon, String type, String address) {
    return Row(
      children: [
        Icon(icon,
            color: AppColors.buttonColor,
            size: type == 'ride_booking.location.pickup'.tr() ? 16 : 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(color: Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  ImageProvider _getProfileImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullImageUrl =
          imageUrl.startsWith('http') ? imageUrl : "$baseUrl$imageUrl";
      return NetworkImage(fullImageUrl);
    } else {
      return const AssetImage("assets/images/profile.png");
    }
  }

  Widget _buildRideActions(
      Map<String, dynamic> ride, RideBookingProvider provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text('More',
                style: AppTextTheme.getLightTextTheme(context).bodyMedium),
            onPressed: () {
              provider.setRelevantScreenActive(false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RideDetailsScreen(
                    displayData: ride['displayData'] as Map<String, dynamic>,
                    fullData: ride['fullData'] as Map<String, dynamic>,
                  ),
                ),
              ).then((_) {
                if (mounted) {
                  if (provider.isOnline) {
                    provider.resumeFetching();
                  }
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => provider.removeRideRequest(ride),
        ),
      ],
    );
  }
}
