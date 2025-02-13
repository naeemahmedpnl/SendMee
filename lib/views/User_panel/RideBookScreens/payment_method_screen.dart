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
    PaymentMethod(
      id: 'card',
      title: 'payment.card'.tr(),
      subtitle: 'Credit or Debit card',
      icon: "assets/images/card.png",
      backgroundColor: Colors.blue,
    ),
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

  Future<void> handleCardPayment() async {
    try {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);

      if (widget.estimatedFare == null || widget.estimatedFare!.isEmpty) {
        throw 'Monto inválido';
      }

      final success = await paymentProvider.makePayment(widget.estimatedFare!);

      if (success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.ratingScreen);
        }
      } else {
        if (mounted) {
          _showErrorDialog(paymentProvider.errorMessage ?? 'Error en el pago');
        }
      }
    } catch (e) {
      log('Payment error: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  

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
                                        'MXN \$${widget.estimatedFare ?? "0.00"}',
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
                                        handleCardPayment();
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
