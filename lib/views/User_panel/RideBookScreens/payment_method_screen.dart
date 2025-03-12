import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
import 'package:sendme/viewmodel/provider/payment_provider.dart';
import 'package:sendme/widgets/custom_button.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? estimatedFare;

  const PaymentMethodScreen({Key? key, this.estimatedFare}) : super(key: key);
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String mapTheme = "";
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.8649492, 67.0568085),
    zoom: 14.4746,
  );

  String selectedPaymentMethod = 'payment.cash_method'.tr();

 

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'cash',
      title: 'payment.cash'.tr(),
      subtitle: 'Pay with cash after ride',
      icon: "assets/images/cash.png",
      backgroundColor: Colors.green,
    ),
    // PaymentMethod(
    //   id: 'card',
    //   title: 'payment.card'.tr(),
    //   subtitle: 'Credit or Debit card',
    //   icon: "assets/images/paynowlogo.png",
    //   backgroundColor: Colors.blue,
    // ),
    PaymentMethod(
      id: 'wallet',
      title: 'Wallet Payment',
      subtitle: 'Pay at Wallet',
      icon: "assets/images/wallet.png",
      backgroundColor: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    log('Total Fare: ${widget.estimatedFare}');
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/night_theme.json')
        .then((value) {
      mapTheme = value;
    });
  }



  // Update handleWalletPayment method
  Future<void> handleWalletPayment() async {
    try {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);

      if (widget.estimatedFare == null || widget.estimatedFare!.isEmpty) {
        throw 'Invalid amount';
      }

      final success =
          await paymentProvider.makeWalletPayment(widget.estimatedFare!);

      if (success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.ratingScreen);
        }
      } else {
        if (mounted) {
          _showErrorDialog(paymentProvider.errorMessage ?? 'Payment failed');
        }
      }
    } catch (e) {
      log('Payment error: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  // Future<void> handleCardPayment() async {
  //   try {
  //     final paymentProvider =
  //         Provider.of<PaymentProvider>(context, listen: false);

  //     if (widget.estimatedFare == null || widget.estimatedFare!.isEmpty) {
  //       throw 'Monto inválido';
  //     }

  //     // final success = await paymentProvider.makePayment(widget.estimatedFare!);

  //     if (success) {
  //       if (mounted) {
  //         Navigator.pushReplacementNamed(context, AppRoutes.ratingScreen);
  //       }
  //     } else {
  //       if (mounted) {
  //         _showErrorDialog(paymentProvider.errorMessage ?? 'Error en el pago');
  //       }
  //     }
  //   } catch (e) {
  //     log('Payment error: $e');
  //     if (mounted) {
  //       _showErrorDialog(e.toString());
  //     }
  //   }
  // }

  

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Pago'),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        final method = paymentMethods[index];
        final isSelected = selectedPaymentMethod == method.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedPaymentMethod = method.id;
              });
            },
            child: Container(
              decoration: BoxDecoration(
          
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : Border.all(color: Colors.white24, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: method.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            method.icon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.subtitle,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              controller.setMapStyle(mapTheme);
            },
          ),
          Consumer<PaymentProvider>(
            builder: (context, paymentProvider, child) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                // In PaymentMethodScreen widget
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Fare:',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'ZAR \$${widget.estimatedFare ?? "0.00"}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                SizedBox(
                                  height: 300,
                                  child: _buildListView(),
                                ),
                                const SizedBox(height: 20),
                                CustomButton(
                                  text:
                                      'Continue with ${selectedPaymentMethod}',
                                  onPressed: () {
                                    if (Provider.of<PaymentProvider>(context,
                                            listen: false)
                                        .isLoading) {
                                      return;
                                    }

                                    switch (selectedPaymentMethod) {
                                      case 'card':
                                        // handleCardPayment();
                                        break;
                                      case 'wallet':
                                        handleWalletPayment();
                                        break;
                                      default:
                                        Navigator.pushReplacementNamed(
                                            context, AppRoutes.ratingScreen);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (paymentProvider.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color backgroundColor;

  PaymentMethod({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
  });
}



// // import 'dart:async';
// // import 'dart:developer';
// // import 'dart:ui';
// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:sendme/utils/routes/driver_panel_routes.dart';
// // // import 'package:rideapp/utils/routes/user_panel_routes.dart';
// // import 'package:sendme/widgets/custom_button.dart';

// // class PaymentMethodScreen extends StatefulWidget {
// //   final String? estimatedFare;

// //   const PaymentMethodScreen({super.key, this.estimatedFare});

// //   @override
// //   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// // }

// // class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
// //   String mapTheme = "";
// //   final Completer<GoogleMapController> _controller =
// //       Completer<GoogleMapController>();

// //   static const CameraPosition _kGooglePlex = CameraPosition(
// //     target: LatLng(24.8649492, 67.0568085),
// //     zoom: 14.4746,
// //   );

// //  String selectedPaymentMethod = 'payment.cash_method'.tr();

// //   final List<PaymentMethod> paymentMethods = [
// //     PaymentMethod(
// //       id: 'cash',
// //       title: 'payment.cash'.tr(),
// //       subtitle: 'payment.cash_method'.tr(),
// //       icon: "assets/images/cash.png",
// //       backgroundColor: Colors.green.withOpacity(0.1),
// //     ),
// //     // PaymentMethod(
// //     //   id: 'card',
// //     //   title: 'payment.card'.tr(),
// //     //   subtitle: 'payment.card_method'.tr(),
// //     //   icon: "assets/images/card.png",
// //     //   backgroundColor: Colors.blue.withOpacity(0.1),
// //     // ),
// //     PaymentMethod(
// //       id: 'wallet',
// //       title: 'payment.wallet'.tr(),
// //       subtitle: 'payment.wallet_method'.tr(),
// //       icon: "assets/images/wallet.png",
// //       backgroundColor: Colors.orange.withOpacity(0.1),
// //     ),
// //   ];

// //   @override
// //   void initState() {
// //     super.initState();
// //        log('Total Fare: ${widget.estimatedFare}');
// //     DefaultAssetBundle.of(context)
// //         .loadString('assets/map_theme/standard_theme.json')
// //         .then((value) {
// //       mapTheme = value;
// //     });
// //   }

  

// //   // List View Implementation
// //   Widget _buildListView() {
// //     return ListView.builder(
// //       shrinkWrap: true,
// //       physics: const BouncingScrollPhysics(),
// //       itemCount: paymentMethods.length,
// //       itemBuilder: (context, index) {
// //         final method = paymentMethods[index];
// //         final isSelected = selectedPaymentMethod == method.id;

// //         return Padding(
// //           padding: const EdgeInsets.only(bottom: 12),
// //           child: GestureDetector(
// //             onTap: () {
// //               setState(() {
// //                 selectedPaymentMethod = method.id;
// //               });
// //             },
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(16),
// //                 border: isSelected
// //                     ? Border.all(color: Colors.blue, width: 2)
// //                     : Border.all(color: Colors.white24, width: 1),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.1),
// //                     blurRadius: 10,
// //                     spreadRadius: 1,
// //                   ),
// //                 ],
// //               ),
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(16),
// //                 child: BackdropFilter(
// //                   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
// //                   child: Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: method.backgroundColor,
// //                       borderRadius: BorderRadius.circular(16),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Container(
// //                           width: 50,
// //                           height: 50,
// //                           padding: const EdgeInsets.all(8),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Image.asset(
// //                             method.icon,
// //                             fit: BoxFit.contain,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 16),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 method.title,
// //                                 style: const TextStyle(
// //                                   color: Colors.white,
// //                                   fontSize: 16,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 4),
// //                               Text(
// //                                 method.subtitle,
// //                                 style: TextStyle(
// //                                   color: Colors.white.withOpacity(0.7),
// //                                   fontSize: 14,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         if (isSelected)
// //                           Container(
// //                             padding: const EdgeInsets.all(4),
// //                             decoration: const BoxDecoration(
// //                               color: Colors.blue,
// //                               shape: BoxShape.circle,
// //                             ),
// //                             child: const Icon(
// //                               Icons.check,
// //                               color: Colors.white,
// //                               size: 16,
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }


// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: _kGooglePlex,
// //             onMapCreated: (GoogleMapController controller) {
// //               _controller.complete(controller);
// //               controller.setMapStyle(mapTheme);
// //             },
// //           ),
// //           Align(
// //             alignment: Alignment.bottomCenter,
// //             child: Container(
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Colors.black.withOpacity(0.7),
// //                     Colors.black.withOpacity(0.9),
// //                   ],
// //                 ),
// //                 borderRadius: const BorderRadius.only(
// //                   topLeft: Radius.circular(20),
// //                   topRight: Radius.circular(20),
// //                 ),
// //               ),
// //               child: ClipRRect(
// //                 borderRadius: const BorderRadius.only(
// //                   topLeft: Radius.circular(20),
// //                   topRight: Radius.circular(20),
// //                 ),
// //                 child: BackdropFilter(
// //                   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
// //                   child: Container(
// //                     padding: const EdgeInsets.all(20),
// //                     child: Column(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         Container(
// //                           width: 60,
// //                           height: 5,
// //                           decoration: BoxDecoration(
// //                             color: Colors.white.withOpacity(0.3),
// //                             borderRadius: BorderRadius.circular(5),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 5),
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(
// //                               vertical: 15, horizontal: 20),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white.withOpacity(0.1),
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text(
// //                                 'payment.total_fare'.tr(),
// //                                 style: const TextStyle(
// //                                   color: Colors.white,
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                               const Text(
// //                                 '\${widget.estimatedFare ?? "0.00"}',
// //                                 style: TextStyle(
// //                                   color: Colors.white,
// //                                   fontSize: 20,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         const SizedBox(height: 20),
// //                         SizedBox(
// //                           height: 300,
// //                           child: _buildListView(),
// //                         ),
// //                         const SizedBox(height: 20),
// //                         CustomButton(
// //                           text: '${'payment.continue_with'.tr()} ${selectedPaymentMethod}',
// //                           onPressed: () {
// //                             Navigator.pushNamed(
// //                                 context, AppDriverRoutes.paymentsuccesful);
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class PaymentMethod {
// //   final String id;
// //   final String title;
// //   final String subtitle;
// //   final String icon;
// //   final Color backgroundColor;

// //   PaymentMethod({
// //     required this.id,
// //     required this.title,
// //     required this.subtitle,
// //     required this.icon,
// //     required this.backgroundColor,
// //   });
// // }



// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:ui';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// import 'package:sendme/utils/constant/image_url.dart';
// import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:sendme/utils/theme/app_colors.dart';
// import 'package:sendme/viewmodel/provider/payment_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PaymentMethodScreen extends StatefulWidget {
//   final String estimatedFare;
//   final String? deliveryProofImage;
//   final bool isParcelDelivery;

//   const PaymentMethodScreen({
//     super.key,
//     required this.estimatedFare,
//     this.deliveryProofImage,
//     this.isParcelDelivery = false,
//   });

//   @override
//   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// }

// class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
//   String mapTheme = "";
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   static const double PLATFORM_FEE_PERCENTAGE = 0.05;

//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(24.8649492, 67.0568085),
//     zoom: 14.4746,
//   );

//   String selectedPaymentMethod = 'cash';
//   double? fareAmount;
//   double walletBalance = 0.0;
//   bool isLoading = true;

//   // Properties for delivery proof
//   String? deliveryProofImage;
//   bool isParcelDelivery = false;

//   String get baseUrl => Constants.apiBaseUrl;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _loadMapTheme();
//   }

//   Future<void> _initializeData() async {
//     log('PaymentMethodScreen - Initializing data');

//     // Get values directly from widget properties
//     final estimatedFareStr = widget.estimatedFare;
//     final imageUrl = widget.deliveryProofImage;
//     final parcelDelivery = widget.isParcelDelivery;

//     log('Arguments received - Fare: $estimatedFareStr, Image: $imageUrl, IsParcel: $parcelDelivery');

//     // Always normalize image URL
//     final normalizedImageUrl =
//         imageUrl != null ? ImageUrlUtils.getFullImageUrl(imageUrl) : null;

//     setState(() {
//       fareAmount = double.tryParse(estimatedFareStr) ?? 0.0;
//       deliveryProofImage = normalizedImageUrl;
//       isParcelDelivery = parcelDelivery;
//     });

//     log('State updated - Fare: $fareAmount, Image URL: $deliveryProofImage');

//     await _fetchUserData();
//   }

//   void _showFullScreenImage(BuildContext context, String imageUrl) {
//     final normalizedUrl = ImageUrlUtils.getFullImageUrl(imageUrl);

//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(
//             title: Text(tr('parcel.delivery_proof')),
//             backgroundColor: Colors.black,
//           ),
//           backgroundColor: Colors.black,
//           body: Center(
//             child: InteractiveViewer(
//               minScale: 0.5,
//               maxScale: 3.0,
//               child: Image.network(
//                 normalizedUrl,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                           : null,
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   log('Error loading image: $error');
//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline,
//                           color: Colors.red, size: 60),
//                       const SizedBox(height: 20),
//                       Text(
//                           'Failed to load image: ${error.toString().substring(0, 50)}...'),
//                       const SizedBox(height: 20),
//                       Text('URL: $normalizedUrl',
//                           style: const TextStyle(fontSize: 12)),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _loadMapTheme() async {
//     try {
//       final mapThemeData = await DefaultAssetBundle.of(context)
//           .loadString('assets/map_theme/standard_theme.json');
//       mapTheme = mapThemeData;
//       log('Map theme loaded successfully');
//     } catch (e) {
//       log('Error loading map theme: $e');
//     }
//   }

//   Future<void> _fetchUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString('userData');

//       if (userDataString != null) {
//         final userData = json.decode(userDataString);
//         setState(() {
//           walletBalance = (userData['walletBalance'] ?? 0.0).toDouble();
//           isLoading = false;
//         });
//         log('Wallet Balance: $walletBalance');
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         log('No userData found in SharedPreferences');
//       }
//     } catch (e) {
//       log('Error fetching user data: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   bool isCashPaymentAvailable() {
//     if (fareAmount == null || fareAmount! <= 0) return false;
//     return true;
//   }

//   bool isWalletPaymentAvailable() {
//     if (fareAmount == null || fareAmount! <= 0) return false;
//     if (walletBalance <= 0) return false;
//     return walletBalance >= fareAmount!;
//   }

//   bool isCardPaymentAvailable() {
//     if (fareAmount == null || fareAmount! <= 0) return false;
//     return fareAmount! >= 10.0;
//   }

//   Future<void> handlePayment() async {
//     try {
//       final paymentProvider =
//           Provider.of<PaymentProvider>(context, listen: false);
//       final prefs = await SharedPreferences.getInstance();
//       final tripId = prefs.getString('tripId');

//       if (tripId == null) {
//         throw Exception('Trip ID not found');
//       }

//       // Get fare amount directly from widget property
//       final estimatedFare = widget.estimatedFare;

//       log('Using estimatedFare for payment: $estimatedFare');

//       if (estimatedFare.isEmpty || double.tryParse(estimatedFare) == 0) {
//         throw Exception('Invalid fare amount');
//       }

//       if (selectedPaymentMethod == 'cash' && !isCashPaymentAvailable()) {
//         throw Exception('Insufficient wallet balance for platform fee');
//       }

//       bool success = false;

//       switch (selectedPaymentMethod) {
//         case 'cash':
//           log('Processing cash payment for amount: $estimatedFare');
//           success = await paymentProvider.confirmCashPayment(
//             tripId: tripId,
//             amount: estimatedFare,
//           );
//           break;

//         // case 'card':
//         //   log('Processing card payment for amount: $estimatedFare');
//         //   final stripeSuccess =
//         //       await paymentProvider.makePayment(estimatedFare);
//         //   if (stripeSuccess) {
//         //     success = await paymentProvider.confirmCardPayment(
//         //       tripId: tripId,
//         //       amount: estimatedFare,
//         //       paymentIntentId: paymentProvider.lastPaymentIntentId ?? '',
//         //     );
//         //   } else {
//         //     throw Exception(
//         //         paymentProvider.errorMessage ?? 'Card payment failed');
//         //   }
//         //   break;

//         case 'wallet':
//           log('Processing wallet payment for amount: $estimatedFare');
//           if (!isWalletPaymentAvailable()) {
//             throw Exception('Insufficient wallet balance');
//           }
//           success = await paymentProvider.confirmWalletPayment(
//             tripId: tripId,
//             amount: estimatedFare,
//           );
//           break;

//         default:
//           throw Exception('Invalid payment method selected');
//       }

//       if (success && mounted) {
//         Navigator.pushReplacementNamed(context, AppRoutes.ratingScreen);
//       } else if (mounted) {
//         _showErrorDialog(paymentProvider.errorMessage ?? 'Payment failed');
//       }
//     } catch (e) {
//       log('Payment error: $e');
//       if (mounted) {
//         _showErrorDialog(e.toString());
//       }
//     }
//   }

//   void _showErrorMessage(String title, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showInsufficientBalanceSnackbar() {
//     _showErrorMessage('Insufficient Balance',
//         'Insufficient wallet balance for platform fee (${(PLATFORM_FEE_PERCENTAGE * 100).toStringAsFixed(0)}% of fare)');
//   }

//   void _showMinimumAmountSnackbar() {
//     _showErrorMessage('Minimum Amount',
//         'Card payment is not available for amounts less than MXN 10');
//   }

//   void _showErrorDialog(String message) {
//     final cleanMessage = message.replaceAll('Exception:', '').trim();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('payment.error'.tr()),
//         content: Text(
//           cleanMessage,
//           style: const TextStyle(color: Colors.black),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get fare from class property
//     final displayFare = widget.estimatedFare;
//     log('Display fare in build: $displayFare');

//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _kGooglePlex,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//               controller.setMapStyle(mapTheme);
//             },
//           ),
//           Consumer<PaymentProvider>(
//             builder: (context, paymentProvider, child) {
//               return Stack(
//                 children: [
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.black.withOpacity(0.7),
//                             Colors.black.withOpacity(0.9),
//                           ],
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Container(
//                                   width: 60,
//                                   height: 5,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 25),
//                                 if (isParcelDelivery &&
//                                     deliveryProofImage != null)
//                                   Column(
//                                     children: [
//                                       Row(
//                                         children: [
//                                           const Icon(Icons.check_circle,
//                                               color: Colors.green, size: 22),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             ('parcel.delivery_proof'.tr()),
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 12),
//                                       GestureDetector(
//                                         onTap: () => _showFullScreenImage(
//                                             context, deliveryProofImage!),
//                                         child: Container(
//                                           height: 140,
//                                           width: double.infinity,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             border: Border.all(
//                                                 color: AppColors.primary),
//                                           ),
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             child: Stack(
//                                               fit: StackFit.expand,
//                                               children: [
//                                                 Image.network(
//                                                   ImageUrlUtils.getFullImageUrl(
//                                                       deliveryProofImage!),
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder: (context,
//                                                       child, loadingProgress) {
//                                                     if (loadingProgress == null)
//                                                       return child;
//                                                     return Center(
//                                                       child:
//                                                           CircularProgressIndicator(
//                                                         color: Colors.white,
//                                                         value: loadingProgress
//                                                                     .expectedTotalBytes !=
//                                                                 null
//                                                             ? loadingProgress
//                                                                     .cumulativeBytesLoaded /
//                                                                 loadingProgress
//                                                                     .expectedTotalBytes!
//                                                             : null,
//                                                       ),
//                                                     );
//                                                   },
//                                                   errorBuilder: (context, error,
//                                                       stackTrace) {
//                                                     log('Error loading image in payment screen: $error');
//                                                     return Container(
//                                                       color: Colors.grey[800],
//                                                       child: Column(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           const Icon(
//                                                             Icons.error_outline,
//                                                             color: Colors.red,
//                                                             size: 40,
//                                                           ),
//                                                           const SizedBox(
//                                                               height: 10),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Text(
//                                                               'parcel.could_not_load_image'
//                                                                   .tr(),
//                                                               style: const TextStyle(
//                                                                   color: Colors
//                                                                       .white70),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//                                                 Positioned(
//                                                   bottom: 0,
//                                                   left: 0,
//                                                   right: 0,
//                                                   child: Container(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(vertical: 8),
//                                                     color: Colors.black
//                                                         .withOpacity(0.6),
//                                                     child: Text(
//                                                       'parcel.tap_to_view'.tr(),
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize: 14,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(height: 20),
//                                       const Divider(
//                                           color: AppColors.primary, height: 1),
//                                       const SizedBox(height: 20),
//                                     ],
//                                   ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 15,
//                                     horizontal: 20,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         'Total Fare:',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       Text(
//                                         'MXN \$$displayFare',
//                                         style: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 SizedBox(
//                                   height: isParcelDelivery &&
//                                           deliveryProofImage != null
//                                       ? 220
//                                       : 300,
//                                   child: _buildListView(),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.primary,
//                                     minimumSize:
//                                         const Size(double.infinity, 50),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     if (paymentProvider.isLoading) return;
//                                     handlePayment();
//                                   },
//                                   child: Text(
//                                     'Continue with ${selectedPaymentMethod == 'cash' ? 'Cash' : selectedPaymentMethod == 'card' ? 'Card' : 'Wallet'}',
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   if (paymentProvider.isLoading)
//                     Container(
//                       color: Colors.black.withOpacity(0.5),
//                       child: const Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // Your existing _buildListView method
//   Widget _buildListView() {
//     // Get payment methods list
//     final methods = paymentMethods;

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const BouncingScrollPhysics(),
//       itemCount: methods.length,
//       itemBuilder: (context, index) {
//         final method = methods[index];
//         final isSelected = selectedPaymentMethod == method.id;

//         return Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: GestureDetector(
//             onTap: () {
//               if (!method.isEnabled) {
//                 if (method.id == 'cash') {
//                   _showInsufficientBalanceSnackbar();
//                 } else if (method.id == 'card') {
//                   _showMinimumAmountSnackbar();
//                 } else if (method.id == 'wallet') {
//                   _showErrorMessage('Insufficient Balance',
//                       'Insufficient wallet balance for payment');
//                 }
//                 return;
//               }
//               setState(() {
//                 selectedPaymentMethod = method.id;
//               });
//             },
//             child: Opacity(
//               opacity: method.isEnabled ? 1.0 : 0.5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                   border: isSelected
//                       ? Border.all(color: Colors.blue, width: 2)
//                       : Border.all(color: Colors.white24, width: 1),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       spreadRadius: 1,
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: method.backgroundColor,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Image.asset(
//                               method.icon,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   method.title,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   method.subtitle,
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.7),
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (isSelected && method.isEnabled)
//                             Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 color: Colors.blue,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.check,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<PaymentMethod> get paymentMethods {
//     final bool isCardAvailable = isCardPaymentAvailable();
//     final bool isCashEnabled = isCashPaymentAvailable();
//     final bool isWalletEnabled = isWalletPaymentAvailable();

//     return [
//       PaymentMethod(
//         id: 'cash',
//         title: 'Cash Payment',
//         subtitle: 'Pay with cash after ride',
//         icon: "assets/images/cash.png",
//         backgroundColor: Colors.green.withOpacity(0.1),
//         isEnabled: isCashEnabled,
//       ),
//       PaymentMethod(
//         id: 'card',
//         title: 'Card Payment',
//         subtitle: isCardAvailable
//             ? 'Credit or Debit card'
//             : 'Not available for amounts less than MXN 10',
//         icon: "assets/images/card.png",
//         backgroundColor: Colors.blue.withOpacity(0.1),
//         isEnabled: isCardAvailable,
//       ),
//       PaymentMethod(
//         id: 'wallet',
//         title: 'Wallet Payment',
//         subtitle:
//             isWalletEnabled ? 'Pay with Wallet' : 'Insufficient wallet balance',
//         icon: "assets/images/wallet.png",
//         backgroundColor: Colors.orange.withOpacity(0.1),
//         isEnabled: isWalletEnabled,
//       ),
//     ];
//   }
// }

// class PaymentMethod {
//   final String id;
//   final String title;
//   final String subtitle;
//   final String icon;
//   final Color backgroundColor;
//   final bool isEnabled;

//   PaymentMethod({
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.backgroundColor,
//     required this.isEnabled,
//   });
// }
