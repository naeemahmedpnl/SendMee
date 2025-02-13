
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/widgets/custom_button.dart';

class PaymentDetails extends StatefulWidget {
  @override
  _PaymentDetailsState createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  String mapTheme = "";
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _kKarachi = CameraPosition(
    target: LatLng(24.8607, 67.0011),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/night_theme.json')
        .then((value) {
      mapTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kKarachi,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              if (mapTheme.isNotEmpty) {
                controller.setMapStyle(mapTheme);
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.8,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: screenWidth * 0.9,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 14,
                        left: 10,
                        right: 5,
                        bottom: 10
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                flex: 3,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage('assets/images/profile.png')
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "James Steve",
                                      style: AppTextTheme.getLightTextTheme(context).headlineSmall,
                                    ),
                                    Text(
                                      'payment_details.driver_info.distance_away'.tr(args: ['3.2']),
                                      style: AppTextTheme.getLightTextTheme(context).titleLarge,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.star_border, color: AppColors.primary),
                                        Text(
                                          'payment_details.driver_info.rating'.tr(),
                                          style: AppTextTheme.getLightTextTheme(context).titleLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, AppDriverRoutes.messages);
                                      },
                                      child: Image.asset(
                                        "assets/icons/messageicon.png",
                                        width: 45,
                                        height: 45,
                                      )
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        // Call the driver
                                      },
                                      child: Image.asset(
                                        "assets/icons/callicon.png",
                                        width: 45,
                                        height: 45,
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 15),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'payment_details.fare_details.total_fare'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).titleMedium
                          ),
                          Text(
                            'payment_details.amounts.fare'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).titleLarge
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'payment_details.fare_details.waiting_amount'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).titleMedium
                          ),
                          Text(
                            'payment_details.amounts.waiting'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).titleLarge
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'payment_details.fare_details.pickup_km'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).titleMedium
                          ),
                          Text(
                            'payment_details.amounts.pickup'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).titleLarge
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'payment_details.fare_details.total_price'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).headlineMedium
                          ),
                          Text(
                            'payment_details.amounts.total'.tr(),
                            style: AppTextTheme.getDarkTextTheme(context).headlineMedium
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'payment_details.buttons.collect'.tr(),
                    onPressed: () {
                      Navigator.pushNamed(context, AppDriverRoutes.paymentmethod);
                    }
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}