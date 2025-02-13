import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
// import 'package:rideapp/utils/routes/user_panel_routes.dart';
import 'package:rideapp/widgets/custom_button.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? estimatedFare;

  const PaymentMethodScreen({Key? key, this.estimatedFare}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
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
      backgroundColor: Colors.green.withOpacity(0.1),
    ),
    PaymentMethod(
      id: 'card',
      title: 'payment.card'.tr(),
      subtitle: 'Credit or Debit card',
      icon: "assets/images/card.png",
      backgroundColor: Colors.blue.withOpacity(0.1),
    ),
     PaymentMethod(
      id: 'wallet',
      title: 'Wallet Payment',
      subtitle: 'Pay at Wallet',
      icon: "assets/images/wallet.png",
      backgroundColor: Colors.orange.withOpacity(0.1),
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

  

  // List View Implementation
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
                color: Colors.white.withOpacity(0.1),
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
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
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

  // Grid View Implementation
  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: paymentMethods.length,
      itemBuilder: (context, index) {
        final method = paymentMethods[index];
        final isSelected = selectedPaymentMethod == method.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedPaymentMethod = method.id;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          method.icon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        method.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
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
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Fare:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${widget.estimatedFare ?? "0.00"}',
                             
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text(
                        //   'payment.select_payment'.tr(),
                        //   style: const TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: _buildListView(), // or _buildGridView()
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'Continue with ${selectedPaymentMethod}',
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppDriverRoutes.paymentsuccesful);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
